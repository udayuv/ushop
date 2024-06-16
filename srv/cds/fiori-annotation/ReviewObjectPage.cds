using {ProductService} from '../../';

annotate ProductService.Reviews with @(
    UI.DataPoint #ratingOP : {
        Value : rating,
    },
    UI.Chart #rating : {
        ChartType : #Line,
        Title : 'Rating Area Chart',
        Measures : [
            rating,
        ],
        MeasureAttributes : [
            {
                DataPoint : '@UI.DataPoint#ratingOP',
                Role : #Axis1,
                Measure : rating,
            },
        ],
        Dimensions : [
            rating,
        ],
    },
);