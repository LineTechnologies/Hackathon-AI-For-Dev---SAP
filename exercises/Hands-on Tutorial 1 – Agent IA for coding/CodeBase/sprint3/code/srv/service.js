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
 * Computes inactivity and risk metrics for a single vendor record.
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
    // Year/month arithmetic avoids floating-point issues at month boundaries
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

  // Invert: riskScore = 100 − cleanliness → higher score = higher risk
  const riskScore = Math.max(0, Math.min(100, 100 - cleanliness))

  let riskStatus, riskScoreCriticality
  if (riskScore <= 30)      { riskStatus = 'Faible';  riskScoreCriticality = 3 }
  else if (riskScore <= 60) { riskStatus = 'Modéré';  riskScoreCriticality = 2 }
  else                      { riskStatus = 'Élevé';   riskScoreCriticality = 1 }

  return {
    inactivityMonths, inactivityCriticality,
    riskScore, riskStatus, riskScoreCriticality,
    paymentDelayAvg, deliveryDelayAvg
  }
}

module.exports = class LongTailVendorManagementSrv extends cds.ApplicationService {
  async init() {
    // Populate computed virtual fields after every Vendors READ
    this.after('READ', 'Vendors', async (results) => {
      // Guard against $count requests (results is a number, not an array/object)
      if (typeof results === 'number') return

      const vendors = Array.isArray(results) ? results : [results]
      const today = new Date()

      // Batch-fetch all invoices and POs to compute per-vendor delay averages
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

      // Sort list results by inactivityMonths descending (most inactive first).
      // Virtual fields cannot be ordered by OData/$orderby, so we sort here.
      if (Array.isArray(results)) {
        results.sort((a, b) => (b.inactivityMonths ?? -1) - (a.inactivityMonths ?? -1))
      }
    })

    // Return pre-aggregated KPI stats as a single record
    this.on('READ', 'VendorStats', async () => {
      const { Vendors, Invoices, PurchaseOrders } = cds.entities('longTailVendorManagement')
      const [vendors, allInvoices, allPOs] = await Promise.all([
        SELECT.from(Vendors),
        SELECT.from(Invoices),
        SELECT.from(PurchaseOrders)
      ])
      const today = new Date()

      let activeCount   = 0
      let inactiveCount = 0
      let highRiskCount = 0
      let blockedCount  = 0

      for (const v of vendors) {
        const { paymentDelayAvg, deliveryDelayAvg } = computeDelayAverages(v.ID, allInvoices, allPOs, today)
        const { inactivityMonths, riskScore } = computeVendorMetrics(v, today, paymentDelayAvg, deliveryDelayAvg)
        if (v.blockingStatus === 'Actif') activeCount++
        if (inactivityMonths !== null && inactivityMonths >= 12) inactiveCount++
        if (riskScore > 60) highRiskCount++
        if (v.blockingStatus === 'Bloqué') blockedCount++
      }

      const total = vendors.length
      const blockedPercentage = total > 0
        ? Math.round((blockedCount / total) * 1000) / 10   // 1 decimal
        : 0

      return [{
        ID: 1,
        totalVendors:     activeCount,
        inactiveVendors:  inactiveCount,
        highRiskVendors:  highRiskCount,
        blockedPercentage
      }]
    })

    return super.init()
  }
}
