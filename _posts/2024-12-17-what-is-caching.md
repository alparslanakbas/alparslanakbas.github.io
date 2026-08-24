---
title: "Caching in .NET: The Complete Guide"
description: "A practical guide to caching in .NET: in-memory vs distributed, Output Caching, HybridCache, and a decision table for picking the right one."
date: 2024-12-17 22:15 +0300
categories: [Data, Caching]
tags: [caching, redis, aspnet-core, performance]
series: "Caching & Redis"
series_order: 1
image:
  path: /assets/img/posts/what-is-caching/cover.webp
  alt: 'Title card: Introduction to Caching'
  lqip: "data:image/webp;base64,UklGRloAAABXRUJQVlA4IE4AAACQAwCdASoYAA0APu1oqk6ppiQiMAgBMB2JZQAAWpgEFP0qiC1kAP7sEYgkbVHKExx4p/+8twyfCbOoIVp1qoRaZFqPNKQp1eBWfcmEAAA="
---

## What is Caching?

In modern software applications, especially on the web, as the number of users increases, resource limitations often become a challenge. This can lead to the need for increased system resources, which in turn demands a larger budget due to the associated additional costs.

Alongside the expansion of resource capacity, it is also necessary to reduce the costs that arise from user interactions. For instance, considering just one of the many factors contributing to these costs—database operations—we can observe that billions of data points are transferred between the application and the database based on user requests. This immense energy consumption can over time lead to the database struggling to meet demands, eventually necessitating further investments in database servers.

Caching serves as a strategic solution to optimize resource usage, enhance performance, and minimize such costs.

In such cases, the caching mechanism is utilized to reduce the load on databases and dynamically handle the majority of requests without requiring additional investments.

Caching is a technique where frequently accessed data is stored in alternative locations outside the database. This allows the data to be retrieved and processed more quickly without repeatedly burdening the system for each request.

When caching is implemented correctly at the right place and time, it significantly enhances application performance and scalability. It ensures a consistent user experience by delivering the same performance for 1,000,000 users as it does for 100 users, regardless of the traffic intensity, without requiring additional capacity upgrades.

## Why Should We Use Caching?

Instead of repeatedly retrieving stable data from the database for each request, the data should be cached after the initial query and served from the cache for subsequent requests. This approach provides a significant performance boost for all operations involving **"stable"** data — data that doesn't change on every request, even if it changes occasionally (a product catalog, a user's profile, an exchange rate refreshed hourly).

## Cache Invalidation and Expiration

The fundamental rule to remember is that cached data is a copy of the original data. Modifications to the original data in the database can lead to the cached data becoming stale. If not managed properly, stale data can cause unforeseen issues and application crises. There are two pieces to getting this right:

* **Expiration.** Cached entries need a lifetime. **Absolute expiration** removes an entry a fixed time after it was created, regardless of how often it's read — good for data that changes on a schedule (a daily report, an hourly rate). **Sliding expiration** resets the timer every time the entry is read — good for "still relevant" data that should stay cached as long as someone's actually using it, but disappear once nobody has.
* **Invalidation.** Sometimes you don't want to wait for expiration — the underlying data changed *now*, and the cache needs to know. The simplest approach is to explicitly remove (or overwrite) the cache entry in the same code path that updates the source data. The most common pattern for populating a cache in the first place is **cache-aside**: check the cache, and on a miss, read from the source, store the result in the cache, then return it. Nearly every example in this post — and every helper method in the [In-Memory Cache](/posts/what-is-in-memory-cache/) and [Distributed Cache](/posts/what-is-distributed-cache/) posts — is some variation of cache-aside.

## Types of Caching

Caching can be categorized into two main types: **Local Caching** and **Global Caching**.

* **Local Caching (In-Memory Caching)**
This type of caching operates in the memory space of the machine where the application is running. It is also referred to as **Private Caching**. See **[In-Memory Cache](/posts/what-is-in-memory-cache/)** for how it works and its main drawback in a multi-instance setup.
* **Global Caching (Distributed Caching)**
This caching system is distributed across multiple servers but functions as a unified entity. It is also known as **Public Caching**. See **[Distributed Cache](/posts/what-is-distributed-cache/)** for the full picture, and the **[Redis](/posts/what-is-redis/)** series for the most common real-world implementation.

## Caching in .NET: Which API Do You Actually Need?

.NET has four different built-in ways to cache something, and they solve different problems. Picking the wrong one is the most common caching mistake I see — usually `IMemoryCache` reached for out of habit in a scenario that actually needed something distributed, or a whole `IDistributedCache` round-trip added for something that never needed to leave the process. Here's what each one is actually for.

### IMemoryCache — process-local object cache

`IMemoryCache` stores arbitrary .NET objects in the memory of the process that's running. It's the simplest option and the fastest — no serialization, no network hop — but it's private to a single instance, which is exactly the data-consistency problem covered in the [In-Memory Cache](/posts/what-is-in-memory-cache/) post. Reach for it when the app runs as a single instance, or when what you're caching is fine being slightly different per instance.

### IDistributedCache — shared, out-of-process object cache

`IDistributedCache` stores serialized data in an external store — Redis, SQL Server, or similar — so every instance of the app sees the same cache. It trades a small amount of latency (a network call to the cache store) for consistency across instances. This is the interface behind the [Distributed Cache](/posts/what-is-distributed-cache/) post and the [Redis](/posts/what-is-redis/) series.

### Output Caching (.NET 7+) — caching whole HTTP responses

Output Caching is middleware, not a cache object you call from your own code — it caches the *entire HTTP response* for GET/HEAD requests, keyed by the request URL by default. It's declarative: you mark an endpoint as cacheable, and the middleware handles the rest.

```csharp
builder.Services.AddOutputCache();

var app = builder.Build();
app.UseOutputCache();

app.MapGet("/weather", GetWeatherAsync).CacheOutput();
```

A few things worth knowing before you reach for it:

* By default, only HTTP 200 responses to GET/HEAD are cached, and requests that set cookies or come from an authenticated user are never cached — so it can't accidentally leak one user's response to another.
* **Tags** let you evict groups of cached responses together (`.CacheOutput(b => b.Tag("tag-blog"))`, then `IOutputCacheStore.EvictByTagAsync("tag-blog")`) — handy for "invalidate every page that shows this product" after an update.
* Storage defaults to in-process memory, same limitation as `IMemoryCache`. For a shared, multi-instance store, use `AddStackExchangeRedisOutputCache` — **not** `AddStackExchangeRedisCache`, that's a different (and, per Microsoft's own docs, not recommended for this) API, because output caching's tag-based eviction needs atomic operations that plain `IDistributedCache` doesn't guarantee.

Use it for GET endpoints whose entire response can be cached as-is — a product listing, a weather forecast, an RSS feed.

### HybridCache (.NET 9) — the modern default for data caching

HybridCache is the newest of the four, and it's meant to replace most direct `IMemoryCache`/`IDistributedCache` usage going forward. It combines both into a two-tier cache (fast in-process L1, optional out-of-process L2) behind one API, and fixes a real bug that plain `IDistributedCache` code has always had to work around by hand: **cache stampede**. If ten concurrent requests miss the cache for the same key at the same time, naive cache-aside code fires the expensive factory (the DB query, the API call) ten times. `HybridCache` coordinates concurrent callers for the same key so the factory runs once and everyone else waits for that one result.

```csharp
builder.Services.AddHybridCache();

public class ProductService(HybridCache cache)
{
    public async Task<Product> GetProductAsync(int id, CancellationToken ct)
    {
        return await cache.GetOrCreateAsync(
            $"product-{id}",
            async token => await LoadProductFromDbAsync(id, token),
            cancellationToken: ct);
    }
}
```

It's a good default for anything you'd have reached for `IMemoryCache` or `IDistributedCache` for — application data, not HTTP responses. It also has tag-based invalidation (logical, not physical: `RemoveByTagAsync` marks entries created before that point as stale rather than deleting them immediately, so old values still occupy memory until they expire naturally). One detail that surprised me: despite shipping in the box with .NET 9, `HybridCache` is distributed as a normal NuGet package (`Microsoft.Extensions.Caching.Hybrid`) that also supports .NET Standard 2.0 and .NET Framework 4.7.2 — you don't have to be on .NET 9 to use it.

### Picking one

| Scenario | Use |
| --- | --- |
| Single instance, small/short-lived data, no need to survive a restart | `IMemoryCache` |
| Multiple instances, need consistent data across all of them | `IDistributedCache` (often via Redis — see the [Redis series](/posts/what-is-redis/)) |
| A GET endpoint whose whole response can be cached as-is | Output Caching |
| Caching arbitrary data (not a full HTTP response), especially with high concurrent read load | `HybridCache` |
| Starting a new project today, general-purpose data caching | `HybridCache` — it subsumes the first two for most cases and adds stampede protection for free |

None of these are mutually exclusive — a typical app might use Output Caching on a handful of read-heavy GET endpoints and HybridCache everywhere else it fetches data that's expensive to recompute.

---

The rest of this series goes deep on the two most common real-world building blocks: the [In-Memory Cache](/posts/what-is-in-memory-cache/) and [Distributed Cache](/posts/what-is-distributed-cache/) posts cover the fundamentals in more depth, and the [Redis](/posts/what-is-redis/) series covers the most common distributed cache implementation end to end — installing it, its data types, and how databases work inside it.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
*Thanks For Reading*
