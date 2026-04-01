using { longTailVendorManagementSrv } from '../../srv/service.cds';

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #vendorName: {
  Value: vendorName,
  Title: 'Vendor Name',
};
annotate longTailVendorManagementSrv.Vendors with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#vendorName', ID: 'VendorName' }
];
annotate longTailVendorManagementSrv.Vendors with @UI.HeaderInfo: {
  TypeName: 'Vendor',
  TypeNamePlural: 'Vendors',
  Title: { Value: vendorID }
};
annotate longTailVendorManagementSrv.Vendors with {
  ID @UI.Hidden;
  inactivityCriticality @UI.Hidden
};
annotate longTailVendorManagementSrv.Vendors with @UI.Identification: [{ Value: vendorID }];
annotate longTailVendorManagementSrv.Vendors with {
  vendorID @Common.Label: 'Vendor ID';
  vendorName @Common.Label: 'Vendor Name';
  country @Common.Label: 'Country';
  category @Common.Label: 'Category';
  blockingStatus @Common.Label: 'Blocking Status';
  lastPODate @Common.Label: 'Last PO Date';
  lastInvoiceDate @Common.Label: 'Last Invoice Date';
  totalPOAmount @Common.Label: 'Total PO Amount';
  inactivityMonths @Common.Label: 'Inactivity (months)';
  PurchaseOrders @Common.Label: 'Purchase Orders';
  Invoices @Common.Label: 'Invoices'
};
annotate longTailVendorManagementSrv.Vendors with {
  ID @Common.Text: { $value: vendorID, ![@UI.TextArrangement]: #TextOnly };
};
annotate longTailVendorManagementSrv.Vendors with @UI.SelectionFields: [
  country,
  category,
  blockingStatus,
  lastPODate,
  inactivityMonths
];
annotate longTailVendorManagementSrv.Vendors with @UI.LineItem: [
  { $Type: 'UI.DataField', Value: vendorID },
  { $Type: 'UI.DataField', Value: vendorName },
  { $Type: 'UI.DataField', Value: country },
  { $Type: 'UI.DataField', Value: category },
  { $Type: 'UI.DataField', Value: blockingStatus },
  { $Type: 'UI.DataField', Value: lastPODate },
  { $Type: 'UI.DataField', Value: lastInvoiceDate },
  { $Type: 'UI.DataField', Value: totalPOAmount },
  { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#InactivityMonths', Label: 'Inactivity (months)' }
];

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #InactivityMonths: {
  Value: inactivityMonths,
  Title: 'Inactivity (months)',
  Criticality: inactivityCriticality
};

annotate longTailVendorManagementSrv.Vendors with @UI.PresentationVariant: {
  SortOrder: [{ $Type: 'Common.SortOrderType', Property: inactivityMonths, Descending: true }],
  Visualizations: ['@UI.LineItem']
};

annotate longTailVendorManagementSrv.Vendors with @UI.SelectionVariant #Inactive: {
  Text: 'Fournisseurs inactifs',
  SelectOptions: [{
    PropertyName: inactivityMonths,
    Ranges: [{ Sign: #I, Option: #GT, Low: 12 }]
  }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.LineItem #purchaseOrdersSection: [
    { $Type: 'UI.DataField', Value: purchaseOrderID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: totalPOAmount }

  ];


annotate longTailVendorManagementSrv.Invoices with @UI.LineItem #invoicesSection: [
    { $Type: 'UI.DataField', Value: invoiceID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastInvoiceDate }

  ];


annotate longTailVendorManagementSrv.Vendors with @UI.Facets: [
  {
    $Type: 'UI.CollectionFacet',
    ID: 'vendorDetailsTab',
    Label: 'Vendor Details',
    Facets: [
      { $Type: 'UI.ReferenceFacet', ID: 'purchaseOrdersSection', Label: 'Purchase Orders', Target: 'PurchaseOrders/@UI.LineItem#purchaseOrdersSection' },
      { $Type: 'UI.ReferenceFacet', ID: 'invoicesSection', Label: 'Invoices', Target: 'Invoices/@UI.LineItem#invoicesSection' } ]
  }
];
annotate longTailVendorManagementSrv.PurchaseOrders with {
  vendors @Common.ValueList: {
    CollectionPath: 'Vendors',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: vendors_ID,
        ValueListProperty: 'ID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'vendorID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'vendorName'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'country'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'category'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'blockingStatus'
      },
    ],
  }
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.DataPoint #vendorID: {
  Value: vendorID,
  Title: 'Vendor ID',
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#vendorID', ID: 'VendorID' }
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.HeaderInfo: {
  TypeName: 'Purchase Order',
  TypeNamePlural: 'Purchase Orders',
  Title: { Value: purchaseOrderID }
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  ID @UI.Hidden
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Identification: [{ Value: purchaseOrderID }];
annotate longTailVendorManagementSrv.PurchaseOrders with {
  purchaseOrderID @Common.Label: 'Purchase Order ID';
  vendorID @Common.Label: 'Vendor ID';
  lastPODate @Common.Label: 'Last PO Date';
  totalPOAmount @Common.Label: 'Total PO Amount';
  vendors @Common.Label: 'Vendor'
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  ID @Common.Text: { $value: purchaseOrderID, ![@UI.TextArrangement]: #TextOnly };
  vendors @Common.Text: { $value: vendors.vendorID, ![@UI.TextArrangement]: #TextOnly };
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.SelectionFields: [
  vendors_ID
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: purchaseOrderID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: totalPOAmount },
    { $Type: 'UI.DataField', Label: 'Vendor', Value: vendors_ID }
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: purchaseOrderID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: totalPOAmount },
    { $Type: 'UI.DataField', Label: 'Vendor', Value: vendors_ID }
]};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: 'General Information', Target: '@UI.FieldGroup#Main' }
];
annotate longTailVendorManagementSrv.Invoices with {
  vendors @Common.ValueList: {
    CollectionPath: 'Vendors',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterInOut',
        LocalDataProperty: vendors_ID,
        ValueListProperty: 'ID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'vendorID'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'vendorName'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'country'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'category'
      },
      {
        $Type            : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty: 'blockingStatus'
      },
    ],
  }
};
annotate longTailVendorManagementSrv.Invoices with @UI.DataPoint #vendorID: {
  Value: vendorID,
  Title: 'Vendor ID',
};
annotate longTailVendorManagementSrv.Invoices with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#vendorID', ID: 'VendorID' }
];
annotate longTailVendorManagementSrv.Invoices with @UI.HeaderInfo: {
  TypeName: 'Invoice',
  TypeNamePlural: 'Invoices',
  Title: { Value: invoiceID }
};
annotate longTailVendorManagementSrv.Invoices with {
  ID @UI.Hidden
};
annotate longTailVendorManagementSrv.Invoices with @UI.Identification: [{ Value: invoiceID }];
annotate longTailVendorManagementSrv.Invoices with {
  invoiceID @Common.Label: 'Invoice ID';
  vendorID @Common.Label: 'Vendor ID';
  lastInvoiceDate @Common.Label: 'Last Invoice Date';
  vendors @Common.Label: 'Vendor'
};
annotate longTailVendorManagementSrv.Invoices with {
  ID @Common.Text: { $value: invoiceID, ![@UI.TextArrangement]: #TextOnly };
  vendors @Common.Text: { $value: vendors.vendorID, ![@UI.TextArrangement]: #TextOnly };
};
annotate longTailVendorManagementSrv.Invoices with @UI.SelectionFields: [
  vendors_ID
];
annotate longTailVendorManagementSrv.Invoices with @UI.LineItem: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: invoiceID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastInvoiceDate },
    { $Type: 'UI.DataField', Label: 'Vendor', Value: vendors_ID }
];
annotate longTailVendorManagementSrv.Invoices with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: invoiceID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastInvoiceDate },
    { $Type: 'UI.DataField', Label: 'Vendor', Value: vendors_ID }
]};
annotate longTailVendorManagementSrv.Invoices with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: 'General Information', Target: '@UI.FieldGroup#Main' }
];