using {ProductService} from '../../';

annotate ProductService.Reviews with @(UI : {
    PresentationVariant : {
        $Type : 'UI.PresentationVariantType',
        SortOrder : [{
            $Type : 'Common.SortOrderType',
            Property : modifiedAt,
            Descending : true
        }, ],
    },
    LineItem : [
        {
            $Type : 'UI.DataFieldForAnnotation',
            Label : '{i18n>rating}',
            Target : '@UI.DataPoint#rating'
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Label : '{i18n>user}',
            Target : '@UI.FieldGroup#ReviewerAndDate'
        },
        {
            Value : title,
            Label : '{i18n>title}'
        },
        {
            Value : text,
            Label : '{i18n>text}'
        },
    ],
    DataPoint #rating : {
        Value : rating,
        Visualization : #Rating,
        MinimumValue : 0,
        MaximumValue : 5
    },
    FieldGroup #ReviewerAndDate : {Data : [
        {Value : createdBy},
        {Value : modifiedAt}
    ]}
});