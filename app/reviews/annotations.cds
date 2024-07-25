using ReviewService as service from '../../srv/cds/services/reviewService';

annotate service.Reviews with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'rating',
            Value : rating,
        },
        {
            $Type : 'UI.DataField',
            Label : 'title',
            Value : title,
        },
        {
            $Type : 'UI.DataField',
            Label : 'text',
            Value : text,
        },
    ]
);
annotate service.Reviews with @(
    odata.draft.enabled: true,
    UI.FieldGroup #GeneratedGroup1 : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'rating',
                Value : rating,
            },
            {
                $Type : 'UI.DataField',
                Label : 'title',
                Value : title,
            },
            {
                $Type : 'UI.DataField',
                Label : 'text',
                Value : text,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup1',
        },
    ]
);
annotate service.Reviews with {
    rating @(Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Reviews',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : rating,
                    ValueListProperty : 'rating',
                },
            ],
            Label : 'Target',
        },
        Common.Text : {
            $value : text,
            ![@UI.TextArrangement] : #TextOnly,
        }
)};
