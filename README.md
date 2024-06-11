## Part 7: Custom Types, Aspects, and Associations in CDS data models

### Step 1: The Ratings Data Model
Our reviews will have three displayed fields — Rating, Title, and Text.
`db/Reviews.cds`
```cds
namespace udayuv.ushop;

entity Reviews {
    key id : Integer;
    rating : Integer;
    title : String(100);
    text : String(1000);
}
```

This is pretty good and it will get the job done but we can add some extra features to make it more robust.

#### Universal Unique Identifiers
In the first place there’s the ID. Of course we can just use a simple integer and increment it with each new review as we did with the Product, but thanks to CAP we can do better than that: with almost no effort we can implement `CUIDs`, a CAP’s flavor of Universal Unique Identifiers. All we have to do is import the cuid cds aspect as shown below.
`// db/Reviews.cds`

```cds
namespace udayuv.ushop;
using {cuid} from '@sap/cds/common';

entity Reviews : cuid {
    rating : Integer;
    title : String(100);
    text : String(1000);
}
```

It’s that simple. Just import cuid from `@sap/cds/common` and add it to your model as shown above, then delete the original `id` field. What this does behind the scenes is add a key field called `id` to your model. CAP will automatically generate a `CUID` and insert it into this field whenever you create a new entity. It’s super convenient. While we’re at it, let’s go and add cuid to our `Products` model as well.

#### Created At, Updated At, Created By, Updated By
The next thing we might care about is which user created a review and when. Luckily, CAP provides us with a built-in, automatic feature for this too the managed aspect. Let’s import that and add it to our model as well.
`// db/Reviews.cds`

```cds
namespace udayuv.ushop;
using {cuid,managed} from '@sap/cds/common';

entity Reviews : cuid,managed {
    rating : Integer;
    title : String(100);
    text : String(1000);
}
```

And there it is: now whenever a Review is created or updated, who did the creating or updating and when will automatically be recorded. We don’t have to do anything else!

For more information on these and other cds aspects, be sure to check out this [documentation](https://cap.cloud.sap/docs/cds/common#common-reuse-aspects).

#### Associations
The next thing that we need to do is to associate our `Reviews` with our `Products`. Since each book can have many reviews and each review can have only one product, we need this relationship captured by our data model. Conventionally we would have to set up foreign keys and all kinds of validations for this, but again CAP is there to help us out: we can easily create associations with almost no effort at all. CAP will handle all the details behind the scenes. Check the code below:
`// db/Reviews.cds`

```cds
namespace udayuv.ushop;

using {udayuv.ushop as ushop} from './index';
using {cuid,managed} from '@sap/cds/common';

entity Reviews : cuid,managed {
    product : Association to ushop.Products;
    rating  : Integer;
    title   : String(100);
    text    : String(1000);
}
```
Notice how we first import our udayuv.ushop namespace from index.cds, which gives us access to our Products model (recall that we imported our Products model there for easy access). After that we simply add a field called product to
our model and define it as Association to ushop.Products. By using this Association keyword CAP will generate a field called PRODUCT_ID behind the scenes and fill it with the associated products's ID automatically when a new review is created. Yet again, all the technical details are handled for us. However, we also need to go back to our products model and add the association there as well.

First, import our reviews model in index.cds for convenient importing
`// db/index.cds`

```cds
using from './products';
using from './reviews';
```
Then import the reviews model in products.cds and add the association as shown below:

```cds
namespace udayuv.ushop;

using {udayuv.ushop as ushop} from './index';
using {Currency,cuid, managed} from '@sap/cds/common';
entity Products : cuid,managed{
    name        : String(30);
    description : String(200);
    price       : Decimal(9,2);
    rating      : Decimal(2, 1)@assert.range : [ 0.0, 5.0 ];
    stock       : Integer;
    discount    : Decimal;
    currency    : Currency;
    reviews     : Association to many ushop.Reviews on reviews.product = $self;
}
```

-   This association is a bit more complex than the other so let’s break it down. We first define a field called `reviews`. Next we define it as an `Association to many` `ushop.Reviews`. 
-   With this definition CAP will know, not to create a field in the database — it won’t exist there at all. Instead, the CAP runtime will generate some logic for how to retrieve the list of reviews associated with a specific `Products` entity, so that when we want to retrieve the `reviews` for a specific product, we can easily do it without needing to write any SQL. 
-   Finally we provide the condition: `when the product field of a Reviews entity contains the ID of the current Products entity`, it will be included.

#### Enum Types
Next, the rating field itself. We just marked it as an Integer here unlike the Rating field in the Products model, which is a Decimal. This is because Products is an average of many single ratings from Reviews, so a Products average might
come out as a decimal, but we don’t want our users to enter anything but whole numbers. 

Of course, the number that the user enters should be between 0 and 5, so at first you might think we should use the `@assert.range` annotation on again. Indeed we could do that and it would work fine, but we could do a little better. The reason is that each rating number actually has a semantic meaning. By using CDS’s Enum Types we can explicitly define the semantics. We can define the type as shown below:
`// db/rating.cds`

```cds
namespace udayuv.ushop;

type Rating : Integer enum {
    Great = 5;
    Good = 4;
    Average = 3;
    Poor = 2;
    Bad = 1;
    Terrible = 0;
}
```
Now we can import this in our Reviews model and set this as the type for the rating field as shown below:
`// db/Reviews.cds`

```cds
entity Reviews : cuid,managed {
    product : Association to ushop.Products;
    rating  : ushop.Rating;
    title   : String(100);
    text    : String(1000);
}
```

#### Validations
Finally, we have one last thing to do: validations. Here we will use **@mandatory** for *title* and *text* because we want to make sure our users always include those. Finally, for rating we add `@assert.range` like we used with our rating field in the Products entity. The difference here is that we don’t have to manually specify the range — because we’re using an enum type that’s handled for us.
`// db/Reviews.cds`

```cds
entity Reviews : cuid,managed {
    product : Association to ushop.Products;
    rating  : ushop.Rating @assert.range;
    title   : String(100) @mandatory;
    text    : String(1000) @mandatory;
}
```
All right! Now we have our Reviews model defined and ready to go. Next we’ll tackle providing a bit of mock data for the Reviews and to update our Products mock data to use cuids instead of simple integers.

### Step 2: Mock Data Revisited
Now that we have our model ready, we need to provide some mock data to help us when we’re working with the UI. If you recall from back in Part 2, we need to provide a semicolon-separated csv file in the folder db/data and the file should be named with this pattern: <namespace>-<entity>.csv. Let’s make that file. `cds add data` will create automatically

In the first line of the file, we need the names of the fields as they are in the database, not as we defined them in our CDS files. An easy way to check them is to run the command `cds compile ./db/Reviews.cds --to hana` and see
what comes out.

Using this, we can set up our CSV header like so:
`// db/data/toadslop.bookshop-Reviews.cds`
```csv
ID;CREATEDAT;CREATEDBY;MODIFIEDAT;MODIFIEDBY;RATING;TITLE;TEXT;PRODUCT_ID;
ID,product_ID,rating,title,text,createdAt,createdBy,modifiedAt,modifiedBy
```
Notice that we did not include a field for PRODUCT. That’s because this field doesn’t exist as a normal field in the database. PRODUCT_ID is all we need to concern ourselves with.

The next steps are unfortunately a bit tedious as CAP doesn’t currently provide a build-in way to generate data, though I suspect one could be built without too much trouble using a library like Faker, but for now we’ll just do it manually.

First, let’s generate some IDs. Because we’re now using CUIDs, we can’t just put in an integer anymore. However developer Andrew Barnard describes a nice way to get this done automatically in this [blog post](https://blogs.sap.com/2020/06/04/cap-preparing-initial-data-with-uuid-keys/). While we’re at it, we do need to update the IDs in our Products model too since we switched those over to CUIDs. You can go ahead and try to do this all yourself, but as it’s tedious and we’re really more interested in learning the CAP framework, you can also just copy the [sample data](https://github.com/SAP-samples/cloud-cap-samples-java/tree/main/db/data) from SAP’s Bookshop app repository and move on to the next step. Be careful about copying the Books data, though! They have some fields that we haven’t implemented yet, so make sure you don’t copy those — just update the IDs

### Step 3: Adding the New Modelto Our Service
Now that we have our new model and some mock data, let’s add it to our oData service so that we can access it. If you’ve been following this series up to this point, you should know how to do this so give it a try on your own. After that, scroll down and check how I did it.

```cds
using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products;
    entity Review as projection on ushop.Reviews;
}
```

## Part 8: Custom Actions and Input Type Definitions

### Step 1: Defining aCustom Action
One of the features of Fiori Elements that can be a little frustrating at first is how to trigger some kind of event on the page. After all, we can’t write any logic directly in the Fiori Elements application, so our hands feel like their
tied.

However, Fiori Elements is controlled entirely by oData and oData luckily has the perfect feature: custom actions and custom functions. oData borrows this terminology from functional programming, so for those new to that style
- a `function` is simply a subroutine that has no side-effects — in the case of oData, that would mean no writes to the database. 
- An `action` on the other hand does include side effects. Again, in oData’s case a side effect would typically just be a write to the database (see this [oData blog article](https://www.odata.org/blog/actions-in-odata/) for more information). 

For a more tangible example, imagine we wanted to get just a count of how many Products are in the database and nothing else — that would be a function because it requires only reading. However, we want to actually write a new Review to the database, so we’re going to create an action. Let’s learn how to do that using CDS.

To begin with, we need to understand that CDS allows us to define two different types of `actions` and `functions`: **bound** and **unbound**. 
- The *bound* variety is attached to a specific entity, ensuring that the entity is present in the context of any call to it. 
- The *unbound* variety can be called without any specific entity context (see this [documentation](https://cap.cloud.sap/docs/cds/cdl#actions) for more info). 

In our case the former is what we want because we need to attach our new Review to a specific Product. Let’s get to the code. First let’s open up our `srv/productservice.cds` file to refresh ourselves on our current service definition.

```cds
using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products;
    entity Reviews as projection on ushop.Reviews;
}
```

We wanted to bind our action to our Products entity. Define a list of available actions bound to this entity in the following way. Note that the newline and tab are for readability — they aren’t required

```cds
using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products
        actions{}
    entity Reviews as projection on ushop.Reviews;
}
```

-   Next we define our action. First we start the definition with the action keyword followed by a name for the action. 
-   Next is a comma-separated list of inputs for the function, each with a required type. 
-   Finally, we provide the return type, which we are defining as an instance of the Reviews entity. 

Note that we aren’t limited to returning just entities like Reviews — we could return a custom type as well.

```cds
using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products
        actions{
            action addReview(rating : Integer,title : String,text : String) returns Reviews;
        }
    entity Reviews as projection on ushop.Reviews;
}
```

Let’s compile our service definition using `cds compile --to edmx` to see the effect of our work. This is what will be sent to our Fiori Elements app to tell it how to process our action.

### Step 2:Custom Input Type Definitions
The weakness of our function definition is that it that its input types are too generic. We know from Part 7, for example, that we defined our our `rating` field as an enum type that only accepts values of 0–5, but an integer could be any non-decimal positive or negative number. Leaving it like this would require some manual validations in the Java handler that we will make for this action later. Instead, though, we can simply reuse the type to the same one we defined before, which is useful because if we update that type definition we won’t need to update the Java code as well. We can do so in the following way:

```cds
using { udayuv.ushop as ushop } from '../db/index';

service CatalogService {
    entity Products as projection on ushop.Products
        actions{
            action addReview(rating : ushop.Rating,title : String,text : String) returns Reviews;
        }
    entity Reviews as projection on ushop.Reviews;
}
```

At this point, though, we can see some other issues as well. Recall that when we created our `Review` model, we specified a max-length for the `title` and `text` fields as 100 and 1000 characters respectively:

If we don’t also define that here, then users might submit text that’s too long, again requiring us to do manual validation. We could solve the issue as follows:

```cds
actions{
            action addReview(rating : ushop.Rating,title : String(100),text : String(1000)) returns Reviews;
        }
```

I think you can already see the problem here, though — what if we decided to change the length for these fields? Then we’d have to update the code in two places, which would be a hassle and easy to forget. Instead, let’s define some custom types to handle this for us. 

In the `db` folder, let’s create two new files,` datatype.cds` under datatype and give them the following content:
```cds
namespace udayuv.ushop;

type Name : String(100);
type Text : String(1000);

```

Let’s not stop there, though! If we look again at our Products entity, we’ll see that it’s name and descr fields are also 100 and 1000 characters respectively. We can reuse our types there. 

Now we can simply use these in our Reviews entity definition and in our action definition:

```cds
entity Reviews : cuid,managed {
    product : Association to ushop.Products;
    rating  : ushop.Rating @assert.range;
    title   : ushop.Name @mandatory;
    text    : ushop.Text @mandatory;
}
```
action
```cds
  action addReview(rating : ushop.Rating,title : ushop.Name,text : ushop.Text) returns Reviews;
```

