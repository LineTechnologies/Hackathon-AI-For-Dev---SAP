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
  address: String(200);
  taxNumber: String(50);
  bankData: String(100);
  accountManager: String(100);
  virtual inactivityMonths: Integer;
  virtual inactivityCriticality: Integer;
  virtual riskScore: Integer;
  virtual riskStatus: String(20);
  virtual riskScoreCriticality: Integer;
  virtual paymentDelayAvg: Decimal(5,1);
  virtual deliveryDelayAvg: Decimal(5,1);
  PurchaseOrders: Composition of many PurchaseOrders on PurchaseOrders.vendors = $self;
  Invoices: Composition of many Invoices on Invoices.vendors = $self;
}

entity PurchaseOrders {
  key ID: UUID;
  purchaseOrderID: String(50) @assert.unique @mandatory;
  vendorID: String(50);
  lastPODate: Date;
  totalPOAmount: Decimal;
  plannedDeliveryDate: Date;
  deliveryDate: Date;
  status: String(20);
  poMonth: String(7);
  vendors: Association to Vendors;
}

entity Invoices {
  key ID: UUID;
  invoiceID: String(50) @assert.unique @mandatory;
  vendorID: String(50);
  lastInvoiceDate: Date;
  dueDate: Date;
  paymentDate: Date;
  totalAmount: Decimal(15,2);
  paymentStatus: String(20);
  paymentDelay: Integer;
  vendors: Composition of Vendors;
}
