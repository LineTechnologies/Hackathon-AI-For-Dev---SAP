sap.ui.define(
    ["sap/fe/core/AppComponent"],
    function (AppComponent) {
        "use strict";

        return AppComponent.extend("vendormanagementapp.Component", {
            metadata: {
                manifest: "json"
            },

            init: function () {
                AppComponent.prototype.init.apply(this, arguments);

                var that = this;
                try {
                    this.getRouter().attachRouteMatched(function (oEvent) {
                        if (oEvent.getParameter("name") === "VendorsList" && !that._kpiInjected) {
                            that._kpiInjected = true;
                            // Defer until after FE finishes rendering the DynamicPage
                            setTimeout(function () { that._injectKPIHeader(); }, 300);
                        }
                    });
                } catch (e) {
                    console.warn("[KPI Header] Router attach failed:", e);
                }
            },

            _injectKPIHeader: function () {
                // Locate the DynamicPage by traversing up from the FilterBar
                // (whose ID is stable and visible in the browser console)
                var oFilterBar = sap.ui.getCore().byId(
                    "vendormanagementapp::VendorsList--fe::FilterBar::Vendors"
                );
                if (!oFilterBar) {
                    console.warn("[KPI Header] FilterBar not found; retrying in 500ms");
                    var that = this;
                    this._kpiInjected = false; // allow one retry
                    setTimeout(function () {
                        that._kpiInjected = true;
                        that._injectKPIHeader();
                    }, 500);
                    return;
                }

                var oCtrl = oFilterBar.getParent();
                var oDynPage = null;
                while (oCtrl) {
                    if (oCtrl.isA && oCtrl.isA("sap.f.DynamicPage")) { oDynPage = oCtrl; break; }
                    oCtrl = oCtrl.getParent();
                }

                if (!oDynPage || !oDynPage.getHeader()) {
                    console.warn("[KPI Header] DynamicPage or its header not found");
                    return;
                }

                var oDynHeader = oDynPage.getHeader();
                var oModel    = this.getModel();
                if (!oModel) { console.warn("[KPI Header] OData model not ready"); return; }

                oModel
                    .bindList("/VendorStats")
                    .requestContexts(0, 1)
                    .then(function (aContexts) {
                        var oRaw = aContexts[0] ? aContexts[0].getObject() : {};

                        sap.ui.require(
                            ["sap/ui/core/Fragment", "sap/ui/model/json/JSONModel"],
                            function (Fragment, JSONModel) {
                                var oKPIModel = new JSONModel({
                                    totalVendors:      oRaw.totalVendors      || 0,
                                    inactiveVendors:   oRaw.inactiveVendors   || 0,
                                    highRiskVendors:   oRaw.highRiskVendors   || 0,
                                    blockedPercentage: oRaw.blockedPercentage || 0
                                });

                                Fragment.load({
                                    id:   "vendormanagementapp--kpiFrag",
                                    name: "vendormanagementapp.ext.KPIHeader"
                                }).then(function (oFrag) {
                                    oFrag.setModel(oKPIModel, "kpi");
                                    oDynHeader.addContent(oFrag);
                                    oDynPage.setHeaderExpanded(true);
                                    console.log("[KPI Header] KPI tiles injected successfully");
                                }).catch(function (e) {
                                    console.warn("[KPI Header] Fragment load error:", e);
                                });
                            }
                        );
                    })
                    .catch(function (e) {
                        console.warn("[KPI Header] VendorStats fetch error:", e);
                    });
            }
        });
    }
);
