sap.ui.define(["sap/ui/core/Fragment","./AddReviewDialogHandler"], function (Fragment,AddReviewDialogHandler) {
    "use strict";

    return {
        openDialog: async function(oEvent){
            const sRowBindingPath = oEvent
                .getSource()
                .getParent()
                .getParent()
                .getBindingContextPath();
            console.log("THE BUTTON",sRowBindingPath);

            const oProductlistPage = sap.ui.getCore().byId("usy.products::ProductsList")

            if (!this.oAddReviewDialog) {
                this.sReviewDialogId = `${oProductlistPage.getId()}-AddReviewDialog`;
                this.oAddReviewDialog = await Fragment.load({
                    id: this.sReviewDialogId,
                    name:"usy.products.custom.AddReview.AddReviewDialog"
                });
                oProductlistPage.addDependent(this.oAddReviewDialog);
            }

            const oParams = {
                sRowBindingPath,
                sReviewDialogId: this.sReviewDialogId,
            };

            this.oAddReviewDialog.attachBeforeOpen(
                oParams,
                AddReviewDialogHandler.beforeOpenDialog
            );
      
            this.oAddReviewDialog.open();
      
            this.oAddReviewDialog.detachBeforeOpen(
                AddReviewDialogHandler.beforeOpenDialog
              );
        },
    };
})