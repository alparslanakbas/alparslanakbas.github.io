---
title: Rate Limiting in .NET An Essential Tool for Network Traffic Management
description: "A hands-on guide to ASP.NET Core's rate limiting middleware — the four built-in algorithms, per-client partitioning, custom rejection responses, and a runnable example."
date: 2024-07-11 20:40 +0300
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-7, rate-limiting, middleware, partitioning]
image:
  path: /assets/img/posts/dotnet7-how-to-use-rate-limitter/cover.webp
  alt: 'Title card: Rate Limiting in .NET'
---

## What is Rate Limiting?

In computer networking, rate limiting is a technique used to control the rate at which requests are sent to or processed by a server. It's one of the simplest, highest-leverage things you can add to a public API — it protects against denial-of-service traffic, stops runaway scraping, and keeps one noisy client from starving everyone else. It's a close cousin of [caching](/posts/what-is-caching/) in that sense: both exist to keep load off your backend before it becomes a problem, just from opposite directions — caching reduces the requests that need to do real work, rate limiting caps how many get through in the first place.

ASP.NET Core got a first-party rate limiting middleware in .NET 7 (`Microsoft.AspNetCore.RateLimiting`), and the API has stayed stable through .NET 8, 9, and 10 — no breaking changes, just a few additions along the way (built-in metrics, mainly). Everything in this post still applies if you're on .NET 10 today.

![Desktop View](/assets/img/posts/rate-limitter-schema.webp)
_Rate limiter schema_

## Rate Limiter Algorithms

There are four built-in algorithms. The fixed window, sliding window, and token bucket limiters all cap the number of requests over a time period; the concurrency limiter caps how many requests can run *at the same time*, regardless of how long each one takes. Which one you want depends on the cost of the endpoint — a cheap read and an expensive report export shouldn't necessarily use the same policy.

### Fixed Window Limiter

The simplest of the four: a fixed time window, a maximum number of requests within it, and a hard reset when the window expires.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("Window", _options =>
    {
        _options.Window = TimeSpan.FromSeconds(12); // The policy is effective every 12 seconds.
        _options.PermitLimit = 5; // A maximum of 5 requests can be made within the 12-second window.
        _options.QueueLimit = 5; // After accepting 5 requests, queue the next 5 requests.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Process requests in the order they were received.
    });
});

app.UseRateLimiter();
```

**Explanation**
* `Window`: The time frame during which the rate limit policy is applied. Here it's 12 seconds.
* `PermitLimit`: The maximum number of requests allowed within the window. Here, 5 requests per 12 seconds.
* `QueueLimit`: How many additional requests can be queued once the limit is reached, rather than rejected outright.
* `QueueProcessingOrder`: The order queued requests are processed in — `OldestFirst` processes the earliest-queued request first.

Apply the policy to a controller or endpoint with the `[EnableRateLimiting]` attribute (or `.RequireRateLimiting("Window")` on a minimal API endpoint):

```csharp
[EnableRateLimiting("Window")]
```

**The catch:** a fixed window can let through up to 2x the intended limit right at the window boundary — a burst just before the window resets, followed immediately by another burst right after. The sliding window limiter exists specifically to fix that.

### Sliding Window Limiter

The sliding window limiter improves on the fixed window by dividing each window into segments and tracking requests per segment, rather than resetting the whole counter at once.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddSlidingWindowLimiter("Sliding", _options =>
    {
        _options.Window = TimeSpan.FromSeconds(12); // The policy is effective every 12 seconds.
        _options.PermitLimit = 5; // A maximum of 5 requests can be made within the 12-second window.
        _options.QueueLimit = 5; // After accepting 5 requests, queue the next 5 requests.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Process requests in the order they were received.
        _options.SegmentsPerWindow = 5; // The window is divided into 5 segments.
    });
});

app.UseRateLimiter();
```

**How it works:** the 12-second window is split into 5 segments of 2.4 seconds each. As each segment expires, the requests it used are added back to the available pool for the current segment — instead of the whole window resetting to zero all at once, capacity trickles back in gradually. That's what smooths out the boundary-burst problem the fixed window has.

```csharp
[EnableRateLimiting("Sliding")]
```

### Token Bucket Limiter

Rather than tracking a rolling window, the token bucket limiter maintains a bucket of tokens that refills at a fixed rate. Every request consumes a token; if the bucket is empty, the request is queued or rejected.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddTokenBucketLimiter("Token", _options =>
    {
        _options.TokenLimit = 4; // The total number of tokens available.
        _options.TokensPerPeriod = 4; // The number of tokens generated per period.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Process queued requests in the order they were received.
        _options.QueueLimit = 2; // After consuming the tokens, queue the next 2 requests.
        _options.ReplenishmentPeriod = TimeSpan.FromSeconds(12); // The period over which tokens are replenished.
    });
});

app.UseRateLimiter();
```

**Explanation**
* `TokenLimit`: The maximum number of tokens the bucket can hold — the size of the burst you're willing to absorb in one go.
* `TokensPerPeriod` / `ReplenishmentPeriod`: How many tokens get added back, and how often. Here, 4 tokens every 12 seconds.
* `QueueLimit` / `QueueProcessingOrder`: Same meaning as the other limiters.

```csharp
[EnableRateLimiting("Token")]
```

This is the one to reach for when you want to allow occasional bursts (a client that's normally quiet but occasionally sends a handful of requests at once) without raising the sustained average rate.

### Concurrency Limiter

The odd one out — it doesn't care about *how many requests over time*, only *how many are in flight right now*. Useful for protecting an endpoint that does something genuinely expensive (a report generation, a large file upload) where the cost is tied up in how long each request takes, not how often they arrive.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddConcurrencyLimiter("Concurrency", _options =>
    {
        _options.PermitLimit = 5; // The maximum number of concurrent requests.
        _options.QueueLimit = 2; // After accepting 5 requests, queue the next 2 requests.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Process queued requests in the order they were received.
    });
});

app.UseRateLimiter();
```

A request takes a permit when it starts and releases it when it finishes — so a slow request holds its slot the whole time it's running, unlike the other three limiters which only care about the request *count*.

```csharp
[EnableRateLimiting("Concurrency")]
```

## Putting It Together: A Minimal API You Can Actually Run

Everything above is a policy definition in isolation. Here's the whole thing wired into a real, runnable minimal API — from `dotnet new` to watching it actually reject a request.

```bash
dotnet new webapi -n RateLimitDemo -minimal
cd RateLimitDemo
```

Replace `Program.cs` with:

```csharp
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", opt =>
    {
        opt.PermitLimit = 3;
        opt.Window = TimeSpan.FromSeconds(10);
        opt.QueueLimit = 0;
    });
});

var app = builder.Build();

app.UseRateLimiter();

app.MapGet("/ping", () => Results.Ok(new { message = "pong", at = DateTime.UtcNow }))
   .RequireRateLimiting("fixed");

app.Run();
```

Run it with `dotnet run`, note the port it prints, then hit it a handful of times in a row from another terminal:

```bash
for i in {1..5}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5000/ping; done
```

You'll see `200` three times, then `429` for the rest — until the 10-second window resets and the limit is available again.

## Rate Limiting Per Client, Not Just Globally

Every example so far shares one limiter across every caller, which is fine for a demo but rarely what you actually want in production — one aggressive client shouldn't be able to eat the entire budget for everyone else. `PartitionedRateLimiter` splits traffic into separate buckets keyed by whatever identifies a "client" to you: user ID, IP address, or API key.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.User.Identity?.Name
                ?? httpContext.Connection.RemoteIpAddress?.ToString()
                ?? "anonymous",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 20,
                Window = TimeSpan.FromMinutes(1)
            }));
});
```

Each distinct partition key gets its own independent counter, so an authenticated user (or IP, for anonymous traffic) gets their own 20-requests-per-minute budget instead of competing with everyone else for a shared one.

One thing worth knowing before you rely on this in production: partitioning purely by client-supplied IP means trusting `RemoteIpAddress`, which can be spoofed. It's a reasonable default behind a properly configured reverse proxy, but it's not a substitute for authentication if you actually need to stop a determined attacker rather than just smooth out normal traffic.

## Customizing the Rejection Response

By default, a rejected request gets a bare `503` with no body. You almost always want something more useful — a `429` with a `Retry-After` header, so well-behaved clients know when it's worth trying again instead of retrying blindly. This is the same idea as [centralizing error handling](/posts/dotnet8-global-error-handling/) with a single handler instead of scattering try/catch blocks everywhere: one place decides what a rejected request looks like, instead of every endpoint reinventing it.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;

        if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
        {
            context.HttpContext.Response.Headers.RetryAfter =
                ((int)retryAfter.TotalSeconds).ToString();
        }

        await context.HttpContext.Response.WriteAsJsonAsync(new
        {
            error = "Too many requests. Please try again later."
        }, cancellationToken);
    };

    // ...your limiters go here, same as before
});
```

`RetryAfter` metadata is only populated by limiters that can actually calculate it — the fixed and sliding window limiters know when their window resets, but the token bucket and concurrency limiters don't set it, since neither has a fixed reset point.

## A Note on Metrics

If you're running this in production, the middleware also emits built-in metrics under `Microsoft.AspNetCore.RateLimiting` (requests leased, queued, and rejected, per policy) that plug into `System.Diagnostics.Metrics` and whatever OpenTelemetry/dashboard setup you already have — worth wiring up before you tune limits based on guesswork instead of real traffic.

## Conclusion

The built-in rate limiting middleware covers the vast majority of real-world cases without reaching for a third-party package or a Redis dependency. Pick an algorithm based on the shape of the traffic you're protecting against, partition it per client if one caller shouldn't be able to starve the rest, and give rejected requests a response that actually tells the caller what to do next.

Hope you found this useful. If you have questions, feel free to reach out on [LinkedIn](https://www.linkedin.com/in/alparslanakbas/).

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks for reading_
