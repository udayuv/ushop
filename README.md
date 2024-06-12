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

service ProductService {
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

service ProductService {
    entity Products as projection on ushop.Products;
    entity Reviews as projection on ushop.Reviews;
}
```

We wanted to bind our action to our Products entity. Define a list of available actions bound to this entity in the following way. Note that the newline and tab are for readability — they aren’t required

```cds
using { udayuv.ushop as ushop } from '../db/index';

service ProductService {
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

service ProductService {
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

service ProductService {
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

## Part 9: Handler Setup, Event Lifecycle Phases, and Context Objects

### Step 1: Setting Up the Service Handler
Our first step is to set up our boilerplate code for the service handler. Let’s start by creating a folder called `handlers` in `srv/src/main/java/uv` and inside it creating a file called `ProductServiceHandler.java`.

If you set up your environment correctly, then a basic Java class boilerplate should already be generated in the file.
```java
package uv.handlers;

public class ProductServiceHandler {
    
}
```

The first thing we need to do is get access to the standard event handler functionality by implementing the CDS `EventHandler` interface and to provide the Component annotation from the SpringBoot framework, as shown below:

```java
package uv.handlers;

import org.springframework.stereotype.Component;

import com.sap.cds.services.handler.EventHandler;

@Component
public class ProductServiceHandler implements EventHandler {
    
}
```
With these we’re almost set up, but there’s a problem: CAP doesn’t know which service this handler belongs to, so even if we write some logic, it can’t be triggered. We need to use CAP’s `ServiceName` annotation and provide it the name of our service as a String.

```java
@Component
@ServiceName("ProductService")
public class ProductServiceHandler implements EventHandler {
    
}
```

As you can imagine, though, using a String literal as an input is a little bit dangerous — after all, we can’t easily see if we made a typo. Luckily CAP automatically generates some files for us from our CDS that can help us out here. Open the `srv/src/gen` folder to check them out.

As you can see, CAP generated a `productservice` folder that contains Java interfaces generated from our CDS files. These provide us a type-safe way of handling our service. For example, open `ProductService_.java` and see what we find inside.

Notice the property `CDS_NAME` — it’s the name of our service as a string. Because it was generated straight from our CDS, we know that it matches correctly, so we won’t have any typos. Let’s go ahead and use this instead of the string literal from before.

```java
...
import cds.gen.productservice.ProductService_;

@Component
@ServiceName(ProductService_.CDS_NAME)
public class ProductServiceHandler implements EventHandler {
    
}
```

Now our service handler is ready to receive calls on the `productservice` and process them. You can confirm this by starting up your server and looking for the following output:

```log
2024-06-11T22:24:01.854+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service OutboxService$InMemory
2024-06-11T22:24:01.862+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service ApplicationLifecycleService$Default
2024-06-11T22:24:01.862+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service AuthorizationService$Default
2024-06-11T22:24:01.869+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service TenantProviderService$Default
2024-06-11T22:24:01.870+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service DeploymentService$Default
2024-06-11T22:24:01.878+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service AuditlogService$Default
2024-06-11T22:24:01.913+05:30  INFO 23196 --- [  restartedMain] c.s.c.services.impl.ServiceCatalogImpl   : Registered service ProductService
```

Next let’s add a lifecycle method!
### Step 2: The ‘On’ Lifecycle Method
CAP provides three lifecycle methods to help us manage our services — `Before`, `On`, and `After`. You can probably guess from the names, but 
-   `Before` is for handling preprocessing of the request, for example checking authorizations, 
-   `On` is where the actual database query should be carried out, 
-   and `After` is for postprocessing, for example setting up the values for a calculated field. 

To keep things simple, we’re going to start with just implementing an On handler. The following is the basic setup for one:
```java
@Component
@ServiceName(ProductService_.CDS_NAME)
public class ProductServiceHandler implements EventHandler {
    @On
    public void addReview(){}
}
```

What we see here is the On annotation, which is used to designate that the following function as an On event handler. We designate it as public since CAP will need to call this function from outside the class. Finally, we give it a descriptive name. Note that the function name can be anything — CAP doesn’t use the name to link it with the function defined in CDS. If we try to start the application as it is, we’ll get the following error message:

```log
com.sap.cds.services.utils.ErrorStatusException: Failed to register handler method 'public void uv.handlers.ProductServiceHandler.addReview()': No event definition in annotations or arguments
```
This is because for the On annotation to work, we need to tell it when to run — or more specifically, under what conditions it should run. We can do that by passing in some attributes to it. There are four possible attributes that can be added: `service`, `serviceType`, `event`, and `entity`. 

We need at least one but we can use as many as we want to target our function to run in as many or as few situations as we need. You can read more about these attributes [here](https://cap.cloud.sap/docs/java/provisioning-api#handlerannotations). 
-   The service annotation isn’t necessary because we already defined that with our ServiceName annotation. You’d only use that one if you wanted an event written in one service handler to be triggered by an event from a completely different service. 
-   serviceType is a bit over our heads now since we haven’t considered the different types of services in a CAP app (we’re currently working in what’s called an Application Service), but suffice to say if we wanted to respond to some event that occurs in another type of service we’d specify that here. 
-   The entity parameter is used to specify which entity we want to trigger the action on. 
-   And finally, the parameter we care most about: event 

CAP has a number of pre-defined events that correspond to the basic CRUD events (with a few extras), but when we create a custom action or function CAP registers that as an event too. We simply need to provide a string containing the name of our action as shown below:
```java
    @On(event="addReview")
    public void addReview(){}
```

As you might have guessed from Step 1, though, CAP provides us with an automatically generated file that contains the name written for us so we don’t have to worry about any typos. Look in the gen folder to find it, There you see it: CDS_NAME, just like before. Let’s use that instead
```java
    @On(event=AddReviewContext.CDS_NAME)
    public void addReview(){}
```
Now we can start up the app with no problem. In the next step we’ll learn how to test our new action using a REST client.

### Step 3: Testing a Bound Action
Before we start writing the logic, we want to be set up to test that logic, so we need some way to trigger our action. You may recall from earlier posts in this series that we used the REST Client addon to VS Code to test the CRUD actions for our Books and Reviews entities and we’re going to use it again here. Before we move over to our test file srv/api-test/cat-service.http, let’s add a println to log Triggered the action! to the console when the function we wrote is called.

Now back in our productservice.http file we need to prepare our request, starting with the endpoint. For bound actions in oData V4, the syntax is as follows:
`<entity_name>(<entity_id>)/<service_name>.<action_name>`

So to test this let’s just get one id for a product and plug it in so we get the following:
```
http://localhost:8080/odata/v4/ProductService/Products(f846b0b9-01d4-4f6d-82a4-d79204f62278)/ProductService.addReview
```
Now we just need to package it up as a POST request and provide a JSON of the input data, as shown below.
```http
POST http://localhost:8080/odata/v4/ProductService/Products(f846b0b9-01d4-4f6d-82a4-d79204f62278)/ProductService.addReview HTTP/1.1
content-type: application/json

{
  "title": "I hated it",
  "text": "Birds freak me out",
  "rating": 1
}
```

Now, if we click Send Request and check the console, we can find our message logged. However, you’ll also noticed that we go an error:

```log
com.sap.cds.services.utils.ErrorStatusException: No ON handler completed the processing
```
This might seem confusing since we did successfully define our On handler, as our console output shows. However, CAP requires a handler to finish with an explicit declaration that its processing completed successfully. We’ll look at how to do that in Part 10 of this series; for now, let’s dive into the context object.

### Step 4: TheContext Object and Its Properties
So we have our action setup and ready for our logic, but as usual, we have a problem: Where are our inputs? How can I get the ID of the product since it’s not an input? And how can I fix that pesky error from the last section? All of those problems can be solved by the context object. 

Recall that when we specified the event for the On handler, we used `AddReviewContext.cds’s` CDS_NAME property. As you may have guessed by now, there’s a lot more that this interface can do than simply give us access to a string. To get access to the context, we simply need to provide it as a parameter to our function and CAP will pass in the appropriate data automatically.

Now we let’s get started on processing our inputs. First, we need to extract them from the `context`. Take a look at the `AddReviewContext.cds` file and you’ll see the following methods.

They’re getter and setter methods for our inputs. Let’s extract them and print them to the console to confirm.

```java
@Component
@ServiceName(ProductService_.CDS_NAME)
public class ProductServiceHandler implements EventHandler {
    @On(event=AddReviewContext.CDS_NAME)
    public void addReview(AddReviewContext context){
        String title = context.getTitle();
        String text = context.getText();
        Integer rating = context.getRating();

        System.out.println("Action Triggered!!!");
        System.out.println(title);
        System.out.println(rating);
        System.out.println(text);

        context.setCompleted();
    }
}
```
We saw earlier that when we define entities in CDS, CAP creates type-safe interface for us to use. We can use that now to create a Review object and populate it with our data.

First we import the Reviews interface, then we instantiate a Review object using the create method. Next we can use getters and setters just like before to populate the values:


## Part 10: CQN Analyzers, extracting values from CQN statements, saving to the database, and returning responses

### Step 1: Setting Up aCQN Analyzer
Last time we extracted the data from the context object and placed it in a new instance of the Review interface. However, we can’t simply save it yet because we don’t have the ID of the parent product, and without that we can’t associate the review to that book. However, we can extract that value from the context object’s CQN.

CQN or *CDS Query Notation* is a CAP’s way of abstracting data queries away from individual dialects of SQL (best support is for SQLite and HANA, but Postgres is also supported with some limitations) into a common notation that allows a single query without having to worry about the underlying database. This is useful because you can switch from one database to another (SQLite for development, HANA for production) without having to change the code; however, it means everyone involved in developments needs to learn yet another query notation. 

So anyway, let’s learn a little about it together. First, let’s extract the CQN using the context object’s getCqn method and print the result to the console so we can get a good look at it.

```log
{"SELECT":{"from":{"ref":[{"id":"ProductService.Products","where":[{"ref":["ID"]},"=",{"val":"f846b0b9-01d4-4f6d-82a4-d79204f62278"}]}]}}}
```

As you can see, this CQN resembles the syntax of a SQL statement, but the different parts have been separated out in arrays and objects so they can be handled easily by the framework; CQN can also be written as a string like regular SQL and then parsed into this form. For more info on CQN, check this [documentation](https://cap.cloud.sap/docs/cds/cqn).

In any case, inside of this CQN we can clearly see the Product ID. But how do we actually extract the value? If we check VS Code to find the output type of the getCqn method, we can see that it’s CqnSelect. We can go to [javadoc.io](https://www.javadoc.io/doc/com.sap.cds/cds4j-api/1.3.0/com/sap/cds/ql/cqn/CqnSelect.html) to examine the details about this type and find quite a few built-in methods that seem promising, but try as you might actually getting the value this way is not possible. Rather, we have to use CqnAnalyzer to extract the ID.

There are several ways to set up a CqnAnalyzer, but an ideal way is to initialize an instance of it in the Event Handler class’ constructor, though we can in fact initialize it directly in the function if we wanted to. However, since we will reuse this analyzer repeatedly throughout this handler, rather than instantiate it every time the method is called we’ll just instantiate it when the event handler itself is instantiated when the app is started. This is achieved in the following way:

```java
public class ProductServiceHandler implements EventHandler {
    private final CqnAnalyzer analyzer;

    ProductServiceHandler(CdsModel model){
        this.analyzer = CqnAnalyzer.create(model);
    }
```

To explain the above, first we import `CqnAnalyzer` and `CdsModel`. Next we declare the analyzer type and variable name. Finally we set up the constructor function. When instantiating the handler, CAP will pass in the metadata about the model for this service, so we specify an input called model of type CdsModel. We then create an instance of CqnAnalyzer and assign it to the variable we declared above. Notice that we pass in the model to CqnAnalyzer.create(), which provides the analyzer with the necessary metadata it needs to properly analyze the CQN generated by and for this service. Now that we have it we can start using it to analyze the CQN that we extracted above. Let’s do that now

### Step 2: Extracting the ID from theCQN Using theCqnAnalyzer
Next let’s explore the `analyzer` a little bit to learn how we can use it to extract information from the CQN. Let’s take our extracted CQN and put in in a variable (it’s type is `CqnSelect`), then let’s use the analyzer’s main method, `analyze` and pass in the CQN as an input, then let’s print that to the console to see what we get.
```java
CqnSelect select = context.getCqn();
AnalysisResult analysisResult = analyzer.analyze(select);
```
```log
{"ref":[{"id":"ProductService.Products","where":[{"ref":["ID"]},"=",{"val":"f846b0b9-01d4-4f6d-82a4-d79204f62278"}]}]}
```

It looks the same printed as it did before, but now the analyzer has provided us with a whole new list of methods to work with that we didn’t have access to when it was simply a CqnSelect. You can check out the full list of them here. For now, what we care about is the targetKeys method.
```java
Map<String,Object> map = analyzer.analyze(select).targetKeys();
```

Look at that! It’s our ID. And since it’s a Map we know we can easily extract the value we’re looking for by just using the get method while passing ‘ID’ in as a String, but let’s not forget all the generated files that CAP provided for us. We’re expecting a product's ID so we can extract the value as follows
```java
String productId = (String) analyzer.analyze(select).targetKeys().get(Products.ID);
```

That’s our book ID. Now we can finally assign it to our new review. Let’s do that.

```java
 public void addReview(AddReviewContext context){

        CqnSelect select = context.getCqn();
        String productId = (String) analyzer.analyze(select).targetKeys().get(Products.ID);
        
        Reviews review = Reviews.create();
        review.setProductId(productId);
        review.setTitle(context.getTitle());
        review.setRating(context.getRating());
        review.setText(context.getText());

        context.setCompleted();
    }
```
And there you have it! We’re ready to actually insert our new review into the database. We’ll talk about that in the next section. For now, let’s just sit back and enjoy the fact that we now know how to extract values from a CQN statement. There are many cases where we might need to do this, and not just to extract IDs, so I encourage you to experiment with the CqnAnalyzer more and see if you can figure out how to extract the other values from our CQN. But for now, let’s move on to the database.

### Step 3: Saving the Review to the Database
In an earlier post in this series I mentioned that a service handler like what we are creating now is known as an application service in CAP, and that there are several other types of services as well (refer to this [documentation](https://cap.cloud.sap/docs/java/consumption-api) to learn about the others). When it comes to interacting with the application’s database, we need to interact with a persistence service, which are services that handle interaction with databases. Since CAP comes preconfigured to work with SQLite (which CAP sets up by default and which we are currently using) and HANA, we don’t have to worry about actually making persistence services— we can use them just as they are. Let’s instantiate our persistence service so we can use it to insert our new product. This is done just like we did for the CQN analyzer — CAP will inject the persistence service automatically.

```java
private final PersistenceService db;
private final CqnAnalyzer analyzer;

ProductServiceHandler(PersistenceService db, CdsModel model){
    this.db = db;
    this.analyzer = CqnAnalyzer.create(model);
}
```

Next we have to provide the insert command to the service. As usual, CAP has it’s own syntax for this so let’s take a moment to break it down.

```java
    review.setRating(context.getRating());
    review.setText(context.getText());

    db.run(Insert.into(Reviews_.CDS_NAME).entry(review));
    context.setCompleted();
```

To execute any kind of operation on the database, we use the persistence service method run. The input to run is a CQN query generated by one of several of CAP’s query builders, not surprisingly named Delete, Insert, Select, Upsert, and Update. 

We use Insert here because of course we are inserting a new entry into the database. Each of these query builders then features a method to specify the entity that we’re operating on. The name of the method is different depending on the query builder in order to make the code read like English. As we can see above Insert uses into but Delete would use from.

Next we need to provide the name of the entity. By now you must be familiar with this pattern, but we can get the name using the CDS_NAME property from the generated Reviews_ interface. Next we choose either the entry method to indicate inserting a single entity or the entries method to insert an iterable of multiple entities. Here we use entry.

What these query builders actually do is generate CQN just like the CQN that we extracted from the context object above. We can actually print what it generates to the console to confirm that.

### Step 4: Sending a Response Back to the Frontend
You might have noticed in the last section that after we ran our code, we still got an error, and what’s more if you tried to read all the reviews in the database to find the one we created, it wouldn’t be there. This is because if any error happens during the processing of a request — even after the insert statement has been run on the database — CAP will undo the changes. The request will only be committed in the database if nothing goes wrong. But what went wrong in our case? Let’s look at the message.
```log
Exception marked the ChangeSet 5 as cancelled: Cannot invoke
"com.sap.cds.Result.first()" because "result" is null
```
What this is telling us is that there is something called result and we’re calling a method called “first” on it and it’s result is null. We didn’t write anything like that so it’s a little confusing, but basically the context object contains a value called result which is an instance of Result, which is an iterable. Since our method is expected to return a single entity rather than an array, CAP will call Result.first() to extract that single entity so it can send it back to the front. (Recall that we specified in CDS two parts back in this series that we would be returning an instance of Reviews.) Since CAP is expecting that and it got nothing, it threw the error. 

Let’s fix that now. First, we have to save the result of the database query in a variable. You can do that like this (you’ll need to import Result from com.sap.cds.Result):
```java
    CqnInsert reviewInsert = Insert.into(Reviews_.CDS_NAME).entry(review);
    Result savedReview = db.run(reviewInsert);
```
Next we need to convert our Result to a Review or else we’ll get a type error since the return type is Reviews. Luckily Result provides with some methods that will easily convert our result to any type. The three I want to introduce now are list, first, and single. List will return our results as a list of the given class that we provide as an input. first and single will both return the first element from the Result as the given type, but single will throw an error if there is more than one item in the Result. It’s therefore the best one to use when you only expect one item to be returned from the database — you can catch some possible bugs this way.

Finally, instead of finishing the method with context.setCompleted(), which is used to tell CAP that the processing is done without providing any result (which will throw an error in our case because we specified one in the CDS), we’ll instead use the context object’s setResult method to pass the result back out.

```java
   public void addReview(AddReviewContext context){

        CqnSelect select = context.getCqn();
        String productId = (String) analyzer.analyze(select).targetKeys().get(Products.ID);
        
        Reviews review = Reviews.create();
        review.setProductId(productId);
        review.setTitle(context.getTitle());
        review.setRating(context.getRating());
        review.setText(context.getText());

        CqnInsert reviewInsert = Insert.into(Reviews_.CDS_NAME).entry(review);
        Reviews newReview = db.run(reviewInsert).single(Reviews.class);

        context.setResult(newReview);
    }
```


## Part 11: Adding a custom action to a Fiori Elements page, problems with the sample app’s implementation

### Step 1: Defining the Add Review Button inCDS

The Add Review button exists as a column of the table, so we need to define it as column like we did for the other data in the table — by adding another item to the LineItem annotation. It’ll look like this below:

```cds
{
    $Type:'UI.DataFieldForAnnotation',
    Target:'@UI.FieldGroup#AddReview'
}  
```
You’ll notice that, like the Rating field above, we need to specify the type as `UI.DataFieldForAnnotation`. Without this, we would get the default type of `DataField`, which simply displays a value; `DataFieldForAnnotation` says that we
will define was goes here using a different annotation. 

We specified that annotation using the Target property, `UI.FieldGroup#AddReview`. The part before the hashtag specifies what type of annotation will contain the information about the target; the part after the hashtag specifies the name of
the annotation, which will be provided by us. 

Notice also that we didn’t provide a label annotation, which would ordinarily give us a column label. This is because for some reason Fiori Elements ignores the label property for this kind of LineItem, so there’s no need to include it. Just trying to start up the application now will lead to an error though because we haven’t defined the FieldGroup yet. Let’s do that now.

```cds
    FieldGroup #AddReview : {Data:[{
        $Type: 'UI.DataFieldForAction',
        Label: 'Add Review',
        Action: 'ProductService.addReview',
        InvocationGrouping: #Isolated
        }]
    },
```

In the same file we add the `FieldGroup` annotation followed by `#AddReview`. Now our annotation from above has something to find. Next we provide an object with one attribute: `Data`. 

Data consists of an array of objects with the properties $Type, Label, Action, and InvocationGrouping. We could presumably add as many of these objects as we like, for example to add multiple buttons to this single column. We only need one here, however so we’ll leave it at that. 

As a *type* we specify `UI.DataFieldForAction`. This tells Fiori Elements that this button is going to be linked to an oData action like the one we defined in the last few episodes of this series. *Label* describes what the text of the button that this will generate will be. This is different from the LineItem label, which determines what the label for a column will be. Next we specify `Action` as <NameOfService>.<NameOfAction>, so `ProductService.addReview`. 

Finally, we set the `InvocationGrouping` to `#Isolated`. What this does is specify the error handling of this action. Isolated means if multiple actions are executed at once and one of them fails then the others should still be allowed to complete. 

We could also choose `ChangeSet` to specify that if one fails they should all fail. In our case we don’t need the ChangeSet behavior since we aren’t firing off a set of these actions at the same time. Let’s take a look at the result And we can even click the button to display a form for to input the rating information.

Notice that there’s something we’re still missing here: the field labels are all just the names of the variables. We should provide proper labels for them. Let’s do that. Go to annotation.cds and add the following lines:

```cds
annotate ProductService.Products actions{
    addReview(rating @title : 'Rating',title @title : 'Title',text @title : 'Text')
}
```

Now go ahead and try adding a Review. It works…kind of. But we have some problems. Let’s talk about them.

### Step 2: Problems With the Sample App’s Implementation
#### Problem 1: The Rating Field Input
The UI is just not good for our purposes here. We have a 0–5 rating system, but the user can type in anything they want. Such a limited number of options would be better served by a radio button group or a dropdown menu. Here though the user is left to just type in values and see what works. Luckily, thanks to the input types we specified, at the very least we do get an a validation error if we type in a non-integer value.

Even though we specified our enum type as an input, look what happens when we input a number that’s out of range for eg 400. What’s the deal? Well, if we check how the CDS compiles to edmx, we can find the answer (run `cds compile srv/productservice.cds --to edmx`):


## Part 12: Adding a custom components to Fiori Elements, basic SAPUI5 dialog setup

### Step 1: Setting Up a SimpleComponent and Adding into the UI

Next, let’s create some space for our custom components. First make a folder called `custom` inside *webapp*. This will hold all custom components that we make. Since we might make more in the future we’ll make a second subfolder called `AddReview` to hold the files related to this add review action. Finally, create two files, one called `AddReviewButton.fragment.xml` and `AddReviewButtonHandler.js`. 

The former will contain the xml UI specification for the button and the latter will contain the logic. Note that the `.fragment` in the name is important! We need to use a fragment in an extension point.


Now let’s put in just enough filler code so we have something to insert into the UI to confirm that everything is working as expected. First, in AddReviewButton we’ll define a simple SAPUI5 button:

```xml
<core:FragmentDefinition
	xmlns:core="sap.ui.core"
	xmlns="sap.m"
	xmlns:l="sap.ui.layout">
	<l:VerticalLayout
		core:require="{handler: 'ushop/custom/AddReview/AddReviewButtonHandler'}">
		<Button
			text="Add Review"
			press="handler.openDialog" />
	</l:VerticalLayout>
</core:FragmentDefinition>
```
- Just as a brief explanation, we are using the `FragmentDefinition` component to define a fragment. 
- The attributes of this element are simply establishing aliases for the SAPUI5 modules used in this component so we don’t have to type them all out.
- Next we provide a `VerticalLayout` from the layout module and within that we require our CustomColumn.js file so we can use the logic we write there in this file. Check [here](https://sapui5.hana.ondemand.com/sdk/#/api/sap.ui.layout.VerticalLayout%23overview) for more information about *VerticalLayout*.
- Finally, we provide a `Button` component, with a text attribute for the text we want to display in the button and a `press` attribute that directs to a method called onPress from our `AddReviewHandler.js` file. 

We’ll define this next.

```js
sap.ui.define(["sap/m/MessageBox"], function (MessageBox){
    "use strict";

    return {
        onPress: function(){
            MessageBox.show("ButtonPressed");
        },
    };
})
```

Here we import the `MessageBox` component (the syntax is from jQuery so check that if you’re unsure what the above is doing). We’re going to delete this later but we just want to use it here to confirm that our files are linked. We return an object with our onPress function that opens the MessageBox and displays *“Button pressed!”*. For more info on the MessageBox, check this [documentation](https://sapui5.hana.ondemand.com/sdk/#/api/sap.m.MessageBox).

Now we need to actually insert this button into the UI. We’ll do that in our manifest.json file. Go down through the file to where we defined our ListReport page. From there, locate the settings object and add in the following code:

```json
     "targets": {
        "ProductsList": {
          "type": "Component",
          "id": "ProductsList",
          "name": "sap.fe.templates.ListReport",
          "options": {
            "settings": {
              ...
              "controlConfiguration":{
                "@com.sap.vocabularies.UI.v1.LineItem":{
                  "columns" :{
                    "AddReviewColumn":{
                      "header":"Add Review",
                      "template":"usy.products.custom.AddReview.AddReviewButton"
                    }
                  }
                }
              },
```
Now, if we boot up the app we’ll see our button and we can click it to confirm that our handler file is properly linked.

Good deal! We have our custom component working. Next we need to actually implement the logic for this action. Let’s get  to it.


