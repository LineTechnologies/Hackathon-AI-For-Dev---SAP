using { longTailVendorManagement } from '../db/schema.cds';

service longTailVendorManagementSrv {

  @odata.draft.enabled
  entity Vendors as projection on longTailVendorManagement.Vendors
    actions {
      @Common.IsActionCritical: true
      action blockVendor()                    returns Vendors;

      @Common.IsActionCritical: true
      action unblockVendor()                  returns Vendors;

      action requestClosure(reason: String(500)) returns Vendors;
    };

  entity PurchaseOrders as projection on longTailVendorManagement.PurchaseOrders;
  entity Invoices       as projection on longTailVendorManagement.Invoices;
  entity ActionLog      as projection on longTailVendorManagement.ActionLog;

  @cds.persistence.skip
  @readonly entity VendorStats {
    key ID                : Integer;
    // ── KPI tiles ──────────────────────────────────────────
    totalVendors          : Integer;       // fournisseurs avec blockingStatus = 'Actif'
    inactiveVendors       : Integer;       // inactivityMonths >= 12
    highRiskVendors       : Integer;       // riskScore > 60
    blockedPercentage     : Decimal(5,1);  // % Bloqués
    riskAmountAtRisk      : Decimal(15,2); // somme totalPOAmount des fournisseurs Élevé
    // ── Distribution pour MicroCharts ──────────────────────
    activeCount           : Integer;       // blockingStatus = 'Actif'
    blockedCount          : Integer;       // blockingStatus = 'Bloqué'
    closureCount          : Integer;       // blockingStatus = 'En cours de clôture'
    lowRiskCount          : Integer;       // riskScore 0-30
    mediumRiskCount       : Integer;       // riskScore 31-60
    inactivity0to6        : Integer;       // inactivityMonths < 6
    inactivity6to12       : Integer;       // inactivityMonths 6-11
    inactivity12plus      : Integer;       // inactivityMonths >= 12
  }
}
