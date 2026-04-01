// KPI header injection is handled by Component.js via router.attachRouteMatched.
// This file is kept to satisfy the manifest controllerExtensions registration.
sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend("vendormanagementapp.ext.ListReportExtension", {
        override: {}
    });
});
