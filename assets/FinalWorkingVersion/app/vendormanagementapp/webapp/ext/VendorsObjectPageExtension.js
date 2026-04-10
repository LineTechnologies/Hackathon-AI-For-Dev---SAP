/**
 * Object Page controller extension — Vendors
 *
 * Rôle : après chaque action métier (Bloquer / Débloquer / Demande de clôture),
 * publie un événement sur l'EventBus pour que le List Report se rafraîchisse
 * automatiquement sans que l'utilisateur n'ait à cliquer sur "Go".
 */
sap.ui.define([
    "sap/fe/core/PageController"
], function (PageController) {
    "use strict";

    return PageController.extend("vendormanagementapp.ext.VendorsObjectPageExtension", {
        override: {
            editFlow: {
                /**
                 * Intercepte toutes les invocations d'actions bound sur l'Object Page.
                 * Après succès :
                 *  1. rafraîchit l'Object Page elle-même (header + sections)
                 *  2. notifie le List Report via l'EventBus pour qu'il se rafraîchisse aussi
                 */
                invokeAction: function (sActionName, mParameters) {
                    var oBase = this.base;
                    var oController = this;
                    return oBase.editFlow.invokeAction(sActionName, mParameters).then(function (oResult) {
                        // 1. Rafraîchir l'Object Page pour mettre à jour le statut et les boutons
                        try {
                            oController.getExtensionAPI().refresh();
                        } catch (e) {
                            console.warn("[ObjectPage] Auto-refresh after action failed:", e);
                        }
                        // 2. Notifier le List Report
                        sap.ui.getCore().getEventBus().publish(
                            "vendormanagementapp",
                            "vendorActionCompleted",
                            { action: sActionName }
                        );
                        return oResult;
                    });
                }
            }
        }
    });
});
