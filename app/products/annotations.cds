using CatalogService as service from '../../srv/productservice';

annotate service.Products with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : name,
            Label : '{i18n>name}',
        },
        {
            $Type : 'UI.DataField',
            Value : price,
            Label : '{i18n>price}',
        },
        {
            $Type : 'UI.DataField',
            Value : rating,
            Label : '{i18n>rating}',
        },
        {
            $Type : 'UI.DataField',
            Value : stock,
            Label : '{i18n>stock}',
        },
    ]
);
annotate service.Products with @(
    UI.SelectionFields : [
        price,
        name,
    ]
);
annotate service.Products with {
    price @Common.Label : 'Price'
};
annotate service.Products with {
    name @Common.Label : 'Name'
};
