package uv.handlers;

import java.util.Map;

import org.springframework.stereotype.Component;

import com.sap.cds.Result;
import com.sap.cds.ql.Insert;
import com.sap.cds.ql.cqn.AnalysisResult;
import com.sap.cds.ql.cqn.CqnAnalyzer;
import com.sap.cds.ql.cqn.CqnInsert;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.reflect.CdsModel;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;

import cds.gen.productservice.AddReviewContext;
import cds.gen.productservice.ProductService_;
import cds.gen.productservice.Products;
import cds.gen.productservice.Reviews;
import cds.gen.udayuv.ushop.Reviews_;

@Component
@ServiceName(ProductService_.CDS_NAME)
public class ProductServiceHandler implements EventHandler {
    private final PersistenceService db;
    private final CqnAnalyzer analyzer;

    ProductServiceHandler(PersistenceService db, CdsModel model){
        this.db = db;
        this.analyzer = CqnAnalyzer.create(model);
    }

    @On(event=AddReviewContext.CDS_NAME)
    public void addReview(AddReviewContext context){

        CqnSelect select = context.getCqn();
        String productId = (String) analyzer.analyze(select).targetKeys().get(Products.ID);
        
        Reviews review = Reviews.create();
        review.setProductId(productId);
        review.setTitle(context.getTitle());
        review.setRating(context.getRating());
        review.setText(context.getText());

        CqnInsert reviewInsert = Insert.into(Reviews_.CDS_NAME).entry(review);
        Result savedReview = db.run(reviewInsert);
        Reviews newReview = savedReview.single(Reviews.class);

        context.setResult(newReview);
    }
}
