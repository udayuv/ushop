namespace udayuv.ushop;

using {udayuv.ushop as ushop} from '../index';
using {Currency,cuid, managed} from '@sap/cds/common';
entity Products : cuid,managed{
    name        : ushop.Name;
    description : ushop.Text;
    price       : Decimal(9,2);
    rating      : ushop.Rating @assert.range;
    stock       : Integer;
    discount    : Decimal;
    currency    : Currency;
    reviews     : Association to many ushop.Reviews on reviews.product = $self;
}