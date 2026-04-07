const cds = require('@sap/cds')

/**
 * Compute average payment and delivery delays for a single vendor.
 * Only considers records from the last 24 months with all required date fields.
 */
function computeDelayAverages(vendorID, invoices, pos, today) {
  const cutoff = new Date(today)
  cutoff.setFullYear(cutoff.getFullYear() - 2)

  const relevantInvoices = invoices.filter(inv =>
    inv.vendors_ID === vendorID &&
    inv.dueDate && inv.paymentDate &&
    new Date(inv.lastInvoiceDate) >= cutoff
  )
  let paymentDelayAvg = null
  if (relevantInvoices.length > 0) {
    const total = relevantInvoices.reduce((sum, inv) =>
      sum + (new Date(inv.paymentDate) - new Date(inv.dueDate)) / 86400000, 0)
    paymentDelayAvg = Math.round((total / relevantInvoices.length) * 10) / 10
  }

  const relevantPOs = pos.filter(po =>
    po.vendors_ID === vendorID &&
    po.plannedDeliveryDate && po.deliveryDate &&
    new Date(po.lastPODate) >= cutoff
  )
  let deliveryDelayAvg = null
  if (relevantPOs.length > 0) {
    const total = relevantPOs.reduce((sum, po) =>
      sum + (new Date(po.deliveryDate) - new Date(po.plannedDeliveryDate)) / 86400000, 0)
    deliveryDelayAvg = Math.round((total / relevantPOs.length) * 10) / 10
  }

  return { paymentDelayAvg, deliveryDelayAvg }
}

/**
 * Computes inactivity, risk metrics, and OperationAvailable flags for a vendor.
 *
 * Risk score semantics: higher score = higher risk.
 *   0–30  → Faible  (green)
 *   31–60 → Modéré  (orange)
 *   61–100→ Élevé   (red)
 */
function computeVendorMetrics(v, today, paymentDelayAvg = null, deliveryDelayAvg = null) {
  // --- Inactivity ---
  const dates = [v.lastPODate, v.lastInvoiceDate]
    .filter(Boolean)
    .map(d => new Date(d))

  let inactivityMonths = null
  if (dates.length) {
    const last = new Date(Math.max(...dates))
    inactivityMonths =
      (today.getFullYear() - last.getFullYear()) * 12 +
      (today.getMonth() - last.getMonth())
  }

  // Criticality: 3 = Positive (green), 2 = Critical (orange), 1 = Negative (red)
  let inactivityCriticality = null
  if (inactivityMonths !== null) {
    if (inactivityMonths < 6)       inactivityCriticality = 3
    else if (inactivityMonths < 12) inactivityCriticality = 2
    else                            inactivityCriticality = 1
  }

  // --- Risk Score: start from a cleanliness baseline and accumulate penalties ---
  let cleanliness = 100

  if (inactivityMonths !== null) {
    if (inactivityMonths >= 24)      cleanliness -= 50
    else if (inactivityMonths >= 12) cleanliness -= 30
    else if (inactivityMonths >= 6)  cleanliness -= 15
  }

  if (v.blockingStatus === 'Bloqué')                   cleanliness -= 30
  else if (v.blockingStatus === 'En cours de clôture') cleanliness -= 15

  if (!v.totalPOAmount || Number(v.totalPOAmount) === 0) cleanliness -= 10
  if (!v.lastInvoiceDate)                                cleanliness -= 10

  if (paymentDelayAvg !== null && paymentDelayAvg > 30)  cleanliness -= 20
  if (deliveryDelayAvg !== null && deliveryDelayAvg > 15) cleanliness -= 20

  const riskScore = Math.max(0, Math.min(100, 100 - cleanliness))

  let riskStatus, riskScoreCriticality
  if (riskScore <= 30)      { riskStatus = 'Faible';  riskScoreCriticality = 3 }
  else if (riskScore <= 60) { riskStatus = 'Modéré';  riskScoreCriticality = 2 }
  else                      { riskStatus = 'Élevé';   riskScoreCriticality = 1 }

  // --- OperationAvailable flags (consumed by @Core.OperationAvailable in UI) ---
  const blockVendor_ac      = v.blockingStatus !== 'Bloqué'
  const unblockVendor_ac    = v.blockingStatus === 'Bloqué'
  const requestClosure_ac   = v.blockingStatus === 'Actif'   // uniquement pour les vendors actifs

  // --- Champs de visibilité pour l'Object Page (inversés des _ac) ---
  // ![@UI.Hidden]: { $Path: '_hide' } → caché quand _hide = true
  const blockVendor_hide      = !blockVendor_ac      // caché si déjà bloqué
  const unblockVendor_hide    = !unblockVendor_ac    // caché si pas bloqué
  const requestClosure_hide   = !requestClosure_ac   // caché si bloqué ou déjà en clôture

  return {
    inactivityMonths, inactivityCriticality,
    riskScore, riskStatus, riskScoreCriticality,
    paymentDelayAvg, deliveryDelayAvg,
    blockVendor_ac, unblockVendor_ac, requestClosure_ac,
    blockVendor_hide, unblockVendor_hide, requestClosure_hide
  }
}

module.exports = class LongTailVendorManagementSrv extends cds.ApplicationService {
  async init() {

    // ── Populate computed virtual fields after every Vendors READ ──────────────
    this.after('READ', 'Vendors', async (results) => {
      if (typeof results === 'number') return

      const vendors = Array.isArray(results) ? results : [results]
      const today = new Date()

      const { Invoices, PurchaseOrders } = cds.entities('longTailVendorManagement')
      const [allInvoices, allPOs] = await Promise.all([
        SELECT.from(Invoices),
        SELECT.from(PurchaseOrders)
      ])

      for (const v of vendors) {
        const { paymentDelayAvg, deliveryDelayAvg } = computeDelayAverages(v.ID, allInvoices, allPOs, today)
        const metrics = computeVendorMetrics(v, today, paymentDelayAvg, deliveryDelayAvg)
        Object.assign(v, metrics)
      }

      if (Array.isArray(results)) {
        results.sort((a, b) => (b.inactivityMonths ?? -1) - (a.inactivityMonths ?? -1))
      }
    })

    // ── Aggregated KPI stats + distribution data for MicroCharts ──────────────
    this.on('READ', 'VendorStats', async () => {
      const { Vendors, Invoices, PurchaseOrders } = cds.entities('longTailVendorManagement')
      const [vendors, allInvoices, allPOs] = await Promise.all([
        SELECT.from(Vendors),
        SELECT.from(Invoices),
        SELECT.from(PurchaseOrders)
      ])
      const today = new Date()

      let activeCount      = 0, blockedCount   = 0, closureCount    = 0
      let inactiveCount    = 0, highRiskCount  = 0
      let lowRiskCount     = 0, mediumRiskCount = 0
      let inactivity0to6   = 0, inactivity6to12 = 0, inactivity12plus = 0
      let riskAmountAtRisk = 0

      for (const v of vendors) {
        const { paymentDelayAvg, deliveryDelayAvg } = computeDelayAverages(v.ID, allInvoices, allPOs, today)
        const { inactivityMonths, riskScore } = computeVendorMetrics(v, today, paymentDelayAvg, deliveryDelayAvg)

        // Blocking status distribution
        if (v.blockingStatus === 'Actif')                   activeCount++
        else if (v.blockingStatus === 'Bloqué')             blockedCount++
        else if (v.blockingStatus === 'En cours de clôture') closureCount++

        // Inactivity KPI + distribution
        if (inactivityMonths !== null) {
          if (inactivityMonths < 6)       inactivity0to6++
          else if (inactivityMonths < 12) inactivity6to12++
          else {
            inactivity12plus++
            inactiveCount++
          }
        }

        // Risk distribution + KPI
        if (riskScore <= 30)      lowRiskCount++
        else if (riskScore <= 60) mediumRiskCount++
        else {
          highRiskCount++
          riskAmountAtRisk += Number(v.totalPOAmount) || 0
        }
      }

      const total = vendors.length
      const blockedPercentage = total > 0
        ? Math.round((blockedCount / total) * 1000) / 10
        : 0

      return [{
        ID: 1,
        // KPI tiles
        totalVendors:     activeCount,
        inactiveVendors:  inactiveCount,
        highRiskVendors:  highRiskCount,
        blockedPercentage,
        riskAmountAtRisk: Math.round(riskAmountAtRisk * 100) / 100,
        // MicroChart distributions
        activeCount,
        blockedCount,
        closureCount,
        lowRiskCount,
        mediumRiskCount,
        inactivity0to6,
        inactivity6to12,
        inactivity12plus
      }]
    })

    // ── Action: blockVendor ────────────────────────────────────────────────────
    this.on('blockVendor', 'Vendors', async (req) => {
      const { ID } = req.params[0]
      const { Vendors, ActionLog } = cds.entities('longTailVendorManagement')

      const vendor = await SELECT.one.from(Vendors).where({ ID })
      if (!vendor) return req.error(404, 'Fournisseur introuvable')
      if (vendor.blockingStatus === 'Bloqué') return req.error(400, 'Ce fournisseur est déjà bloqué')

      await UPDATE(Vendors).set({ blockingStatus: 'Bloqué' }).where({ ID })
      await INSERT.into(ActionLog).entries({
        ID: cds.utils.uuid(),
        vendorID:   vendor.vendorID,
        action:     'Block',
        actionDate: new Date().toISOString(),
        user:       req.user?.id || 'system',
        vendors_ID: ID
      })

      return SELECT.one.from(Vendors).where({ ID })
    })

    // ── Action: unblockVendor ──────────────────────────────────────────────────
    this.on('unblockVendor', 'Vendors', async (req) => {
      const { ID } = req.params[0]
      const { Vendors, ActionLog } = cds.entities('longTailVendorManagement')

      const vendor = await SELECT.one.from(Vendors).where({ ID })
      if (!vendor) return req.error(404, 'Fournisseur introuvable')
      if (vendor.blockingStatus !== 'Bloqué') return req.error(400, 'Ce fournisseur n\'est pas bloqué')

      await UPDATE(Vendors).set({ blockingStatus: 'Actif', pendingAction: null }).where({ ID })
      await INSERT.into(ActionLog).entries({
        ID: cds.utils.uuid(),
        vendorID:   vendor.vendorID,
        action:     'Unblock',
        actionDate: new Date().toISOString(),
        user:       req.user?.id || 'system',
        vendors_ID: ID
      })

      return SELECT.one.from(Vendors).where({ ID })
    })

    // ── Action: requestClosure ─────────────────────────────────────────────────
    this.on('requestClosure', 'Vendors', async (req) => {
      const { ID } = req.params[0]
      const { reason } = req.data
      const { Vendors, ActionLog } = cds.entities('longTailVendorManagement')

      const vendor = await SELECT.one.from(Vendors).where({ ID })
      if (!vendor) return req.error(404, 'Fournisseur introuvable')
      if (vendor.blockingStatus === 'En cours de clôture') return req.error(400, 'Une demande de clôture est déjà en cours')

      await UPDATE(Vendors).set({
        blockingStatus: 'En cours de clôture',
        pendingAction:  'En cours de clôture'
      }).where({ ID })
      await INSERT.into(ActionLog).entries({
        ID: cds.utils.uuid(),
        vendorID:   vendor.vendorID,
        action:     'RequestClosure',
        actionDate: new Date().toISOString(),
        user:       req.user?.id || 'system',
        reason:     reason || '',
        vendors_ID: ID
      })

      return SELECT.one.from(Vendors).where({ ID })
    })

    return super.init()
  }
}
