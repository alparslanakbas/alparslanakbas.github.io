---
title: What is Distributed Caching ?
date: 2024-12-17 23:10 +0300
categories: [Redis, NoSql]
tags: [Blog, Tutorial, NoSql, Redis, Cache]
---

## Introduction
Hello,

In the second article of our Redis series, we will discuss what **Distributed Caching** is and delve into the necessary details.

## What is Distributed Caching?
Distributed caching involves storing cached data in a completely separate cache service rather than the memory of the servers running the application.

![Desktop View](/assets/img/posts/what-is-distributed-cache.png)
_Distributed Cache_

As mentioned in our previous article titled **[What is In-Memory Caching?](https://alparslanakbas.github.io/posts/what-is-in-memory-cache/)**, when using the memory of application servers as cache storage, it is essential to centralize these caches to prevent data inconsistency. Distributed caching, as shown in the accompanying diagram, enables instances of an application running on different servers to access a shared cache. This ensures that every user request receives the same data regardless of which instance processes the request, thereby maintaining data consistency.

## Key Advantages
One significant advantage of distributed caching is its resilience compared to in-memory caching. When in-memory caching is used, any failure in the server hosting the application can result in the loss of all cached data. However, with distributed caching, the cache is stored on an independent service, making it secure and unaffected by issues on the application server.

While distributed caching may exhibit slightly slower performance than in-memory caching due to communication with an external service, this trade-off is often negligible. The benefits of ease of use, reliability, and scalability far outweigh the minor performance impact.

Distributed caching serves as a robust solution to ensure consistent and reliable data delivery across all instances of an application, paving the way for better performance and scalability.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_