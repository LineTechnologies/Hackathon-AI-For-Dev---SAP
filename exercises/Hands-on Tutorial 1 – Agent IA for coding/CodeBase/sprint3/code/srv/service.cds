using { longTailVendorManagement } from '../db/schema.cds';

service longTailVendorManagementSrv {
  @odata.draft.enabled
  entity Vendors as projection on longTailVendorManagement.Vendors;
  entity PurchaseOrders as projection on longTailVendorManagement.PurchaseOrders;
  entity Invoices as projection on longTailVendorManagement.Invoices;

  @cds.persistence.skip
  @readonly entity VendorStats {
    key ID               : Integer;
    totalVendors         : Integer;
    inactiveVendors      : Integer;
    highRiskVendors      : Integer;
    blockedPercentage    : Decimal(5,1);
  }
}