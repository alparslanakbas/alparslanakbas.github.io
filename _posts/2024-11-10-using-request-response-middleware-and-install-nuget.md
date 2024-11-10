---
title: What is Request Response Middleware And How is Install ?
date: 2024-11-10 17:46 +0300
categories: [Blog, Tutorial, AspNetCore, Dotnet8, Nuget]
tags: [Blog, Tutorial, AspNetCore, Dotnet8, Middleware]
---

## Using RequestResponse Middleware and Testing Methods
Hello, in this blog post, we will explain step-by-step how to use our newly released RequestResponse Middleware package, the features it offers, and how you can test it in your Web API projects. This post will be especially helpful for ASP.NET Core developers and will show you how to use your middleware effectively. Reading time: 3-5 minutes.

## What is RequestResponse Middleware?

RequestResponse Middleware is a library that allows detailed logging of HTTP requests and responses in ASP.NET Core applications. It provides developers with a powerful tool to monitor the performance of their applications, debug issues, and analyze system events more efficiently. This middleware collects detailed information about HTTP requests and responses and can be configured to log these or handle them with a custom handler.

![Desktop View](/assets/img/posts/request-with-middleware.PNG)
_Road-Map_

## Getting Started

### Installation
Adding the middleware to your project is quite simple. First, add the package to your project via NuGet. You can do this using the .NET CLI:
```bash
dotnet add package CD.RequestResponse.Middleware
```
Or, you can add it using the NuGet package manager.

Also you can visit nuget.org my package:
[Nuget Package](https://www.nuget.org/packages/CD.RequestResponse.Middleware)

### Usage
To integrate this middleware into your Web API project, simply add the following lines to your **Program.cs** file:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddHttpClient();

var app = builder.Build();

// Use the RequestResponse Middleware
app.AddRequestResponseMiddleware(opts =>
{ 
    opts.UseHandler(async context =>
    {
        // You can use what do you need
        Console.WriteLine("--Handler--\n");
        Console.WriteLine($"Request: {context.Request}");
        Console.WriteLine($"Response: {context.Response}");
        Console.WriteLine($"Timer: {context.FormatedRequestTime}");
        Console.WriteLine($"Url: {context.Url}");
        Console.WriteLine($"Status Code: {context.StatusCode}");
        Console.WriteLine($"Method: {context.Method}");
        Console.WriteLine($"HTTP Version: {context.HttpVersion}");
        Console.WriteLine($"Client IP Address: {context.ClientIPAddress}");
        Console.WriteLine($"External IP Address: {context.ExternalIPAddress}");
        Console.WriteLine($"User Agent: {context.UserAgent}");
        Console.WriteLine($"Cookies: {context.Cookies}");

        await Task.CompletedTask;
    });

    
    opts.UseLogger(app.Services.GetRequiredService<ILoggerFactory>(), opts =>
    {
        // Select log level type
        opts.LogLevel = LogLevel.Error;
        opts.LoggerCategoryName = "RRM-Api-Test";

        // You can use what do you need
        opts.LoggingFields = 
                         RRM_Library.Models.LoggingOptions.LogFields.Request |
                         RRM_Library.Models.LoggingOptions.LogFields.Response |
                         RRM_Library.Models.LoggingOptions.LogFields.ResponseTime |
                         RRM_Library.Models.LoggingOptions.LogFields.StatusCode |
                         RRM_Library.Models.LoggingOptions.LogFields.HostName |
                         RRM_Library.Models.LoggingOptions.LogFields.Path |
                         RRM_Library.Models.LoggingOptions.LogFields.QueryString 
                         ;
    });
});

app.MapGet("/GetUserInfo/{id}", (int id, ILogger<Program> logger) =>
{
        var response = new UserLoginResponseModel
        {
            Success = true,
            UserEmail = "alparslan@gmail.com"
        };
        logger.LogInformation("User info is requested");
        return Results.Ok(response);
})
.WithName("GetUserInfo")
.WithOpenApi();

app.Run();

internal class UserLoginRequestModel
{
    public string Username { get; set; }
    public string Password { get; set; }
}

internal class UserLoginResponseModel
{
    public bool Success { get; set; }
    public string UserEmail { get; set; }
}
```
With this configuration, every HTTP request and response will be logged, and logs will be managed according to the log level and category you specify.


## Detailed Feature Usage

### Logging Features
**RequestResponse Middleware** makes logging of HTTP requests and responses highly customizable. For example, you can specify which fields you want to log using **LoggingFields**:

* Request: Request body and headers.

* Response: Response content and headers.

* StatusCode: Response status code (e.g., 200, 404).

* ResponseTime: Time between the request and response.

These fields are very useful for analyzing performance issues and gaining deeper insights into your application.

In addition to defining what you want to log, you can also configure logging behavior using the **UseLogger** method:

```csharp
opts.UseLogger(app.Services.GetRequiredService<ILoggerFactory>(), opts =>
{
    opts.LogLevel = LogLevel.Error;
    opts.LoggerCategoryName = "RRM-Api-Test";

    opts.LoggingFields = 
                     RRM_Library.Models.LoggingOptions.LogFields.Request |
                     RRM_Library.Models.LoggingOptions.LogFields.Response |
                     RRM_Library.Models.LoggingOptions.LogFields.ResponseTime |
                     RRM_Library.Models.LoggingOptions.LogFields.StatusCode |
                     RRM_Library.Models.LoggingOptions.LogFields.HostName |
                     RRM_Library.Models.LoggingOptions.LogFields.Path |
                     RRM_Library.Models.LoggingOptions.LogFields.QueryString;
});
```

With **UseLogger**, you can:

* Set Log Level: Use **LogLevel** to determine the severity of the logs (e.g., Error, Information, Debug). This allows you to filter logs based on their importance.

* Specify Logger Category: The **LoggerCategoryName** allows you to define a category for your logs, making it easier to distinguish and filter logs in a complex application.

* Customize Logging Fields: The **LoggingFields** property allows you to define exactly which parts of the request and response you want to log. You can choose any combination of fields, such as request body, response body, headers, status code, etc.

This makes it easy to use your existing logging infrastructure, such as console logging, debugging tools, or third-party logging services like Serilog or NLog, to capture request and response details.

For example, if you have set up your logging configuration as follows:
```csharp
services.AddLogging(configure => 
{
    configure.AddConsole();
    configure.AddDebug();
    configure.AddEventLog();
});
```

You can simply use **UseLogger** with this logging configuration, and all request-response logs will be directed to the configured log providers. This makes it easy to integrate the middleware with your existing logging tools, whether they are console-based or more sophisticated logging services.


### Using Handlers
In addition to logging, you can define a handler function to perform custom operations using the **UseHandler** method:

```csharp
options.UseHandler(async context =>
{
    Console.WriteLine("--Request and Response Details--\n");
    Console.WriteLine($"Request URL: {context.Url}");
    Console.WriteLine($"Status Code: {context.StatusCode}");
    Console.WriteLine($"Response Time: {context.FormatedRequestTime}");
    Console.WriteLine($"Request Method: {context.Method}");
    Console.WriteLine($"HTTP Version: {context.HttpVersion}");
    Console.WriteLine($"Client IP Address: {context.ClientIPAddress}");
    Console.WriteLine($"External IP Address: {context.ExternalIPAddress}");
    Console.WriteLine($"User Agent: {context.UserAgent}");
    Console.WriteLine($"Cookies: {context.Cookies}");
    await Task.CompletedTask;
});
```

This handler is called after every HTTP request and response, allowing you to apply your own logic beyond logging. For example, you can use this function if you want to take a specific action under certain conditions. Additionally, with this handler, you can access many details about the request and response:

* Request Method: Request method (GET, POST, etc.).

* HTTP Version: HTTP protocol version.

* Client IP Address: IP address of the requesting client.

* External IP Address: External IP address (e.g., behind a proxy).

* User Agent: Browser information of the requesting client.

* Cookies: Cookies sent with the request.

These details allow you to analyze requests more thoroughly and create custom business logic if needed.


## API Testing
When using this middleware in your API, you may want to ensure that the logging or handler functionality is working correctly. Here are a few steps to perform these tests:

1. Unit Tests: Test the middleware configuration in your **Program.cs** file within a unit test to ensure that logs are being created correctly.

2. Testing with Postman or Insomnia: Make different requests (GET, POST, PUT) and verify that the response times and log outputs are as expected.

3. Mock Log Providers: Use **ILoggerFactory** to add mock log providers to ensure that logs are passing through the middleware correctly and giving the expected results.


## Summary and Conclusion
RequestResponse Middleware makes it easier to manage HTTP requests and responses in your ASP.NET Core projects, thereby streamlining the development and debugging process. By using this package in your projects, you can standardize logging operations and establish a more efficient monitoring structure.

If you have any questions or suggestions about this package, feel free to leave a comment or reach out via our GitHub page.

[Github Repository](https://github.com/alparslanakbas/request-response-nuget-package)

We look forward to seeing how you use this middleware to enhance your projects. 😊

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_

