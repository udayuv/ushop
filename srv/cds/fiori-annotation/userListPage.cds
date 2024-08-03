using ProductService as service from '../../';

// annotate service.Products with @(UI : {
annotate service.Users with @(UI : {
    LineItem : [
        {
            $Type : 'UI.DataField',
            Value : name
        },
        {
            $Type : 'UI.DataField',
            Value : phone
        },
        {
            $Type : 'UI.DataField',
            Value : city
        },
        {
            $Type : 'UI.DataField',
            Value : country_code
        }
    ],
    PresentationVariant : {
        Text : 'Default',
        SortOrder : [{Property : name}],
        Visualizations : ['@UI.LineItem']
    }
});