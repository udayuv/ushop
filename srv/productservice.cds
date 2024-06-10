using { udayuv.ushop as product } from '../db/product';

service CatalogService {
    entity Products as projection on product.Products;
}