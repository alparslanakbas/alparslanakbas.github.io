---
title: What is File Logger Middleware And How is Install ?
date: 2024-11-23 22:00 +0300
categories: [Blog, Tutorial, AspNetCore, Dotnet8, Nuget]
tags: [Blog, Tutorial, AspNetCore, Dotnet8, Middleware, Logging]
---

## Introduction
In web development, logging plays a critical role in ensuring APIs work as expected. Logs help simplify the debugging process and provide detailed information about system operation. In this post, we will explore the newly released **CD.File-Logger.Middleware** package, which makes logging easier and more effective. This library helps you log HTTP requests and responses more efficiently by saving them to a file.

## What is File Logger Middleware and Why Should You Use It?
**CD.File-Logger.Middleware** is an extension package for ASP.NET Core applications that enables logging HTTP request and response data into a file. This library can be particularly useful in cases where you need detailed tracking during intensive operations.
* **Persistent Logging**: Save logs to disk for later analysis.
* **Ease of Analysis**: Easily identify performance issues and errors through saved logs.
* **Error Tracking**: Recorded logs make the error analysis process more transparent, especially during debugging.

## How to Install?
To use this library, you need to install **CD.File-Logger.Middleware** packages.

```bash
dotnet add package CD.File-Logger.Middleware
```

### Usage
Once the packages are installed, you can configure the middleware in your Program.cs file. Below is an example that shows how to use the file logging middleware with **CD.RequestResponse.Middleware**.

```csharp
using Microsoft.Extensions.Logging;
using RRM_File_Logger.Library;
using RRM_Library;

var builder = WebApplication.CreateBuilder(args);

// Add Logging
builder.Services.AddLogging(opts =>
{
    opts.AddConsole();
});

// Add HttpClient
builder.Services.AddHttpClient();

var app = builder.Build();

// Adding RequestResponse Middleware with File Logger Middleware
app.AddRequestResponseMiddleware(opts =>
{
    opts.UseHandler(async context =>
    {
        Console.WriteLine("--Handler--
");
        Console.WriteLine($"Request: {context.Request}");
        Console.WriteLine($"Response: {context.Response}");
        await Task.CompletedTask;
    });
});

app.AddRequestResponseFileLoggerMiddleware(opts =>
{
    // You can specify the file path you want.
    opts.FileDirectory = AppDomain.CurrentDomain.BaseDirectory;
    opts.FileName = "alparslan_log";
    opts.Extension = ".txt";
    opts.UseJsonFormat = true;
    opts.ForceCreateDirectory = true;
});
```

## Parameters and Configurations
The **AddRequestResponseFileLoggerMiddleware** extension method allows you to configure the file logger options as follows:
* **FileDirectory**: Specify the directory where the log files will be saved.
* **FileName**: Set the base name of the log file.
* **Extension**: Set the extension of the log file (e.g., .txt, .log, .json).
* **UseJsonFormat**: You can select json format type (e.g., true or false)
* **ForceCreateDirectory**: If set to true, the middleware will create the directory if it doesn't exist.

## Example Logging Output
Once the middleware is integrated, it will log each request and response to the specified file directory. Below is an example of what a log file might look like:
```csharp
datetime: 18.11.2024 13:25:30 - [GET /api/test] [200 OK] [Request Time: 00:00:01.025]
Request: ...
Response: ...
```
## Conclusion
**CD.File-Logger.Middleware** is a handy library for logging HTTP requests and responses in ASP.NET Core applications. It is especially useful for error tracking and performance monitoring. By integrating this library into your application, you can strengthen your logging infrastructure and make your debugging processes smoother.

If you have any questions or suggestions about this package, feel free to leave a comment or reach out via our GitHub page.

[Github Repository](https://github.com/alparslanakbas/request-response-nuget-package/tree/main/Request-Response-Middleware-Solition/RRM-File-Logger.Library)

We look forward to seeing how you use this middleware to enhance your projects. 😊

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_