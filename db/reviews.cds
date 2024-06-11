namespace udayuv.ushop;

using {udayuv.ushop as ushop} from './index';
using {cuid,managed} from '@sap/cds/common';

entity Reviews : cuid,managed {
    product : Association to ushop.Products;
    rating  : ushop.Rating @assert.range;
    title   : String(100) @mandatory;
    text    : String(1000) @mandatory;
}