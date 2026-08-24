---
title: What is Distributed Caching ?
description: "What distributed caching is, how it keeps data consistent across multiple application instances, and how it compares to in-memory caching."
date: 2024-12-17 23:10 +0300
last_modified_at: 2026-08-24 22:00 +0300
categories: [Data, Caching]
tags: [caching, distributed-systems, redis]
series: "Caching & Redis"
series_order: 3
image:
  path: /assets/img/posts/what-is-distributed-cache/cover.webp
  alt: 'Title card: What is Distributed Caching?'
  lqip: "data:image/webp;base64,UklGRl4AAABXRUJQVlA4IFIAAADQAwCdASoYAA0APu1kqU2ppaQiMAgBMB2JZQAAWqFFJ/HPRaY/8AAA/uwRiCRtUcmjwTGQF7hHI37Eab1zQG0mzQ9U+KBes5rLqIuWP/SB2AAA"
---

## Introduction

Hello,

Following up on the [introduction to caching](/posts/what-is-caching/), we will discuss what **Distributed Caching** is and delve into the necessary details.

## What is Distributed Caching?

Distributed caching involves storing cached data in a completely separate cache service rather than the memory of the servers running the application.

![Desktop View](/assets/img/posts/what-is-distributed-cache.webp)
_Distributed Cache_

As mentioned in our previous article titled **[What is In-Memory Caching?](/posts/what-is-in-memory-cache/)**, when using the memory of application servers as cache storage, it is essential to centralize these caches to prevent data inconsistency. Distributed caching, as shown in the accompanying diagram, enables instances of an application running on different servers to access a shared cache. This ensures that every user request receives the same data regardless of which instance processes the request, thereby maintaining data consistency.

## Key Advantages

One significant advantage of distributed caching is its resilience compared to in-memory caching. When in-memory caching is used, any failure in the server hosting the application can result in the loss of all cached data. However, with distributed caching, the cache is stored on an independent service, making it secure and unaffected by issues on the application server.

While distributed caching may exhibit slightly slower performance than in-memory caching due to communication with an external service, this trade-off is often negligible. The benefits of ease of use, reliability, and scalability far outweigh the minor performance impact.

Distributed caching serves as a robust solution to ensure consistent and reliable data delivery across all instances of an application, paving the way for better performance and scalability. Distributed cache data also has two practical advantages that don't show up in a feature comparison but matter in production: it stays coherent across every instance, and it survives a server restart or a fresh deployment — an in-memory cache is wiped clean every time, a distributed one just keeps serving from where it left off.

## The IDistributedCache Interface

In .NET, `IDistributedCache` is the interface every distributed cache implementation (Redis, SQL Server, and others) implements, so your application code doesn't need to know which one is actually behind it. It has four operations:

* `GetAsync(key)` / `Get(key)` — retrieves a cached item as a `byte[]`.
* `SetAsync(key, value)` / `Set(key, value)` — stores an item, also as a `byte[]`.
* `RefreshAsync(key)` / `Refresh(key)` — resets the item's sliding expiration without changing its value, useful for "keep this alive as long as it's being read" scenarios.
* `RemoveAsync(key)` / `Remove(key)` — evicts the item.

The one detail that trips people up the first time: everything is `byte[]`, not an arbitrary object the way `IMemoryCache` works. If you want to cache something like a `Product` or a list of DTOs, you're responsible for serializing it yourself — usually with `System.Text.Json` — before calling `SetAsync`, and deserializing it back after `GetAsync`. A minimal cache-aside implementation looks like this:

```csharp
public async Task<Product?> GetProductAsync(int id, CancellationToken ct)
{
    var cacheKey = $"product-{id}";
    var cached = await _cache.GetAsync(cacheKey, ct);

    if (cached is not null)
    {
        return JsonSerializer.Deserialize<Product>(cached);
    }

    var product = await _dbContext.Products.FindAsync([id], ct);
    if (product is null) return null;

    var serialized = JsonSerializer.SerializeToUtf8Bytes(product);
    await _cache.SetAsync(cacheKey, serialized, new DistributedCacheEntryOptions
    {
        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
    }, ct);

    return product;
}
```

This is exactly the byte-shuffling overhead that [HybridCache](/posts/what-is-caching/#hybridcache-net-9--the-modern-default-for-data-caching) was built to remove — it wraps `IDistributedCache` and handles the serialization for you, on top of adding stampede protection. `IDistributedCache` is still worth understanding directly, though: it's what HybridCache uses as its second tier under the hood, and it's what you'll find in most existing .NET codebases today.

## Backing Stores

`IDistributedCache` is just the interface — you still need something behind it to actually store the data. The framework ships first-party support for a few options:

* **Redis** (`AddStackExchangeRedisCache`) — the most common choice, and the one Microsoft's own docs call out as delivering the best performance for production. It's the implementation the rest of this series covers in depth.
* **SQL Server** (`AddDistributedSqlServerCache`) — stores cache entries in a SQL Server table. Useful if you already run SQL Server and don't want to stand up a separate cache service, at the cost of being noticeably slower than Redis.
* **Postgres, Azure Cosmos DB, and third-party options like NCache** — also supported, less commonly reached for unless one of them is already part of the stack.

For most new projects, Redis is the default choice — which is exactly why the rest of this series goes deep on it specifically: [what Redis is and why it's fast](/posts/what-is-redis/), [running it locally with Docker](/posts/run-redis-with-docker/), [its data types](/posts/redis-data-types/), and [how its databases work](/posts/redis-databases/).

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
