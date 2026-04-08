sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"vendormanagementapp/test/integration/pages/VendorsList",
	"vendormanagementapp/test/integration/pages/VendorsObjectPage"
], function (JourneyRunner, VendorsList, VendorsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('vendormanagementapp') + '/test/flpSandbox.html#vendormanagementapp-tile',
        pages: {
			onTheVendorsList: VendorsList,
			onTheVendorsObjectPage: VendorsObjectPage
        },
        async: true
    });

    return runner;
});

