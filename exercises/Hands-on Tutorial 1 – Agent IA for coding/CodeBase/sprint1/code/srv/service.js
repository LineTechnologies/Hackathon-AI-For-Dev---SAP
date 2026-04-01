const cds = require('@sap/cds')

module.exports = class LongTailVendorManagementSrv extends cds.ApplicationService {
  async init() {
    this.after('READ', 'Vendors', (results) => {
      // Guard against $count requests (results is a number, not an array/object)
      if (typeof results === 'number') return

      const vendors = Array.isArray(results) ? results : [results]
      const today = new Date()

      for (const v of vendors) {
        const dates = [v.lastPODate, v.lastInvoiceDate]
          .filter(Boolean)
          .map(d => new Date(d))

        if (!dates.length) {
          v.inactivityMonths = null
          continue
        }

        const last = new Date(Math.max(...dates))
        // Use year/month arithmetic to avoid floating-point issues at month boundaries
        v.inactivityMonths =
          (today.getFullYear() - last.getFullYear()) * 12 +
          (today.getMonth() - last.getMonth())

        // Criticality: 3 = Positive (green), 2 = Critical (orange), 1 = Negative (red)
        if (v.inactivityMonths < 6)       v.inactivityCriticality = 3
        else if (v.inactivityMonths < 12) v.inactivityCriticality = 2
        else                              v.inactivityCriticality = 1
      }
    })

    return super.init()
  }
}
