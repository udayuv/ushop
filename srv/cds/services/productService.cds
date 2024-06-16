using { udayuv.ushop as ushop } from '../../../db';

service ProductService {
    entity Products as projection on ushop.Products
        actions{
            action addReview(rating : ushop.Rating,title : ushop.Name,text : ushop.Text) returns Reviews;
        };

    entity Reviews as projection on ushop.Reviews;
}