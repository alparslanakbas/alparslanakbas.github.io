---
title: Asp.NET Core 8 Automatically Handle Exceptions
date: 2024-11-30 21:40 +0300
categories: [Blog, Tutorial, Dotnet8]
tags: [Blog, Tutorial, AspNetCore, Dotnet8]
---

## Introduction
Hello,

If you are developing APIs in Asp.NET Core, I'm sure the following structure will seem quite familiar to you:

```csharp
public IActionResult Get(Guid id)
{
    var product = _productService.GetById(id);
    if (product is null)
        return NotFound();
    return Ok(product);
}
```

When you take a look at this code, can you see anything wrong? Not really, right? We see an action that simply queries a product based on its id and returns the relevant object if it arrives, otherwise it returns an error with 'NotFound'. This may seem like perfectly natural coding. And it is. However, checking for the absence of such objects in every action and constructing our code according to the result of this check will mean that we are constantly repeating ourselves, won't it? Also, in such a case, if we want to log when an object comes back null, won't we have to write the same code separately in each operation?


Moreover, in this operation, wouldn't it be misplaced and absurd for the service acting as the business layer to carry the problem control to a different layer, the controller, when no object comes back as a result of querying for the relevant id? Ultimately, it would be more appealing for the layer running the business logic to warn the architecture by throwing an exception when no object is found for the incoming id, right?

So we should question removing the object check from this code and also making such situations that will cause us to repeat ourselves more central... But how will we do that? The answer: Action Filters, one of the veins of the Asp.NET Core architecture...

## What exactly is a 'Filter' in Asp.NET Core?
Filters in Asp.NET Core are one way to run any code before or after certain stages of the request pipeline. In the C# language, these filters are designed as attributes. Although there are many filters in Asp.NET Core, as mentioned above, the filter that will be triggered according to the thrown exception is **ExceptionFilterAttribute**.
Now, let's quickly implement a simple example.

'Product' entity:
```csharp
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }
}
```

'ProductService' class and 'IProductService' interface:
```csharp
public interface IProductService
{
    Product GetById(Guid id);
}
public class ProductService : IProductService
{
    List<Product> _products = new()
    {
        new() { Id = Guid.NewGuid(), Name = "Book" },
        new() { Id = Guid.NewGuid(), Name = "Pencil" }
    };
    public Product GetById(Guid id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        return product;
    }
}
```

So far, the only thing we need is to check whether any object corresponding to the relevant id comes in the 'GetById' method of 'ProductService' and throw an error if it does not come. For this, it is beneficial to design the exception to be thrown as custom.

```csharp
public class DataNotFoundException : Exception
{
    public DataNotFoundException(string type, object id) 
        : base($"The object with id {id} of type {type} was not found!") { }
}
```
And now we can perform the mentioned control in the 'GetById' function:
```csharp
public Product GetById(Guid id)
{
    var product = _products.FirstOrDefault(p => p.Id == id);
    if (product is null)
        throw new DataNotFoundException(nameof(Product), id);
    return product;
}
```


## Creating a Custom ExceptionFilterAttribute
As designed above, an error will be thrown if there is no object corresponding to the id. Therefore, we need to create the filter that will be activated in response to this error as custom.
```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class ExceptionFilter : ExceptionFilterAttribute
{
    public async override Task OnExceptionAsync(ExceptionContext context)
    {
        //When we don't know the status code of the thrown exception  
        //we set '500 Internal Server Error' as default.
        var statusCode = HttpStatusCode.InternalServerError;
 
        //If the thrown exception is DataNotFoundException
        //we make the status code '404 Not Found'.
        if (context.Exception is DataNotFoundException)
            statusCode = HttpStatusCode.NotFound;
 
        //We can return by changing the status code and 
        //result to the response to be given to this request.
        context.HttpContext.Response.ContentType = "application/json";
        context.HttpContext.Response.StatusCode = (int)statusCode;
 
        context.Result = new JsonResult(new
        {
            error = new[] { context.Exception.Message },
            statusCode = (int)statusCode,
            stackTrace = context.Exception.StackTrace  
        });
    }
}
```

As seen, our action filter that will come into play during an error is as above. Of course, this can be customized further, but for now we will be content with this. Now the only thing left is to inform the Asp.NET Core architecture about this created filter. For this, we can choose two different methods.

### 1. Method - Adding as a Global Filter
In order to add a filter globally, it is sufficient to declare it in the 'AddControllers' service in the 'Program.cs' file as follows.

```csharp
        builder.Services.AddControllers(options => options.Filters.Add(typeof(ExceptionFilter)));
        .
        .
        .
    .
    .
    .
```
Globally added filters are triggered in all action situations specific to their type. Therefore, if you want to use a filter only in customized situations, you should prefer the 2nd method.

### 2. Method - Adding as an Attribute Based on Controller or Action
The created filter is essentially an attribute, so it can also be used this way.

```csharp
[HttpGet("{id}")]
[ExceptionFilter]
public IActionResult Get(Guid id)
{
    var product = _productService.GetById(id);
    return Ok(product);
}
```
This usage enables us to display a structurally more preferable behavior and prevents the relevant filter from being triggered from unnecessary places.

## Let's Test
That's it... Now all we have to do is test by sending a request to this API.
```text
/api/Products/1 then /api/Products/10
```
![Desktop View](/assets/img/posts/test-api-1.PNG)
_Success-Test_

![Desktop View](/assets/img/posts/test-api-2.PNG)
_Error-Test_

As you can see, we have centralized the control responsibility of the data to be produced in the business logic through a filter and prevented code waste that may arise due to the need in the next actions.

It is also obvious that it is a more professional approach.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_

