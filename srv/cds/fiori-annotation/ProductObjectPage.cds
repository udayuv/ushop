using ProductService as service from '../..';
using udayuv.ushop as db from '../../../db';

annotate service.Products with @(
    odata.draft.enabled: true,
    UI : {
        HeaderInfo  : {
            $Type : 'UI.HeaderInfoType',
            TypeName : 'Product',
            TypeNamePlural : 'Products',
            Title : { $Type : 'UI.DataField', Value : name},
            ImageUrl : 'https://placebear.com/251/251'
        },

        HeaderFacets: [            
            {$Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#RatingIndicator'},
            {$Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Rating'},
            {$Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#RatingProgress'},
            {
                $Type : 'UI.ReferenceFacet',
                ID : 'stock',
                Target : '@UI.Chart#stock',
            },
            {
                $Type : 'UI.ReferenceFacet',
                ID : 'rating',
                Target : 'reviews/@UI.Chart#rating',
            },
        ],
        Facets : [
            {
                $Type  : 'UI.CollectionFacet',
                Label  : 'General Information',
                ID     : 'GeneralInformationFacet',
                Facets : [
                    {
                        $Type  : 'UI.ReferenceFacet',
                        ID     : 'SubSectionMainDetails',
                        Label  : 'Main Details',
                        Target : '@UI.FieldGroup#MainDetails'
                    },
                    {
                        $Type  : 'UI.ReferenceFacet',
                        ID     : 'SubSectionAdminData',
                        Label  : 'Admin Date',
                        Target : '@UI.FieldGroup#Admin'
                    },
                    {
                        $Type  : 'UI.ReferenceFacet',
                        ID     : 'SubSectionAdData',
                        Label  : 'Macros Field',
                        Target : '@UI.FieldGroup#myQualifier'
                    }
                ]
            },
            {
                $Type : 'UI.ReferenceFacet',
                Label : '{i18n>Description}',
                Target : '@UI.FieldGroup#Descr'
            },
            {
                $Type : 'UI.ReferenceFacet',
                Label : '{i18n>Reviews}',
                Target : 'reviews/@UI.LineItem'
            }
        ],
        FieldGroup#MainDetails:{
            Data  : [
                {$Type : 'UI.DataField', Value : name},
                {$Type : 'UI.DataField', Value : rating}
            ]
        },
        FieldGroup#Admin :{
            Data  : [
                {$Type : 'UI.DataField', Value : createdAt},
                {$Type : 'UI.DataField', Value : createdBy},
                {$Type : 'UI.DataField', Value : modifiedAt},
                {$Type : 'UI.DataField', Value : modifiedBy}
            ]
        },
        FieldGroup #Descr : {Data : [{Value : description}]},

        DataPoint #RatingIndicator : {
            Value : rating,
            Visualization : #Rating,
            TargetValue : 5
        },
        DataPoint#Rating:{
            Value: rating,
            Criticality:3,//need to check with edmjson for rating
            CriticalityRepresentation : #WithIcon,
            Title : 'Rating DataPoint'
        },
        DataPoint#RatingProgress:{
            Value: rating,
            Visualization :#Progress,
            TargetValue : 5,
            Title : 'Rating Progress'
        },
        
        //chart reference to be shown in header facet
        Chart #stock : {
            ChartType : #Donut,
            Title : 'Stock',
            Measures : [
                stock,
            ],
            MeasureAttributes : [
                {
                    DataPoint : '@UI.DataPoint#stock',
                    Role : #Axis1,
                    Measure : stock,
                },
            ],
        },
        DataPoint #stock : {
            Value : stock,
            TargetValue : 100,
        },
    }
);

annotate service.Products.currency with @(Common.ValueListWithFixedValues);