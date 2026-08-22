---
title: What is Distributed Caching ?
description: "What distributed caching is, how it keeps data consistent across multiple application instances, and how it compares to in-memory caching."
date: 2024-12-17 23:10 +0300
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

Distributed caching serves as a robust solution to ensure consistent and reliable data delivery across all instances of an application, paving the way for better performance and scalability. [Redis](/posts/what-is-redis/) is the most common real-world example of exactly this kind of independent cache service — the next few posts cover it in detail.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
