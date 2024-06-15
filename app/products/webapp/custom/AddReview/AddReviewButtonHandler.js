sap.ui.define(["sap/ui/core/Fragment","./AddReviewDialogHandler"], function (Fragment,AddReviewDialogHandler) {
    "use strict";

    return {
        openDialog: async function(){
            const oProductlistPage = sap.ui.getCore().byId("usy.products::ProductsList")
            if (!this.oAddReviewDialog) {
               this.oAddReviewDialog = await Fragment.load({
                    id: `${oProductlistPage.getId()}-AddReviewDialog`,
                    name:"usy.products.custom.AddReview.AddReviewDialog"
                });
                oProductlistPage.addDependent(this.oAddReviewDialog);
            }
            this.oAddReviewDialog.attachBeforeOpen(
                AddReviewDialogHandler.beforeOpenDialog
            );
      
            this.oAddReviewDialog.open();
      
            this.oAddReviewDialog.detachBeforeOpen(
                AddReviewDialogHandler.beforeOpenDialog
              );
        },
    };
})