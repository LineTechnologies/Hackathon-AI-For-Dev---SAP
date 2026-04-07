using { longTailVendorManagementSrv } from '../../srv/service.cds';

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #vendorName: {
  Value: vendorName,
  Title: 'Vendor Name',
};
annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #riskStatus: {
  Value: riskStatus,
  Title: 'Risk Status',
  Criticality: riskScoreCriticality
};
annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #blockingStatus: {
  Value: blockingStatus,
  Title: 'Blocking Status'
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
  { $Type: 'UI.ReferenceFacet', Target: '@UI.FieldGroup#HeaderDetails', ID: 'HeaderDetails', Label: 'Informations' },
  { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#riskStatus',     ID: 'RiskStatus' },
  { $Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#blockingStatus', ID: 'BlockingStatus' }
];
annotate longTailVendorManagementSrv.Vendors with @UI.HeaderInfo: {
  TypeName: 'Vendor',
  TypeNamePlural: 'Vendors',
  Title: { Value: vendorName }
};
annotate longTailVendorManagementSrv.Vendors with {
  ID                  @UI.Hidden;
  inactivityCriticality @UI.Hidden;
  riskScoreCriticality  @UI.Hidden;
  blockVendor_ac      @UI.Hidden;
  unblockVendor_ac    @UI.Hidden;
  requestClosure_ac   @UI.Hidden;
  pendingAction       @Common.Label: 'Action en attente'
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
  riskScore        @Common.Label: 'Risk Score';
  riskStatus       @Common.Label: 'Risk Status';
  PurchaseOrders @Common.Label: 'Purchase Orders';
  Invoices @Common.Label: 'Invoices';
  address @Common.Label: 'Adresse';
  taxNumber @Common.Label: 'N° Fiscal / SIRET';
  bankData @Common.Label: 'Données bancaires';
  accountManager @Common.Label: 'Gestionnaire';
  paymentDelayAvg @Common.Label: 'Retard paiement moy. (j)';
  deliveryDelayAvg @Common.Label: 'Retard livraison moy. (j)'
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
  { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#InactivityMonths', Label: 'Inactivity (months)' },
  { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#RiskScore', Label: 'Risk Score' },
  { $Type: 'UI.DataField', Value: riskStatus },
  // ── Actions métier (boutons dans la toolbar du List Report) ────────────────
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.blockVendor',
    Label : 'Bloquer',
    ![@UI.Importance]: #High
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.unblockVendor',
    Label : 'Débloquer',
    ![@UI.Importance]: #High
  },
  {
    $Type : 'UI.DataFieldForAction',
    Action: 'longTailVendorManagementSrv.requestClosure',
    Label : 'Demande de clôture',
    ![@UI.Importance]: #High
  }
];

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #InactivityMonths: {
  Value: inactivityMonths,
  Title: 'Inactivity (months)',
  Criticality: inactivityCriticality
};

annotate longTailVendorManagementSrv.Vendors with @UI.DataPoint #RiskScore: {
  Value: riskScore,
  Title: 'Risk Score',
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
    Label         : 'Bloquer',
    ![@UI.Hidden] : { $Path: 'blockVendor_hide' }
  },
  {
    $Type         : 'UI.DataFieldForAction',
    Action        : 'longTailVendorManagementSrv.unblockVendor',
    Label         : 'Débloquer',
    ![@UI.Hidden] : { $Path: 'unblockVendor_hide' }
  },
  {
    $Type         : 'UI.DataFieldForAction',
    Action        : 'longTailVendorManagementSrv.requestClosure',
    Label         : 'Demande de clôture',
    ![@UI.Hidden] : { $Path: 'requestClosure_hide' }
  }
];

annotate longTailVendorManagementSrv.Vendors with @UI.SelectionVariant #Inactive: {
  Text: 'Fournisseurs inactifs',
  SelectOptions: [{
    PropertyName: inactivityMonths,
    Ranges: [{ Sign: #I, Option: #GT, Low: 12 }]
  }]
};
annotate longTailVendorManagementSrv.PurchaseOrders with {
  status  @Common.Label: 'Statut';
  poMonth @Common.Label: 'Mois' @Analytics.Dimension: true @Aggregation.default: #NONE
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
  Title: 'Montant PO'
};
annotate longTailVendorManagementSrv.PurchaseOrders with @UI.Chart #monthlyPO: {
  Title              : 'Évolution mensuelle des PO',
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
  totalAmount   @Common.Label: 'Montant';
  paymentStatus @Common.Label: 'Statut paiement';
  paymentDelay  @Common.Label: 'Retard (j)'
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
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#InactivityMonths', Label: 'Inactivité (mois)' },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#RiskScore',        Label: 'Score de risque' },
    { $Type: 'UI.DataField', Value: lastPODate },
    { $Type: 'UI.DataField', Value: lastInvoiceDate },
    { $Type: 'UI.DataField', Value: totalPOAmount },
    { $Type: 'UI.DataField', Value: paymentDelayAvg },
    { $Type: 'UI.DataField', Value: deliveryDelayAvg }
  ]
};
annotate longTailVendorManagementSrv.Vendors with @UI.Facets: [
  { $Type: 'UI.ReferenceFacet', ID: 'generalDataSection',   Label: 'Données générales',       Target: '@UI.FieldGroup#GeneralData' },
  { $Type: 'UI.ReferenceFacet', ID: 'activityScoreSection', Label: 'Activité & Score',        Target: '@UI.FieldGroup#ActivityScore' },
  { $Type: 'UI.ReferenceFacet', ID: 'purchaseOrdersSection', Label: 'Bons de Commande',       Target: 'PurchaseOrders/@UI.PresentationVariant#purchaseOrdersSection' },
  { $Type: 'UI.ReferenceFacet', ID: 'invoicesSection',       Label: 'Factures',               Target: 'Invoices/@UI.PresentationVariant#invoicesSection' },
  { $Type: 'UI.ReferenceFacet', ID: 'chartSection',          Label: 'Indicateurs graphiques', Target: 'PurchaseOrders/@UI.PresentationVariant#chartPV' },
  { $Type: 'UI.ReferenceFacet', ID: 'actionLogSection',      Label: 'Historique des actions', Target: 'ActionLogs/@UI.PresentationVariant#actionLog' }
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
  totalPOAmount @Common.Label: 'Total PO Amount' @Analytics.Measure: true @Aggregation.default: #SUM;
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

// ── ActionLog ─────────────────────────────────────────────────────────────────
annotate longTailVendorManagementSrv.ActionLog with {
  action     @Common.Label: 'Action';
  actionDate @Common.Label: 'Date';
  user       @Common.Label: 'Utilisateur';
  reason     @Common.Label: 'Motif'
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
  totalVendors      @Common.Label: 'Fournisseurs actifs';
  inactiveVendors   @Common.Label: 'Inactifs';
  highRiskVendors   @Common.Label: 'Risque élevé';
  blockedPercentage @Common.Label: '% Bloqués'
};

// DataPoints declared separately so @UI.KPI can reference them via qualifier path
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #TotalVendors: {
  Value: totalVendors, Title: 'Fournisseurs actifs', Visualization: #Number
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #InactiveVendors: {
  Value: inactiveVendors, Title: 'Inactifs', Visualization: #Number, Criticality: { $edmJson: { $Int: 1 } }
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #HighRiskVendors: {
  Value: highRiskVendors, Title: 'Risque élevé', Visualization: #Number, Criticality: { $edmJson: { $Int: 1 } }
};
annotate longTailVendorManagementSrv.VendorStats with @UI.DataPoint #BlockedPct: {
  Value: blockedPercentage, Title: '% Bloqués', Visualization: #Number
};

// @UI.KPI tiles are not used — KPI rendering is handled by the
// ListReportExtension controller extension + KPIHeader.fragment.xml.