---
title: Rate Limiting in .NET An Essential Tool for Network Traffic Management
date: 2024-07-11 20:40 +0300
categories: [Blog, Tutorial, AspNetCore]
tags: [Blog, Tutorial, Rate-Limitter, AspNetCore, Dotnet7]
---

## What is the Rate Limitter

In computer networking, rate limiting is a technique used to control the rate at which requests are sent or received by a network interface controller. This can be crucial for preventing Denial of Service (DoS) attacks and limiting web scraping activities. Traditionally, .NET developers had to implement their own rate limiting mechanisms, but now there's a new library that simplifies this process.

What is Rate Limiting?

Rate limiting is a strategy for controlling the amount of incoming or outgoing traffic to or from a network. It is commonly used to:

* Prevent DoS Attacks: By limiting the number of requests that a client can make within a specified time frame, you can protect your server from being overwhelmed by malicious traffic.
* Limit Web Scraping: By controlling the rate at which a client can access your web resources, you can prevent excessive data scraping, which can degrade the performance of your web services.

![Desktop View](/assets/img/posts/rate-limitter-schema.jpeg)
_Rate Limitter Schema_


## Rate Limiter Algorithms, What Are They and How to Use Them?

Rate limiter algorithms are essential tools for controlling the rate at which a resource (such as an API endpoint) is accessed. They help to prevent abuse and ensure fair usage by capping the number of requests a user or client can make within a specific period. Here’s an overview of common rate limiter algorithms and how to use them:
* Fixed Window
* Sliding Window Log

### Fixed Window Limiter (An algorithm that limits requests using a fixed time window)

First, we write our code above in the Program.cs file. Then, we navigate to our Controller page. Under the Namespace, we need to specify which rate limiter we will use because more than one rate limit can be defined.

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

1. Explanation
* Window: The time frame during which the rate limit policy is applied. In this example, it's set to 12 seconds.
* PermitLimit: The maximum number of requests allowed within the specified time window. Here, it's set to 5 requests per 12 seconds.
* QueueLimit: The number of additional requests that can be queued after the permit limit is reached. In this case, up to 5 additional requests can be queued.
* QueueProcessingOrder: Specifies the order in which queued requests are processed. OldestFirst ensures that the earliest requests in the queue are processed first.

2. Steps to Implement
- Add the Rate Limiter Configuration:
 * The configuration above should be added to the Program.cs file.

- Specify the Rate Limiter in the Controller:
 * Navigate to the controller page and, under the Namespace, specify which rate limiter will be used. This is essential as multiple rate limits can be defined and used within the application.

 ```csharp
 [EnableRateLimiting("Window")]
 ```

By following these steps, you can effectively control the rate of requests to your application, helping to prevent DoS attacks and limit web scraping activities. This new .NET library simplifies the process, making it easier for developers to implement robust rate limiting strategies.

### Sliding Window Limiter, An Advanced Rate Limiting Algorithm
A Sliding Window Limiter is a more sophisticated rate limiting algorithm that improves upon the Fixed Window Limiter by allowing requests to be distributed more evenly over time. It does this by breaking down the fixed time window into smaller segments and tracking the request count in each segment. This approach allows for a smoother and more granular control over the rate of requests.

Benefits of Sliding Window Limiter
1. Smooth Rate Limiting
* Unlike the fixed window limiter, which can cause sudden spikes in allowed requests, the sliding window limiter provides a more even distribution of requests over time.
2. Better Accuracy
* By breaking down the time window into smaller segments, the sliding window limiter can more accurately enforce rate limits.
3. Flexibility
* It allows for more flexible rate limiting policies that can adapt to varying traffic patterns.

Here is an example of how to implement a Sliding Window Limiter in a .NET application:
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

1. Explanation
* Window: The total time frame within which the rate limit policy is applied. Here, it's set to 12 seconds.
* PermitLimit: The maximum number of requests allowed within the specified time window. In this example, up to 5 requests can be made in 12 seconds.
* QueueLimit: The number of additional requests that can be queued after the permit limit is reached. Here, up to 5 additional requests can be queued.
* QueueProcessingOrder: Specifies the order in which queued requests are processed. OldestFirst ensures that the earliest requests in the queue are processed first.
* SegmentsPerWindow: The number of segments into which the time window is divided. In this example, the 12-second window is divided into 5 segments.

2. How It Works
The sliding window limiter divides the time window into smaller segments (e.g., if the window is 12 seconds and there are 5 segments, each segment is 2.4 seconds). It tracks the number of requests in each segment. If the number of requests in the current segment plus the requests in the previous segments exceeds the limit, additional requests are queued or denied.

 ```csharp
 [EnableRateLimiting("Sliding")]
 ```

For example, if you set a 12-second window with a 5-request limit and 5 segments, the algorithm will:

* Allow up to 1 request per 2.4-second segment on average.
* If 5 requests are made in the first 6 seconds, no more requests will be allowed until the 12-second window refreshes, but the limiter will check for each smaller segment to allow requests as soon as possible based on the sliding count.

3. Conclusion
* The Sliding Window Limiter provides a more flexible and accurate way to control the rate of requests in your .NET applications. By using smaller segments within the time window, it ensures a smoother distribution of requests and better adheres to rate limiting policies.

This advanced rate limiting mechanism helps in preventing DoS attacks and managing traffic more effectively, ensuring that your application remains responsive and reliable.

By following these steps, you can effectively control the rate of requests to your application, helping to prevent DoS attacks and limit web scraping activities. This new .NET library simplifies the process, making it easier for developers to implement robust rate limiting strategies.


### Token Bucket Limiter, An Efficient Rate Limiting Algorithm

The Token Bucket Limiter is a rate limiting algorithm that uses tokens to control the number of requests that can be processed in a given time period. Tokens are generated at a constant rate and each request consumes a token. If tokens are available, the request is processed; if not, the request is queued or denied.

1. Benefits of Token Bucket Limiter
- Burst Handling: The Token Bucket Limiter can handle burst traffic effectively by allowing a burst of requests to be processed as long as there are enough tokens available.
- Flexibility: This algorithm provides more flexibility compared to fixed window rate limiting, as it allows for short bursts of traffic without exceeding the overall rate limit.
- Simplicity: It is simple to implement and understand, making it a popular choice for many applications.

Here is an example of how to implement a Token Bucket Limiter in a .NET application:
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

1. Explanation
* TokenLimit: The maximum number of tokens that can be available at any given time. Here, it's set to 4.
* TokensPerPeriod: The number of tokens generated in each replenishment period. In this example, 4 tokens are generated every 12 seconds.
* QueueProcessingOrder: Specifies the order in which queued requests are processed. OldestFirst ensures that the earliest requests in the queue are processed first.
* QueueLimit: The number of additional requests that can be queued after the token limit is reached. Here, up to 2 additional requests can be queued.
* ReplenishmentPeriod: The time interval at which tokens are replenished. In this example, tokens are replenished every 12 seconds.

2. How It Works
The Token Bucket Limiter generates a certain number of tokens at a fixed interval (replenishment period). Each incoming request consumes one token. If tokens are available, the request is processed immediately. If no tokens are available, the request is either queued or denied based on the queue limit and queue processing order.

 ```csharp
 [EnableRateLimiting("Token")]
 ```

For example, if you set a token limit of 4 and a replenishment period of 12 seconds with 4 tokens per period, the algorithm will:

* Allow up to 4 requests to be processed immediately.
* Generate 4 new tokens every 12 seconds, replenishing the bucket.
* If more than 4 requests are made within the 12 seconds, the excess requests are queued up to a limit of 2.

3. Conclusion
The Token Bucket Limiter provides an efficient way to control the rate of requests in your .NET applications. By using tokens, it allows for burst traffic while maintaining an overall rate limit, ensuring that your application can handle varying traffic patterns effectively.

This algorithm is particularly useful for scenarios where occasional bursts of traffic are expected, and it ensures that your application remains responsive and reliable.

By following these steps, you can effectively control the rate of requests to your application, helping to prevent DoS attacks and limit web scraping activities. This new .NET library simplifies the process, making it easier for developers to implement robust rate limiting strategies.


### Concurrency Limiter, Controlling Asynchronous Requests

What is a Concurrency Limiter?

A Concurrency Limiter is an algorithm used to limit the number of asynchronous requests that can be processed concurrently. Each request decreases the concurrency limit, and when the limit is reached, additional requests are queued or denied. Once a request is completed, the concurrency limit is incremented, allowing new requests to be processed. This limiter is particularly useful in managing server resources and ensuring that the system remains responsive under high load.

1. Benefits of Concurrency Limiter
- Resource Management: Helps in managing server resources effectively by limiting the number of concurrent requests.
- Prevent Overload: Protects the system from being overwhelmed by too many simultaneous requests.
- Simple Implementation: Easy to configure and integrate into existing systems.

Here is an example of how to implement a Concurrency Limiter in a .NET application:
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

1. Explanation
* PermitLimit: The maximum number of concurrent requests allowed. Here, it is set to 5.
* QueueLimit: The number of additional requests that can be queued once the permit limit is reached. In this example, up to 2 additional requests can be queued.
* QueueProcessingOrder: Specifies the order in which queued requests are processed. OldestFirst ensures that the earliest requests in the queue are processed first.

2. How It Works
The Concurrency Limiter restricts the number of requests that can be processed simultaneously. When a request is received, it consumes one permit. If the number of active requests reaches the permit limit, any additional requests are queued until a permit becomes available. Once a request is completed, the permit is released, allowing the next queued request to proceed.

For example, if you set a permit limit of 5 and a queue limit of 2:

* Up to 5 requests can be processed concurrently.
* Any additional requests beyond these 5 will be queued up to a limit of 2.
* If more than 7 requests are made simultaneously, the excess requests will be denied until permits become available.

3. Conclusion

The Concurrency Limiter is an effective way to control the number of asynchronous requests that can be processed simultaneously in your .NET application. By limiting concurrent requests, it helps manage server resources efficiently and prevents the system from becoming overloaded.

This limiter is particularly useful in scenarios where the server needs to handle a high volume of simultaneous requests while ensuring that the system remains responsive and stable.

By following these steps and using the provided code, you can implement a Concurrency Limiter in your .NET application to manage asynchronous requests effectively. If you have any questions or need further assistance, feel free to reach out!

## Conclusion: Mastering Rate Limiting in .NET

Hope you found this article useful. If you have any questions or feel free to reach out to me on [LinkedIn](https://www.linkedin.com/in/alparslanakbas/).

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_