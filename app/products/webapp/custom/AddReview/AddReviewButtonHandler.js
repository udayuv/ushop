sap.ui.define(["sap/m/MessageBox"], function (MessageBox){
    "use strict";

    return {
        openDialog: function(){
            MessageBox.show("ButtonPressed");
        },
    };
})