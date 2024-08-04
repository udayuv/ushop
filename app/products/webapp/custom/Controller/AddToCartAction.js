sap.ui.define([
    "sap/m/MessageToast"
], function(MessageToast) {
    'use strict';

    return {
        addToCartAction: function(oEvent) {
            MessageToast.show("Added to Cart action invoked.");
        }
    };
});
