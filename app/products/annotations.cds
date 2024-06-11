using CatalogService as service from '../../srv/productservice';

annotate service.Products with @(UI : {
    HeaderInfo : {
        TypeName : 'Product',
        TypeNamePlural : 'Products',
    },
    LineItem : [
        {
            $Type : 'UI.DataField',
            Value : name
        },
        {
            $Type : 'UI.DataField',
            Value : price
        },
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target : '@UI.DataPoint#rating'
        },
        {
            $Type : 'UI.DataField',
            Value : stock
        },
        {
            Value: description,
            ![@UI.Hidden]
        },
        {
            Value: currency_code,
            ![@UI.Hidden]
        }         
    ],
    SelectionFields : [
        price,
        name,
    ],
    PresentationVariant : {
        Text : 'Default',
        SortOrder : [{Property : name}],
        Visualizations : ['@UI.LineItem']
    },
    DataPoint #rating : {
        Value : rating,
        Visualization : #Rating,
        TargetValue : 5
    }
})

{
    //it will hide description from filter option
    @UI.HiddenFilter
    description;

    @Measures.ISOCurrency : currency.code
    price
};

// this is to make the label common so no need to provide label for filter,column etc
annotate service.Products with {
    price @title : '{i18n>price}';
    name @title : '{i18n>name}';
    description @title : '{i18n>description}';
    rating @title : '{i18n>rating}';
    stock @title : '{i18n>stock}';
    discount @title : '{i18n>discount}';
    //it will hide id from table column settings as well as filter settings
    ID @UI.Hidden;
};
