namespace udayuv.ushop;

using {Currency} from '@sap/cds/common';
entity Products {
    key id : Integer;
    name        :   String(30);
    description :   String(200);
    price       :   Decimal(9,2);
    rating      :   Decimal(2, 1)@assert.range : [ 0.0, 5.0 ];
    stock       :   Integer;
    discount    :   Decimal;
    currency    :   Currency;
}