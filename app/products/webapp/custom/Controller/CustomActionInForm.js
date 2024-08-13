sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        actionInForm: function(oEvent) {
            MessageToast.show("Custom action form invoked.");
        }
    };
});
