namespace udayuv.ushop;

using {udayuv.ushop as ushop} from '../index';
using {Country, cuid, managed} from '@sap/cds/common';
entity Users : cuid,managed{
    name        : ushop.Name;
    phone       : ushop.Text;
    city        : ushop.Text;
    country     : Country;
    products    : Association to ushop.Products;
}