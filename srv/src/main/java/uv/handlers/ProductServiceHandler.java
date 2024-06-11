package uv.handlers;

import org.springframework.stereotype.Component;

import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;

import cds.gen.productservice.AddReviewContext;
import cds.gen.productservice.ProductService_;
import cds.gen.productservice.Reviews;

@Component
@ServiceName(ProductService_.CDS_NAME)
public class ProductServiceHandler implements EventHandler {
    @On(event=AddReviewContext.CDS_NAME)
    public void addReview(AddReviewContext context){

        Reviews review = Reviews.create();
        review.setTitle(context.getTitle());
        review.setRating(context.getRating());
        review.setText(context.getText());

        context.setCompleted();
    }
}
