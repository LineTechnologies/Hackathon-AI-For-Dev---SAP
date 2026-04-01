namespace longTailVendorManagement;

entity Vendors {
  key ID: UUID;
  vendorID: String(50) @assert.unique @mandatory;
  vendorName: String(100);
  country: String(3);
  category: String(50);
  blockingStatus: String(20);
  lastPODate: Date;
  lastInvoiceDate: Date;
  totalPOAmount: Decimal(15,2);
  virtual inactivityMonths: Integer;
  virtual inactivityCriticality: Integer;
  virtual riskScore: Integer;
  virtual riskStatus: String(20);
  virtual riskScoreCriticality: Integer;
  PurchaseOrders: Association to many PurchaseOrders on PurchaseOrders.vendors = $self;
  Invoices: Association to many Invoices on Invoices.vendors = $self;
}

entity PurchaseOrders {
  key ID: UUID;
  purchaseOrderID: String(50) @assert.unique @mandatory;
  vendorID: String(50);
  lastPODate: Date;
  totalPOAmount: Decimal;
  vendors: Association to Vendors;
}

entity Invoices {
  key ID: UUID;
  invoiceID: String(50) @assert.unique @mandatory;
  vendorID: String(50);
  lastInvoiceDate: Date;
  vendors: Association to Vendors;
}
