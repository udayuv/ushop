using { udayuv.ushop as ushop } from '../../../db';

service ReviewService {
    entity Reviews as projection on ushop.Reviews;
}