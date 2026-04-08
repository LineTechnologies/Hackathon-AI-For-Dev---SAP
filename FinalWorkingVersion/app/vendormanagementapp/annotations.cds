using { longTailVendorManagementSrv } from '../../srv/service.cds';

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #vendorName: {
  Value: vendorName,
  Title: '{i18n>vendor_name}',
};
annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #riskStatus: {
  Value: riskStatus,
  Title: '{i18n>vendor_risk_status}',
  Criticality: riskScoreCriticality
};
annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #blockingStatus: {
  Value: blockingStatus,
  Title: '{i18n>vendor_blocking_status}'
};
annotate longTailVendorManagementSrv.Vendors with @UI.FieldGroup #HeaderDetails: {
  $Type: 'UI.FieldGroupType',
  Data: [
    { $Type: 'UI.DataField', Value: country },
    { $Type: 'UI.DataField', Value: category }
  ]
};
annotate longTailVendorManagementSrv.Vendors with @UI.HeaderFacets: [
  { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#vendorName',     ID: 'VendorName' },
  { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#HeaderDetails', ID: 'HeaderDetails', Label: '{i18n>facet_general}' },
  { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#riskStatus',     ID: 'RiskStatus' },
  { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#blockingStatus', ID: 'BlockingStatus' }
];
annotate longTailVendorManagementSrv.Vendors with @UI.HeaderInfo: {
  TypeName: '{i18n>vendor_title}',
  TypeNamePlural: '{i18n>vendor_title_plural}',
  Title: { Value: vendorName }
};
annotate longTailVendorManagementSrv.Vendors with {
  ID                  @UI.Hidden;
  inactivityCriticality @UI.Hidden;
  riskScoreCriticality  @UI.Hidden;
  blockVendor_ac      @UI.Hidden;
  unblockVendor_ac    @UI.Hidden;
  requestClosure_ac   @UI.Hidden;
  pendingAction       @Common.Label: '{i18n>vendor_pending_action}'
};
annotate longTailVendorManagementSrv.Vendors with {
  vendorID         @Common.Label: '{i18n>vendor_id}';
  vendorName       @Common.Label: '{i18n>vendor_name}';
  country          @Common.Label: '{i18n>vendor_country}';
  category         @Common.Label: '{i18n>vendor_category}';
  blockingStatus   @Common.Label: '{i18n>vendor_blocking_status}';
  lastPODate       @Common.Label: '{i18n>vendor_last_po_date}';
  lastInvoiceDate  @Common.Label: '{i18n>vendor_last_invoice_date}';
  totalPOAmount    @Common.Label: '{i18n>vendor_total_po_amount}';
  inactivityMonths @Common.Label: '{i18n>vendor_inactivity_months}';
  riskScore        @Common.Label: '{i18n>vendor_risk_score}';
  riskStatus       @Common.Label: '{i18n>vendor_risk_status}';
  PurchaseOrders   @Common.Label: '{i18n>vendor_purchase_orders}';
  Invoices         @Common.Label: '{i18n>vendor_invoices}';
  address          @Common.Label: '{i18n>vendor_address}';
  taxNumber        @Common.Label: '{i18n>vendor_tax_number}';
  bankData         @Common.Label: '{i18n>vendor_bank_data}';
  accountManager   @Common.Label: '{i18n>vendor_account_manager}';
  paymentDelayAvg  @Common.Label: '{i18n>vendor_payment_delay}';
  deliveryDelayAvg @Common.Label: '{i18n>vendor_delivery_delay}'
};
annotate longTailVendorManagementSrv.Vendors with {
  ID @Common.Text: { $value: vendorID, ![@UI.TextArrangement]: #TextOnly };
};
annotate longTailVendorManagementSrv.Vendors with @UI.SelectionFields: [
  country,
  category,
  blockingStatus,
  lastPODate,
  inactivityMonths,
  riskStatus
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
  { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#InactivityMonths', Label: '{i18n>vendor_inactivity_months}' },
  { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#RiskScore', Label: '{i18n>vendor_risk_score}' },
  { $Type: 'UI.DataField', Value: riskStatus },
  // ── Actions métier (boutons dans la toolbar du List Report) ────────────────
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.blockVendor',
    Label : '{i18n>action_block}',
    ![@UI.Importance]: #High
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.unblockVendor',
    Label : '{i18n>action_unblock}',
    ![@UI.Importance]: #High
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.requestClosure',
    Label : '{i18n>action_request_closure}',
    ![@UI.Importance]: #High
  },
];

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #InactivityMonths: {
  Value: inactivityMonths,
  Title: '{i18n>vendor_inactivity_months}',
  Criticality: inactivityCriticality
};

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #RiskScore: {
  Value: riskScore,
  Title: '{i18n>vendor_risk_score}',
  Criticality: riskScoreCriticality
};

annotate longTailVendorManagementSrv.Vendors with @UI.PresentationVariant: {
  SortOrder: [
    { $Type: 'Common.SortOrderType', Property: lastPODate,      Descending: false },
    { $Type: 'Common.SortOrderType', Property: lastInvoiceDate, Descending: false }
  ],
  Visualizations: ['@UI.LineItem']
};

// ── OperationAvailable ────────────────────────────────────────────────────────
// Valeur statique `true` : le List Report utilise $select strict et exclut les
// champs @UI.Hidden du résultat → un $Path sur un champ virtuel caché donne
// undefined (falsy) → bouton toujours grisé. Le serveur valide côté back-end.
annotate longTailVendorManagementSrv.Vendors with actions {
  blockVendor      @Core.OperationAvailable: true;
  unblockVendor    @Core.OperationAvailable: true;
  requestClosure   @Core.OperationAvailable: true;
};

// ── Boutons actions dans l'en-tête de l'Object Page ───────────────────────────
// ![@UI.Hidden]: { $Path: '..._hide' } : caché quand le champ vaut true
// Les champs _hide sont des virtuels calculés côté CAP selon blockingStatus :
//   Bloqué          → Débloquer visible, les deux autres cachés
//   En cours de clôture → Bloquer visible, les deux autres cachés
//   Actif           → Bloquer + Demande de clôture visibles, Débloquer caché
annotate longTailVendorManagementSrv.Vendors with @UI.Identification: [
  { Value: vendorID },
  {
    $Type         : 'UI.DataFieldForAction',
    Action        : 'longTailVendorManagementSrv.blockVendor',
    Label         : '{i18n>action_block}',
    ![@UI.Hidden] : { $Path: 'blockVendor_hide' }
  },
  {
    $Type         : 'UI.DataFieldForAction',
    Action        : 'longTailVendorManagementSrv.unblockVendor',
    Label         : '{i18n>action_unblock}',
    ![@UI.Hidden] : { $Path: 'unblockVendor_hide' }
  },
  {
    $Type         : 'UI.DataFieldForAction',
    Action        : 'longTailVendorManagementSrv.requestClosure',
    Label         : '{i18n>action_request_closure}',
    ![@UI.Hidden] : { $Path: 'requestClosure_hide' }
  }
];

annotate longTailVendorManagementSrv.Vendors with @UI.SelectionVariant #Inactive: {
  Text: '{i18n>list_title}',
  SelectOptions: [{
    PropertyName: inactivityMonths,
    Ranges: [{ Sign: #I, Option: #GT, Low: 12 }]
  }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  status  @Common.Label: '{i18n>chart_dimension_status}';
  poMonth @Common.Label: '{i18n>chart_dimension_month}' @Analytics.Dimension: true @Aggregation.default: #NONE
};
annotate longTailVendorManagementSrv.PurchaseOrders with @Aggregation.ApplySupported: {
  $Type                 : 'Aggregation.ApplySupportedType',
  Transformations       : ['aggregate', 'groupby'],
  PropertyRestrictions  : true,
  GroupableProperties   : [poMonth],
  AggregatableProperties: [{
    $Type   : 'Aggregation.AggregatablePropertyType',
    Property: totalPOAmount
  }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with @Analytics.AggregatedProperty #totalPOAmountSum: {
  $Type               : 'Analytics.AggregatedPropertyType',
  Name                : 'totalPOAmountSum',
  AggregationMethod   : 'sum',
  AggregatableProperty: totalPOAmount
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.DataPoint #monthlyAmount: {
  Value: totalPOAmount,
  Title: '{i18n>chart_po_amount}'
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Chart #monthlyPO: {
  Title              : '{i18n>chart_monthly_po_evolution}',
  ChartType          : #Column,
  Dimensions         : [poMonth],
  DimensionAttributes: [{
    $Type    : 'UI.ChartDimensionAttributeType',
    Dimension: poMonth,
    Role     : #Category
  }],
  DynamicMeasures    : ['@Analytics.AggregatedProperty#totalPOAmountSum'],
  MeasureAttributes  : [{
    $Type         : 'UI.ChartMeasureAttributeType',
    DynamicMeasure: '@Analytics.AggregatedProperty#totalPOAmountSum',
    Role          : #Axis1
  }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.PresentationVariant #chartPV: {
  Visualizations: ['@UI.Chart#monthlyPO'],
  SortOrder     : [{ $Type: 'Common.SortOrderType', Property: poMonth, Descending: false }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.LineItem #purchaseOrdersSection: [
  { $Type: 'UI.DataField', Value: purchaseOrderID },
  { $Type: 'UI.DataField', Value: lastPODate },
  { $Type: 'UI.DataField', Value: totalPOAmount },
  { $Type: 'UI.DataField', Value: status }
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.PresentationVariant #purchaseOrdersSection: {
  SortOrder    : [{ $Type: 'Common.SortOrderType', Property: lastPODate, Descending: true }],
  MaxItems     : 10,
  Visualizations: ['@UI.LineItem#purchaseOrdersSection']
};

annotate longTailVendorManagementSrv.Invoices with {
  totalAmount   @Common.Label: '{i18n>invoice_amount}';
  paymentStatus @Common.Label: '{i18n>invoice_payment_status}';
  paymentDelay  @Common.Label: '{i18n>invoice_delay}'
};
annotate longTailVendorManagementSrv.Invoices with @UI.LineItem #invoicesSection: [
  { $Type: 'UI.DataField', Value: invoiceID },
  { $Type: 'UI.DataField', Value: lastInvoiceDate },
  { $Type: 'UI.DataField', Value: totalAmount },
  { $Type: 'UI.DataField', Value: paymentStatus },
  { $Type: 'UI.DataField', Value: paymentDelay }
];
annotate longTailVendorManagementSrv.Invoices with @UI.PresentationVariant #invoicesSection: {
  SortOrder    : [{ $Type: 'Common.SortOrderType', Property: lastInvoiceDate, Descending: true }],
  MaxItems     : 10,
  Visualizations: ['@UI.LineItem#invoicesSection']
};


annotate longTailVendorManagementSrv.Vendors with @UI.FieldGroup #GeneralData: {
  $Type: 'UI.FieldGroupType',
  Data: [
    { $Type: 'UI.DataField', Value: address },
    { $Type: 'UI.DataField', Value: taxNumber },
    { $Type: 'UI.DataField', Value: bankData },
    { $Type: 'UI.DataField', Value: accountManager }
  ]
};
annotate longTailVendorManagementSrv.Vendors with @UI.FieldGroup #ActivityScore: {
  $Type: 'UI.FieldGroupType',
  Data: [
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#InactivityMonths', Label: '{i18n>vendor_inactivity_months}' },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#RiskScore',        Label: '{i18n>vendor_risk_score}' },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: lastInvoiceDate },
    { $Type: 'UI.DataField', Value: totalPOAmount },
    { $Type: 'UI.DataField', Value: paymentDelayAvg },
    { $Type: 'UI.DataField', Value: deliveryDelayAvg }
  ]
};
annotate longTailVendorManagementSrv.Vendors with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'generalDataSection',    Label: '{i18n>facet_general}',         Target: '@UI.FieldGroup#GeneralData' },
  { $Type: 'UI.ReferenceFacet', ID: 'activityScoreSection',  Label: '{i18n>facet_activity_score}',  Target: '@UI.FieldGroup#ActivityScore' },
  { $Type: 'UI.ReferenceFacet', ID: 'purchaseOrdersSection', Label: '{i18n>facet_purchase_orders}', Target: 'PurchaseOrders/@UI.PresentationVariant#purchaseOrdersSection' },
  { $Type: 'UI.ReferenceFacet', ID: 'invoicesSection',       Label: '{i18n>facet_invoices}',        Target: 'Invoices/@UI.PresentationVariant#invoicesSection' },
  { $Type: 'UI.ReferenceFacet', ID: 'chartSection',          Label: '{i18n>facet_charts}',          Target: 'PurchaseOrders/@UI.PresentationVariant#chartPV' },
  { $Type: 'UI.ReferenceFacet', ID: 'actionLogSection',      Label: '{i18n>facet_action_history}',  Target: 'ActionLogs/@UI.PresentationVariant#actionLog' }
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
  Title: '{i18n>vendor_id}',
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#vendorID', ID: 'VendorID' }
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.HeaderInfo: {
  TypeName: '{i18n>po_title}',
  TypeNamePlural: '{i18n>po_title_plural}',
  Title: { Value: purchaseOrderID }
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  ID @UI.Hidden
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Identification: [{ Value: purchaseOrderID }];
annotate longTailVendorManagementSrv.PurchaseOrders with {
  purchaseOrderID @Common.Label: '{i18n>po_id}';
  vendorID        @Common.Label: '{i18n>vendor_id}';
  lastPODate      @Common.Label: '{i18n>po_last_date}';
  totalPOAmount   @Common.Label: '{i18n>po_amount}' @Analytics.Measure: true @Aggregation.default: #SUM;
  vendors         @Common.Label: '{i18n>po_vendor}'
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  ID      @Common.Text: { $value: purchaseOrderID, ![@UI.TextArrangement]: #TextOnly };
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
    { $Type: 'UI.DataField', Label: '{i18n>po_vendor}', Value: vendors_ID }
];
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: purchaseOrderID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: totalPOAmount },
    { $Type: 'UI.DataField', Label: '{i18n>po_vendor}', Value: vendors_ID }
]};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: '{i18n>facet_general_info}', Target: '@UI.FieldGroup#Main' }
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
  Title: '{i18n>vendor_id}',
};
annotate longTailVendorManagementSrv.Invoices with @UI.HeaderFacets: [
 { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#vendorID', ID: 'VendorID' }
];
annotate longTailVendorManagementSrv.Invoices with @UI.HeaderInfo: {
  TypeName: '{i18n>invoice_title}',
  TypeNamePlural: '{i18n>invoice_title_plural}',
  Title: { Value: invoiceID }
};
annotate longTailVendorManagementSrv.Invoices with {
  ID @UI.Hidden
};
annotate longTailVendorManagementSrv.Invoices with @UI.Identification: [{ Value: invoiceID }];
annotate longTailVendorManagementSrv.Invoices with {
  invoiceID       @Common.Label: '{i18n>invoice_id}';
  vendorID        @Common.Label: '{i18n>vendor_id}';
  lastInvoiceDate @Common.Label: '{i18n>invoice_last_date}';
  vendors         @Common.Label: '{i18n>invoice_vendor}'
};
annotate longTailVendorManagementSrv.Invoices with {
  ID      @Common.Text: { $value: invoiceID, ![@UI.TextArrangement]: #TextOnly };
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
    { $Type: 'UI.DataField', Label: '{i18n>invoice_vendor}', Value: vendors_ID }
];
annotate longTailVendorManagementSrv.Invoices with @UI.FieldGroup #Main: {
  $Type: 'UI.FieldGroupType', Data: [
    { $Type: 'UI.DataField', Value: ID },
    { $Type: 'UI.DataField', Value: invoiceID },
    { $Type: 'UI.DataField', Value: vendorID },
    { $Type: 'UI.DataField', Value: lastInvoiceDate },
    { $Type: 'UI.DataField', Label: '{i18n>invoice_vendor}', Value: vendors_ID }
]};
annotate longTailVendorManagementSrv.Invoices with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'Main', Label: '{i18n>facet_general_info}', Target: '@UI.FieldGroup#Main' }
];

// ── ActionLog ─────────────────────────────────────────────────────────────────
annotate longTailVendorManagementSrv.ActionLog with {
  action     @Common.Label: '{i18n>actionlog_action}';
  actionDate @Common.Label: '{i18n>actionlog_date}';
  user       @Common.Label: '{i18n>actionlog_user}';
  reason     @Common.Label: '{i18n>actionlog_reason}'
};
annotate longTailVendorManagementSrv.ActionLog with @UI.LineItem #actionLog: [
  { $Type: 'UI.DataField', Value: actionDate },
  { $Type: 'UI.DataField', Value: action },
  { $Type: 'UI.DataField', Value: user },
  { $Type: 'UI.DataField', Value: reason }
];
annotate longTailVendorManagementSrv.ActionLog with @UI.PresentationVariant #actionLog: {
  SortOrder    : [{ $Type: 'Common.SortOrderType', Property: actionDate, Descending: true }],
  Visualizations: ['@UI.LineItem#actionLog']
};

// ── KPI Header ────────────────────────────────────────────────────────────────
annotate longTailVendorManagementSrv.VendorStats with {
  totalVendors      @Common.Label: '{i18n>kpi_active_vendors}';
  inactiveVendors   @Common.Label: '{i18n>kpi_inactive}';
  highRiskVendors   @Common.Label: '{i18n>kpi_high_risk}';
  blockedPercentage @Common.Label: '{i18n>kpi_blocked_pct}'
};

// DataPoints declared separately so @UI.KPI can reference them via qualifier path
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #TotalVendors: {
  Value: totalVendors, Title: '{i18n>kpi_active_vendors}', Visualization: #Number
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #InactiveVendors: {
  Value: inactiveVendors, Title: '{i18n>kpi_inactive}', Visualization: #Number, Criticality: { $edmJson: { $Int: 1 } }
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #HighRiskVendors: {
  Value: highRiskVendors, Title: '{i18n>kpi_high_risk}', Visualization: #Number, Criticality: { $edmJson: { $Int: 1 } }
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #BlockedPct: {
  Value: blockedPercentage, Title: '{i18n>kpi_blocked_pct}', Visualization: #Number
};

// Label for syncFromS4 action (moved here from srv/service.cds)
annotate longTailVendorManagementSrv.syncFromS4 with @Common.Label: '{i18n>action_sync_s4}';

// @UI.KPI tiles are not used — KPI rendering is handled by the
// ListReportExtension controller extension + KPIHeader.fragment.xml.
