using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products;
    entity Review as projection on ushop.Reviews;
}