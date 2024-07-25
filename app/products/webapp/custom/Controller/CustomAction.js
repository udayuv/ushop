sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        triggerAction: function(oEvent) {
            MessageToast.show("Action Clicked.");
        }
    };
});
