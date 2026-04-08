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
                            setTimeout(function () { that._injectKPIHeader(); }, 300);
                        }
                    });
                } catch (e) {
                    console.warn("[KPI Header] Router attach failed:", e);
                }
            },

            _injectKPIHeader: function () {
                var oFilterBar = sap.ui.getCore().byId(
                    "vendormanagementapp::VendorsList--fe::FilterBar::Vendors"
                );
                if (!oFilterBar) {
                    console.warn("[KPI Header] FilterBar not found; retrying in 500ms");
                    var that = this;
                    this._kpiInjected = false;
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

                var that = this;

                oModel
                    .bindList("/VendorStats")
                    .requestContexts(0, 1)
                    .then(function (aContexts) {
                        var oRaw = aContexts[0] ? aContexts[0].getObject() : {};

                        // Préchargement de la librairie microchart avant le parsing du fragment
                        sap.ui.require(
                            [
                                "sap/ui/core/Fragment",
                                "sap/ui/model/json/JSONModel",
                                "sap/suite/ui/microchart/library"
                            ],
                            function (Fragment, JSONModel /*, mcLib */) {
                                var oKPIModel = new JSONModel({
                                    // ── KPI tiles ──────────────────────────
                                    totalVendors:      oRaw.totalVendors      || 0,
                                    inactiveVendors:   oRaw.inactiveVendors   || 0,
                                    highRiskVendors:   oRaw.highRiskVendors   || 0,
                                    blockedPercentage: oRaw.blockedPercentage || 0,
                                    riskAmountAtRisk:  oRaw.riskAmountAtRisk  || 0,
                                    // ── Distributions pour MicroCharts ─────
                                    activeCount:       oRaw.activeCount       || 0,
                                    blockedCount:      oRaw.blockedCount      || 0,
                                    closureCount:      oRaw.closureCount      || 0,
                                    lowRiskCount:      oRaw.lowRiskCount      || 0,
                                    mediumRiskCount:   oRaw.mediumRiskCount   || 0,
                                    inactivity0to6:    oRaw.inactivity0to6    || 0,
                                    inactivity6to12:   oRaw.inactivity6to12   || 0,
                                    inactivity12plus:  oRaw.inactivity12plus  || 0
                                });

                                Fragment.load({
                                    id:   "vendormanagementapp--kpiFrag",
                                    name: "vendormanagementapp.ext.KPIHeader"
                                }).then(function (oFrag) {
                                    oFrag.setModel(oKPIModel, "kpi");
                                    oFrag.setModel(that.getModel("i18n"), "i18n");
                                    oDynHeader.addContent(oFrag);
                                    oDynPage.setHeaderExpanded(true);

                                    // Câblage des événements MicroChart après injection dans le DOM
                                    // (les attributs press/selectionChanged sont absents du XML car
                                    //  ils nécessitent un contexte contrôleur pour se résoudre)
                                    that._wireChartHandlers(oFilterBar);

                                    console.log("[KPI Header] injected successfully");
                                }).catch(function (e) {
                                    console.warn("[KPI Header] Fragment load error:", e);
                                });
                            },
                            function (oErr) {
                                // Fallback : microchart indisponible, on charge quand même les tiles
                                console.warn("[KPI Header] microchart library unavailable:", oErr);
                                sap.ui.require(
                                    ["sap/ui/core/Fragment", "sap/ui/model/json/JSONModel"],
                                    function (Fragment, JSONModel) {
                                        var oKPIModel = new JSONModel({
                                            totalVendors:     oRaw.totalVendors     || 0,
                                            inactiveVendors:  oRaw.inactiveVendors  || 0,
                                            highRiskVendors:  oRaw.highRiskVendors  || 0,
                                            blockedPercentage:oRaw.blockedPercentage|| 0,
                                            riskAmountAtRisk: oRaw.riskAmountAtRisk || 0
                                        });
                                        Fragment.load({
                                            id:   "vendormanagementapp--kpiFrag",
                                            name: "vendormanagementapp.ext.KPIHeader"
                                        }).then(function (oFrag) {
                                            oFrag.setModel(oKPIModel, "kpi");
                                            oFrag.setModel(that.getModel("i18n"), "i18n");
                                            oDynHeader.addContent(oFrag);
                                            oDynPage.setHeaderExpanded(true);
                                            that._wireChartHandlers(oFilterBar);
                                        }).catch(function (e2) {
                                            console.warn("[KPI Header] Fallback fragment error:", e2);
                                        });
                                    }
                                );
                            }
                        );
                    })
                    .catch(function (e) {
                        console.warn("[KPI Header] VendorStats fetch error:", e);
                    });
            },

            /**
             * Câble :
             *  1. Le bouton engrenage → Popover pour afficher/masquer les tuiles KPI
             *  2. Les InteractiveBarCharts → filtre FilterBar (statut) ou toast (virtuels)
             */
            _wireChartHandlers: function (oFilterBar) {
                var sFragId = "vendormanagementapp--kpiFrag";
                var oI18n   = this.getModel("i18n");
                function t(sKey) { return oI18n ? oI18n.getProperty(sKey) : sKey; }

                // ── 1. Bouton settings → Popover de sélection des KPIs ────────────────
                var oSettingsBtn = sap.ui.getCore().byId(sFragId + "--kpiSettingsBtn");
                if (oSettingsBtn) {
                    var aTilesConfig = [
                        { id: sFragId + "--kpiTileRiskAmount", label: t("kpi_tile_amount_at_risk"), checked: true  },
                        { id: sFragId + "--kpiTileActive",     label: t("kpi_tile_active"),         checked: false },
                        { id: sFragId + "--kpiTileInactive",   label: t("kpi_tile_inactive"),       checked: false }
                    ];
                    var oPopover = null;

                    oSettingsBtn.attachPress(function () {
                        if (!oPopover) {
                            var aItems = aTilesConfig.map(function (cfg) {
                                return new sap.m.CheckBox({
                                    text:     cfg.label,
                                    selected: cfg.checked,
                                    select: (function (tileId, tileCfg) {
                                        return function (oEv) {
                                            tileCfg.checked = oEv.getParameter("selected");
                                            var oTile = sap.ui.getCore().byId(tileId);
                                            if (oTile) { oTile.setVisible(tileCfg.checked); }
                                        };
                                    })(cfg.id, cfg)
                                }).addStyleClass("sapUiTinyMarginBottom");
                            });
                            oPopover = new sap.m.Popover({
                                title:     t("kpi_popover_title"),
                                placement: "Bottom",
                                content:   [ new sap.m.VBox({ items: aItems }).addStyleClass("sapUiSmallMargin") ]
                            });
                        }
                        oPopover.openBy(oSettingsBtn);
                    });
                }

                // ── 2. Helper : filtre FilterBar (champs persistés) ───────────────────
                function applyFilter(sProperty, sValue) {
                    try {
                        var oConditions = {};
                        oConditions[sProperty] = [{
                            operator: "EQ", values: [sValue], isEmpty: false, validated: "NotValidated"
                        }];
                        oFilterBar.setFilterConditions(oConditions);
                        if (typeof oFilterBar.triggerSearch === "function") { oFilterBar.triggerSearch(); }
                    } catch (e) {
                        console.warn("[KPI Chart] applyFilter failed:", e);
                    }
                }

                // ── 3. Bar statut de blocage → filtre sur blockingStatus ──────────────
                var oStatusChart = sap.ui.getCore().byId(sFragId + "--statusBarChart");
                if (oStatusChart && typeof oStatusChart.attachSelectionChanged === "function") {
                    oStatusChart.attachSelectionChanged(function (oEvent) {
                        var aBars = oEvent.getParameter("selectedBars");
                        if (aBars && aBars.length) { applyFilter("blockingStatus", aBars[0].getLabel()); }
                    });
                }

                // ── 4. Bar niveaux de risque → toast (champ virtuel) ─────────────────
                var oRiskChart = sap.ui.getCore().byId(sFragId + "--riskBarChart");
                if (oRiskChart && typeof oRiskChart.attachSelectionChanged === "function") {
                    oRiskChart.attachSelectionChanged(function (oEvent) {
                        var aBars = oEvent.getParameter("selectedBars");
                        if (aBars && aBars.length) {
                            sap.ui.require(["sap/m/MessageToast"], function (T) {
                                T.show(t("filter_risk_toast").replace("{0}", aBars[0].getLabel()));
                            });
                        }
                    });
                }

                // ── 5. Bar inactivité → toast (champ virtuel) ────────────────────────
                var oInactChart = sap.ui.getCore().byId(sFragId + "--inactivityBarChart");
                if (oInactChart && typeof oInactChart.attachSelectionChanged === "function") {
                    oInactChart.attachSelectionChanged(function (oEvent) {
                        var aBars = oEvent.getParameter("selectedBars");
                        if (aBars && aBars.length) {
                            sap.ui.require(["sap/m/MessageToast"], function (T) {
                                T.show(t("filter_inactivity_toast").replace("{0}", aBars[0].getLabel()));
                            });
                        }
                    });
                }
            }
        });
    }
);
