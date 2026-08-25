---
title: Asp.NET Core 8 – Global Error Handling
description: "Global error handling in ASP.NET Core: custom middleware vs. IExceptionHandler, ProblemDetails, and a real diagnostics change in .NET 10."
date: 2024-11-30 22:05 +0300
translation_key: dotnet8-global-error-handling
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-8, error-handling, middleware, problemdetails]
series: "ASP.NET Core Error Handling"
series_order: 2
image:
  path: /assets/img/posts/dotnet8-global-error-handling/cover.webp
  alt: 'Title card: Asp.NET Core 8 - Global Error Handling'
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAAAQAwCdASoYAA0APu1kqU2ppaOiMAgBMB2JZQAAWpcmzMAA/uwRiCRtUcoUJE9JwHoggsSiFLDYWPNgCbWJn/kc5/idSLDlsBmHW987A+Q6y6iLlj/0gdgA"
---

## Introduction

Hello,

No matter how carefully and securely we design our applications, errors—often a natural part of software operation—will inevitably occur. This is especially true for web applications, where such situations can be considered almost unavoidable. However, in a good software development process, the number of potential errors can be minimized, and applications can be made more robust and reliable through proper testing strategies and a fault-tolerant coding approach.

Even with these measures in place, errors will still remind us of their inevitability. Sooner or later, they will surface, whether due to inputs from the external world, database issues at the core of the operation, or countless unknown factors we may never fully understand.

In such cases, we won’t simply say, "We did our best; it was meant to be." Instead, we will manage errors without exposing them to users. We will implement different behaviors to handle errors, performing the necessary manipulations to maintain the desired user experience.

At the same time, we will focus on advancing the process to its most ideal state by tracing and logging where appropriate, ensuring that these critical components of risk management in the software lifecycle are effectively addressed.

In our previous article titled "[Automatically Manage Exceptions in ASP.NET Core](/posts/dotnet8-custom-exceptions/)", we explored and experienced the most effective method among those we can apply for achieving this ideal state.

## Let's Starting

Alternatively, we can adopt an approach to handle all potential errors in the process by using a middleware like the one below.

```csharp
public class ExceptionHandlingMiddleware(ILogger<ExceptionHandlingMiddleware> logger, RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception exception)
        {
            string errorMessage = $"An error occurred. Error message: {exception.Message}";
            logger.LogError(exception, errorMessage);
 
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(new
            {
                Title = "Server Error",
                Status = context.Response.StatusCode,
                Message = errorMessage
            });
        }
    }
}
```

Of course, provided that this middleware is configured as shown below:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
builder.Services.AddLogging();
 
var app = builder.Build();
 
app.UseMiddleware<Global.Error.Handling.Example.Traditional_Method.ExceptionHandlingMiddleware>();
 
app.MapGet("/", () =>
{
    throw new Exception("bla bla bla error...");
});
 
app.Run();
```

As seen, ASP.NET Core provides us with several options to respond to potential error scenarios. In addition to these options, ASP.NET Core 8 introduces the IExceptionHandler interface to manage error situations effectively.

```csharp
public class ExceptionHandler(ILogger<ExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = "Server Error",
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

This interface, as seen in the code block above, enforces the implementation of the TryHandleAsync method. It returns a boolean value: true if a handle exists for the potential error, or false otherwise.

To include this custom exception handler class in the ASP.NET Core request pipeline, the following configuration is sufficient:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
builder.Services.AddLogging();
 
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.ExceptionHandler>();
builder.Services.AddProblemDetails();
 
var app = builder.Build();
 
app.UseExceptionHandler();
 
app.MapGet("/", () =>
{
    throw new Exception("bla bla bla error...");
});
 
app.Run();
```

As seen, on line 5, we use the AddExceptionHandler method to add the relevant service as a dependency to the application. On line 6, we include the AddProblemDetails service to generate a response with details about potential errors. Finally, on line 10, we activate the ExceptionHandlerMiddleware by invoking the UseExceptionHandler middleware.

When we compile and run the application in this state, we can observe that the exception handler class operates during potential error scenarios, as shown below:

```json
{
    "title": "Server Error",
    "status": 500,
    "Message": "An error occurred. Error message: bla bla bla errorr..."
}
```

Additionally, you can include multiple exception handler classes in the application and manage potential error scenarios based on their registration order. For example:

```csharp
public class DivideByZeroExceptionHandler(ILogger<DivideByZeroExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        if (exception is not DivideByZeroException)
            return false;
 
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = exception.GetType().ToString(),
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

```csharp
public class NullReferenceExceptionHandler(ILogger<NullReferenceExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        if (exception is not NullReferenceException)
            return false;
 
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = exception.GetType().ToString(),
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

If you pay attention to the exception handler classes we created here, you’ll notice that the error is evaluated behaviorally. If it is not suitable, a false value is returned, indicating that the exception is not handled by that class. This allows the next handler class to take over, and the process continues until it reaches the handler class that returns true.

For this reason, the handler class that addresses the most general type of error should be defined last, as shown below.

```csharp
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.DivideByZeroExceptionHandler>();
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.NullReferenceExceptionHandler>();
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.ExceptionHandler>();
```

This means that if an error occurs, the DivideByZeroExceptionHandler will be checked first. If it returns false, the NullReferenceExceptionHandler will be checked next. If that also returns false, the ExceptionHandler will be checked last. If any of these return true, the others will not be evaluated. However, if all of them return false, no result will be returned to the user.

I believe that with the IExceptionHandler introduced in ASP.NET Core 8, we can handle error scenarios more effectively and flexibly compared to the middleware approach.

## Update: A Real Breaking Change in .NET 10

Everything above still works exactly as written on .NET 10 — but there's one behavioral change worth knowing about if you're upgrading. Previously, whenever an `IExceptionHandler` handled an exception (returned `true` from `TryHandleAsync`), the middleware *still* recorded diagnostics for it: logging `UnhandledException`, writing a `HandledException` event, and tagging the `http.server.request.duration` metric with `error.type`.

Starting in .NET 10, that stops happening by default. If your handler reports the exception as handled, it's treated as genuinely handled — no more noise in your logs or metrics for errors your code already dealt with. This was a deliberate fix: plenty of people were confused why their "handled" exceptions kept showing up in telemetry anyway.

If you actually want the old behavior back — for example, you're logging inside a catch-all handler and still want the middleware's own diagnostics too — there's an explicit opt-out:

```csharp
app.UseExceptionHandler(new ExceptionHandlerOptions
{
    SuppressDiagnosticsCallback = context => false
});
```

Returning `false` from the callback restores the pre-.NET 10 behavior (diagnostics get recorded); returning `true` (the new default) suppresses them.

## A Modern Companion: ProblemDetails

One thing neither of the two approaches above mention: as of .NET 8, ASP.NET Core has first-party support for [RFC 9457 Problem Details](https://www.rfc-editor.org/rfc/rfc9457) — a standard JSON shape for API error responses (`type`, `title`, `status`, `detail`, `instance`). Wiring it up is one line:

```csharp
builder.Services.AddProblemDetails();
```

Combined with `UseExceptionHandler()` (no custom handler needed for the default case), unhandled exceptions now come back as a consistent, machine-readable `application/problem+json` response instead of whatever ad hoc shape you'd otherwise hand-roll — the same idea as the [custom exception filter](/posts/dotnet8-custom-exceptions/) covered in the earlier post, just standardized across the whole app instead of per-action.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
*Thanks For Reading*
