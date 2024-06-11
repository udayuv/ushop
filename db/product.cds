namespace udayuv.ushop;

using {udayuv.ushop as ushop} from './index';
using {Currency,cuid, managed} from '@sap/cds/common';
entity Products : cuid,managed{
    name        : String(30);
    description : String(200);
    price       : Decimal(9,2);
    rating      : Decimal(2, 1)@assert.range : [ 0.0, 5.0 ];
    stock       : Integer;
    discount    : Decimal;
    currency    : Currency;
    reviews     : Association to many ushop.Reviews on reviews.product = $self;
}