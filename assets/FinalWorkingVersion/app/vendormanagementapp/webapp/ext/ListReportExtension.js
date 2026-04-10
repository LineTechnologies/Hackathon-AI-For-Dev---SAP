/**
 * List Report controller extension — Vendors
 *
 * Rôle : écoute l'EventBus et rafraîchit la table lorsqu'une action métier
 * (Bloquer / Débloquer / Demande de clôture) est exécutée depuis l'Object Page.
 * Cela évite à l'utilisateur de cliquer manuellement sur "Go" pour voir
 * le nouveau Blocking Status dans la liste.
 */
sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend("vendormanagementapp.ext.ListReportExtension", {
        override: {
            onInit: function () {
                var that = this;
                sap.ui.getCore().getEventBus().subscribe(
                    "vendormanagementapp",
                    "vendorActionCompleted",
                    function () {
                        try {
                            that.getExtensionAPI().refresh();
                        } catch (e) {
                            console.warn("[ListReport] Auto-refresh after action failed:", e);
                        }
                    }
                );
            }
        }
    });
});
