const cds = require('@sap/cds')

let lastSyncTimestamp = null;
let isSyncing = false;
const SYNC_COOLDOWN_MS = 60000;

// ─── Fonctions Utilitaires ────────────────────────────────────────────────────
function extractResults(response) {
  if (!response) return []
  if (Array.isArray(response.value)) return response.value
  if (response.d?.results) return response.d.results
  if (Array.isArray(response)) return response
  return []
}

function parseODataDate(val) {
  if (!val) return null
  if (typeof val === 'string' && val.startsWith('/Date(')) {
    const ms = parseInt(val.match(/\d+/)[0])
    return new Date(ms).toISOString().substring(0, 10)
  }
  return val
}

function mapPOStatus(s4Status) {
  const map = { '01': 'En cours', '02': 'Livré', '03': 'Clôturé' }
  return map[s4Status] ?? s4Status ?? 'Inconnu'
}

function mapInvoicePaymentStatus(s4Status) {
  if (!s4Status || s4Status === '' || s4Status === 'O') return 'En attente'
  if (s4Status === 'C') return 'Payée'
  return s4Status
}

// ─── Diversification déterministe des données sandbox ─────────────────────────

/**
 * Soustrait N mois à une date et retourne une chaîne YYYY-MM-DD.
 */
function subtractMonths(date, months) {
  const d = new Date(date)
  d.setMonth(d.getMonth() - months)
  return d.toISOString().substring(0, 10)
}

/**
 * Calcule les champs à distribuer selon la position relative (ratio 0→1)
 * du fournisseur dans la liste triée. Couvre tous les buckets d'inactivité
 * et de statut pour garantir un affichage varié dans Fiori.
 *
 * Distribution :
 *   0–18 %  → Actif,               inactivité 1–5 mois   (vert)
 *  18–35 %  → Actif,               inactivité 6–11 mois  (orange)
 *  35–60 %  → Actif,               inactivité 12–30 mois (rouge)
 *  60–78 %  → Bloqué,              inactivité 15–36 mois
 *  78–100 % → En cours de clôture, inactivité 24–48 mois
 */
function distributionBucket(ratio, today) {
  let poMonthsAgo, invMonthsAgo, blockingStatus

  if (ratio < 0.18) {
    poMonthsAgo  = 1 + Math.round((ratio / 0.18) * 4)
    invMonthsAgo = Math.max(1, poMonthsAgo - 1)
    blockingStatus = 'Actif'
  } else if (ratio < 0.35) {
    poMonthsAgo  = 6 + Math.round(((ratio - 0.18) / 0.17) * 5)
    invMonthsAgo = poMonthsAgo + 1
    blockingStatus = 'Actif'
  } else if (ratio < 0.60) {
    poMonthsAgo  = 12 + Math.round(((ratio - 0.35) / 0.25) * 18)
    invMonthsAgo = poMonthsAgo + 2
    blockingStatus = 'Actif'
  } else if (ratio < 0.78) {
    poMonthsAgo  = 15 + Math.round(((ratio - 0.60) / 0.18) * 21)
    invMonthsAgo = poMonthsAgo + 1
    blockingStatus = 'Bloqué'
  } else {
    poMonthsAgo  = 24 + Math.round(((ratio - 0.78) / 0.22) * 24)
    invMonthsAgo = poMonthsAgo + 3
    blockingStatus = 'En cours de clôture'
  }

  return {
    lastPODate:      subtractMonths(today, poMonthsAgo),
    lastInvoiceDate: subtractMonths(today, invMonthsAgo),
    blockingStatus
  }
}

/**
 * Applique la distribution déterministe à tous les vendors de la base locale.
 * Les vendors triés par vendorID garantissent un résultat identique à chaque sync.
 * Les vendors avec pendingAction (actions CAP en cours) sont ignorés.
 */
async function diversifyVendors(VendorsEntity) {
  const log = cds.log('s4sync')
  const today = new Date()

  const vendors = await SELECT.from(VendorsEntity).columns('ID', 'vendorID', 'pendingAction')
  vendors.sort((a, b) => a.vendorID.localeCompare(b.vendorID))

  const n = vendors.length
  let updated = 0

  for (let i = 0; i < n; i++) {
    const v = vendors[i]
    if (v.pendingAction) continue
    const { lastPODate, lastInvoiceDate, blockingStatus } = distributionBucket(i / n, today)
    await UPDATE(VendorsEntity).set({ lastPODate, lastInvoiceDate, blockingStatus }).where({ ID: v.ID })
    updated++
  }

  log.info(`Diversification appliquée à ${updated}/${n} fournisseurs`)
}

// ─── Calcul des KPIs et Retards (Inchangé) ────────────────────────────────────
function computeDelayAverages(vendorID, invoices, pos, today) {
  const cutoff = new Date(today)
  cutoff.setFullYear(cutoff.getFullYear() - 2)

  const relevantInvoices = invoices.filter(inv => inv.vendors_ID === vendorID && inv.dueDate && inv.paymentDate && new Date(inv.lastInvoiceDate) >= cutoff)
  let paymentDelayAvg = null
  if (relevantInvoices.length > 0) {
    const total = relevantInvoices.reduce((sum, inv) => sum + (new Date(inv.paymentDate) - new Date(inv.dueDate)) / 86400000, 0)
    paymentDelayAvg = Math.round((total / relevantInvoices.length) * 10) / 10
  }

  const relevantPOs = pos.filter(po => po.vendors_ID === vendorID && po.plannedDeliveryDate && po.deliveryDate && new Date(po.lastPODate) >= cutoff)
  let deliveryDelayAvg = null
  if (relevantPOs.length > 0) {
    const total = relevantPOs.reduce((sum, po) => sum + (new Date(po.deliveryDate) - new Date(po.plannedDeliveryDate)) / 86400000, 0)
    deliveryDelayAvg = Math.round((total / relevantPOs.length) * 10) / 10
  }

  return { paymentDelayAvg, deliveryDelayAvg }
}

function computeVendorMetrics(v, today, paymentDelayAvg = null, deliveryDelayAvg = null) {
  const dates = [v.lastPODate, v.lastInvoiceDate].filter(Boolean).map(d => new Date(d))
  let inactivityMonths = null
  if (dates.length) {
    const last = new Date(Math.max(...dates))
    inactivityMonths = (today.getFullYear() - last.getFullYear()) * 12 + (today.getMonth() - last.getMonth())
  }

  let inactivityCriticality = null
  if (inactivityMonths !== null) {
    if (inactivityMonths < 6) inactivityCriticality = 3
    else if (inactivityMonths < 12) inactivityCriticality = 2
    else inactivityCriticality = 1
  }

  let cleanliness = 100
  if (inactivityMonths !== null) {
    if (inactivityMonths >= 24) cleanliness -= 50
    else if (inactivityMonths >= 12) cleanliness -= 30
    else if (inactivityMonths >= 6) cleanliness -= 15
  }
  if (v.blockingStatus === 'Bloqué') cleanliness -= 30
  else if (v.blockingStatus === 'En cours de clôture') cleanliness -= 15
  if (!v.totalPOAmount || Number(v.totalPOAmount) === 0) cleanliness -= 10
  if (!v.lastInvoiceDate) cleanliness -= 10
  if (paymentDelayAvg !== null && paymentDelayAvg > 30) cleanliness -= 20
  if (deliveryDelayAvg !== null && deliveryDelayAvg > 15) cleanliness -= 20

  const riskScore = Math.max(0, Math.min(100, 100 - cleanliness))
  let riskStatus, riskScoreCriticality
  if (riskScore <= 30) { riskStatus = 'Faible'; riskScoreCriticality = 3 }
  else if (riskScore <= 60) { riskStatus = 'Modéré'; riskScoreCriticality = 2 }
  else { riskStatus = 'Élevé'; riskScoreCriticality = 1 }

  const blockVendor_ac = v.blockingStatus !== 'Bloqué'
  const unblockVendor_ac = v.blockingStatus === 'Bloqué'
  const requestClosure_ac = v.blockingStatus === 'Actif'
  const blockVendor_hide = !blockVendor_ac
  const unblockVendor_hide = !unblockVendor_ac
  const requestClosure_hide = !requestClosure_ac

  return { inactivityMonths, inactivityCriticality, riskScore, riskStatus, riskScoreCriticality, paymentDelayAvg, deliveryDelayAvg, blockVendor_ac, unblockVendor_ac, requestClosure_ac, blockVendor_hide, unblockVendor_hide, requestClosure_hide }
}

async function updateVendorPOAggregates(VendorsEntity, POsEntity) {
  const allPOs = await SELECT.from(POsEntity).columns('vendors_ID', 'lastPODate', 'totalPOAmount')
  const grouped = {}
  for (const po of allPOs) {
    if (!po.vendors_ID) continue
    if (!grouped[po.vendors_ID]) grouped[po.vendors_ID] = { lastPODate: null, totalPOAmount: 0 }
    if (po.lastPODate && (!grouped[po.vendors_ID].lastPODate || po.lastPODate > grouped[po.vendors_ID].lastPODate))
      grouped[po.vendors_ID].lastPODate = po.lastPODate
    grouped[po.vendors_ID].totalPOAmount += Number(po.totalPOAmount) || 0
  }
  for (const [id, agg] of Object.entries(grouped)) {
    await UPDATE(VendorsEntity).set({ lastPODate: agg.lastPODate, totalPOAmount: Math.round(agg.totalPOAmount * 100) / 100 }).where({ ID: id })
  }
}

async function updateVendorInvoiceAggregates(VendorsEntity, InvoicesEntity) {
  const allInvs = await SELECT.from(InvoicesEntity).columns('vendors_ID', 'lastInvoiceDate')
  const grouped = {}
  for (const inv of allInvs) {
    if (!inv.vendors_ID) continue
    if (!grouped[inv.vendors_ID] || (inv.lastInvoiceDate && inv.lastInvoiceDate > grouped[inv.vendors_ID]))
      grouped[inv.vendors_ID] = inv.lastInvoiceDate
  }
  for (const [id, lastInvoiceDate] of Object.entries(grouped)) {
    await UPDATE(VendorsEntity).set({ lastInvoiceDate }).where({ ID: id })
  }
}


// ─── Définition du Service Principal ──────────────────────────────────────────
module.exports = class LongTailVendorManagementSrv extends cds.ApplicationService {
  async init() {

    // ── Auto-Synchronisation lors du READ (Bouton 'Go') ───────────────────────
    this.before('READ', 'Vendors', async (req) => {
      // 1. On ignore si la requête cible un seul ID (ex: Fiori Object Page)
      if (req.params && req.params.length > 0) return;

      const now = Date.now();
      
      // 2. Vérification du verrou et du Cooldown
      if (isSyncing || (lastSyncTimestamp && (now - lastSyncTimestamp < SYNC_COOLDOWN_MS))) {
        return; 
      }

      isSyncing = true; // On verrouille pour les requêtes parallèles
      const log = cds.log('s4sync');
      log.info('Auto-synchronisation déclenchée par Fiori (Bouton Go)...');

      try {
        const [BupaAPI, PoAPI, InvAPI] = await Promise.all([
          cds.connect.to('API_BUSINESS_PARTNER'),
          cds.connect.to('CE_PURCHASEORDER_0001'),
          cds.connect.to('API_SUPPLIERINVOICE_PROCESS_SRV')
        ]);
        const { Vendors, PurchaseOrders, Invoices } = cds.entities('longTailVendorManagement');
        
        const poRaw = await PoAPI.get('/PurchaseOrder?$select=PurchaseOrder,Supplier,PurchaseOrderDate,PurchasingProcessingStatus&$expand=_PurchaseOrderItem($select=NetAmount)&$top=200');
        const pos = extractResults(poRaw);

        const invRaw = await InvAPI.get('/A_SupplierInvoice?$select=SupplierInvoice,FiscalYear,InvoicingParty,PostingDate,InvoiceGrossAmount,SupplierInvoicePaymentStatus,DueCalculationBaseDate&$top=200');
        const invoices = extractResults(invRaw);

        const vendorIds = new Set([
          ...pos.map(po => po.Supplier).filter(Boolean),
          ...invoices.map(inv => inv.InvoicingParty).filter(Boolean)
        ]);
        
        const uniqueVendors = Array.from(vendorIds).slice(0, 40); 
        if (uniqueVendors.length === 0) return;

        const bpFilter = uniqueVendors.map(id => `BusinessPartner eq '${id}'`).join(' or ');
        const suppFilter = uniqueVendors.map(id => `Supplier eq '${id}'`).join(' or ');

        const bpRaw = await BupaAPI.get(`/A_BusinessPartner?$filter=${bpFilter}&$expand=to_BusinessPartnerAddress,to_BusinessPartnerBank&$top=50`);
        const bps = extractResults(bpRaw);

        const suppRaw = await BupaAPI.get(`/A_Supplier?$filter=${suppFilter}&$select=Supplier,SupplierName,PurchasingIsBlocked,PaymentIsBlockedForSupplier,TaxNumber1&$top=50`);
        const suppliers = extractResults(suppRaw);

        const bpMap = Object.fromEntries(bps.map(bp => [bp.BusinessPartner, bp]));
        const existingVendors = await SELECT.from(Vendors).columns('ID', 'vendorID', 'pendingAction');
        const existingVMap = Object.fromEntries(existingVendors.map(v => [v.vendorID, v]));

        const vInsert = [], vUpdate = [];
        for (const s of suppliers) {
          const vendorID = s.Supplier;
          const bp = bpMap[vendorID] || {};
          const blockingStatus = (s.PurchasingIsBlocked || s.PaymentIsBlockedForSupplier) ? 'Bloqué' : 'Actif';
          const vendorName = s.SupplierName || '';
          const taxNumber = s.TaxNumber1 || null;

          let address = '', country = '';
          const addrs = bp.to_BusinessPartnerAddress?.results || bp.to_BusinessPartnerAddress || [];
          if (addrs.length > 0) {
              country = addrs[0].Country || '';
              address = [addrs[0].StreetName, addrs[0].PostalCode, addrs[0].CityName].filter(Boolean).join(', ').substring(0, 200);
          }

          let bankData = '';
          const banks = bp.to_BusinessPartnerBank?.results || bp.to_BusinessPartnerBank || [];
          if (banks.length > 0) {
              bankData = (banks[0].BankAccount || banks[0].BankNumber || 'Banque Sandbox').substring(0, 100);
          }

          const found = existingVMap[vendorID];
          if (found) {
              vUpdate.push({
                  ID: found.ID, vendorName, country, address, bankData,
                  ...(taxNumber ? { taxNumber } : {}),
                  ...(found.pendingAction ? {} : { blockingStatus })
              });
          } else {
              vInsert.push({
                  ID: cds.utils.uuid(), vendorID, vendorName, country, address, bankData,
                  taxNumber: taxNumber || '', category: 'Autre', blockingStatus, accountManager: 'Non assigné'
              });
          }
        }
        if (vInsert.length) await INSERT.into(Vendors).entries(vInsert);
        for (const v of vUpdate) await UPDATE(Vendors).set(v).where({ ID: v.ID });

        const updatedVendors = await SELECT.from(Vendors).columns('ID', 'vendorID');
        const vendorUUIDMap = Object.fromEntries(updatedVendors.map(v => [v.vendorID, v.ID]));

        const existingPOs = await SELECT.from(PurchaseOrders).columns('ID', 'purchaseOrderID');
        const poMap = Object.fromEntries(existingPOs.map(p => [p.purchaseOrderID, p.ID]));
        const pInsert = [], pUpdate = [];

        for (const po of pos) {
          const vendors_ID = vendorUUIDMap[po.Supplier];
          if (!vendors_ID || !po.PurchaseOrder) continue;

          const totalPOAmount = (po._PurchaseOrderItem || []).reduce((sum, item) => sum + (Number(item.NetAmount) || 0), 0);
          const lastPODate = parseODataDate(po.PurchaseOrderDate);
          const status = mapPOStatus(po.PurchasingProcessingStatus);
          const poMonth = lastPODate ? String(lastPODate).substring(0, 7) : null;

          const foundID = poMap[po.PurchaseOrder];
          if (foundID) pUpdate.push({ ID: foundID, vendorID: po.Supplier, vendors_ID, lastPODate, totalPOAmount: totalPOAmount || null, status });
          else pInsert.push({ ID: cds.utils.uuid(), purchaseOrderID: po.PurchaseOrder, vendorID: po.Supplier, vendors_ID, lastPODate, totalPOAmount: totalPOAmount || null, status, poMonth });
        }
        if (pInsert.length) await INSERT.into(PurchaseOrders).entries(pInsert);
        for (const p of pUpdate) await UPDATE(PurchaseOrders).set(p).where({ ID: p.ID });

        const existingInvs = await SELECT.from(Invoices).columns('ID', 'invoiceID');
        const invMap = Object.fromEntries(existingInvs.map(i => [i.invoiceID, i.ID]));
        const iInsert = [], iUpdate = [];

        for (const inv of invoices) {
          const vendors_ID = vendorUUIDMap[inv.InvoicingParty];
          if (!vendors_ID || !inv.SupplierInvoice) continue;

          const invoiceID = `${inv.SupplierInvoice}/${inv.FiscalYear}`;
          const totalAmount = Number(inv.InvoiceGrossAmount) || null;
          const lastInvoiceDate = parseODataDate(inv.PostingDate);
          const dueDate = parseODataDate(inv.DueCalculationBaseDate);
          const paymentStatus = mapInvoicePaymentStatus(inv.SupplierInvoicePaymentStatus);

          const foundID = invMap[invoiceID];
          if (foundID) iUpdate.push({ ID: foundID, vendorID: inv.InvoicingParty, vendors_ID, lastInvoiceDate, totalAmount, paymentStatus, dueDate });
          else iInsert.push({ ID: cds.utils.uuid(), invoiceID, vendorID: inv.InvoicingParty, vendors_ID, lastInvoiceDate, totalAmount, paymentStatus, dueDate, paymentDate: null, paymentDelay: null });
        }
        if (iInsert.length) await INSERT.into(Invoices).entries(iInsert);
        for (const i of iUpdate) await UPDATE(Invoices).set(i).where({ ID: i.ID });

        await updateVendorPOAggregates(Vendors, PurchaseOrders);
        await updateVendorInvoiceAggregates(Vendors, Invoices);
        await diversifyVendors(Vendors);

        lastSyncTimestamp = Date.now();
        log.info('Auto-synchro terminée avec succès.');

      } catch (err) {
        log.error('Erreur lors de la synchro auto:', err.message);
      } finally {
        isSyncing = false; // <-- On déverrouille quoi qu'il arrive (succès ou erreur)
      }
    })

    this.after('READ', 'Vendors', async (results) => {
      if (typeof results === 'number') return
      const vendors = Array.isArray(results) ? results : [results]
      const today = new Date()
      const { Invoices, PurchaseOrders } = cds.entities('longTailVendorManagement')
      const [allInvoices, allPOs] = await Promise.all([SELECT.from(Invoices), SELECT.from(PurchaseOrders)])

      for (const v of vendors) {
        const { paymentDelayAvg, deliveryDelayAvg } = computeDelayAverages(v.ID, allInvoices, allPOs, today)
        Object.assign(v, computeVendorMetrics(v, today, paymentDelayAvg, deliveryDelayAvg))
      }
      if (Array.isArray(results)) results.sort((a, b) => (b.inactivityMonths ?? -1) - (a.inactivityMonths ?? -1))
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
        vendorID: vendor.vendorID,
        action: 'Block',
        actionDate: new Date().toISOString(),
        user: req.user?.id || 'system',
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
        vendorID: vendor.vendorID,
        action: 'Unblock',
        actionDate: new Date().toISOString(),
        user: req.user?.id || 'system',
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
        pendingAction: 'En cours de clôture'
      }).where({ ID })
      await INSERT.into(ActionLog).entries({
        ID: cds.utils.uuid(),
        vendorID: vendor.vendorID,
        action: 'RequestClosure',
        actionDate: new Date().toISOString(),
        user: req.user?.id || 'system',
        reason: reason || '',
        vendors_ID: ID
      })

      return SELECT.one.from(Vendors).where({ ID })
    })

    return super.init()
  }
}