using udayuv.ushop as db from '../../../db';

annotate db.Reviews with {
    rating
    @UI.Hidden   : {$edmJson: {$If: [{$Ge: [{$Path: 'rating'}, 2]}, false, true]}}
}