---
title: What is In-Memory Caching ?
date: 2024-12-17 22:40 +0300
categories: [Redis, NoSql]
tags: [Blog, Tutorial, NoSql, Redis, Cache]
---

## Introduction
Hello,

In the second article of our Redis series, we will discuss what In-Memory Caching is and delve into the necessary details.

## What is In-Memory Caching?
In-Memory Caching is the process of temporarily storing stable data, which is frequently retrieved from the database due to high request rates, in the memory (RAM) of the server hosting the application. This approach is used to minimize the costs associated with database queries and provide faster access to data.

## How Does It Work?
When a user makes a request, the system first checks the cache for the data to be displayed. If the data is available in the cache, it is retrieved and sent to the user. If the cache is empty, the data is fetched from the database, saved in the cache, and then sent to the user. For subsequent requests, the data will be served directly from the cache. Of course, the amount of data that can be cached depends on the server's RAM specifications and capacity.

![Desktop View](/assets/img/posts/what-is-in-memory-cache.jpg)
_In Memory Cache_

### Potential Drawbacks of In-Memory Caching
If an application has multiple instances accessing the same database and uses In-Memory Caching, there is a risk of data inconsistency.

For example, consider the following scenario:
In the adjacent illustration, there are two instances of an application, A and B, both using the same database. A load balancer distributes user requests between these instances based on traffic. Let’s assume that at time (T), a request leads instance A to perform in-memory caching, and at time (T + 15), another request causes instance B to cache data. If the database undergoes any modifications, we could observe a discrepancy in the data returned by these instances at time (T + 30). If both instances provide consistent data, there’s no issue. However, if instance A shows "Apple" and instance B shows "Pear" due to database modifications, this highlights a significant drawback.

This inconsistency can arise in multi-instance applications using in-memory caching. However, if the application operates through a single instance, all users will process requests through the same instance, and this inconsistency will not occur.

![Desktop View](/assets/img/posts/potential-drawbacks-of-in-memory-cache.png)
_Potential Drawbacks of In-Memory Caching_

### How Can We Resolve This Drawback?
Although not a perfect solution, Session Sticky (Sticky Sessions) can partially address this issue. By configuring the load balancer to direct all requests from user X to instance A after their initial request, we can mitigate inconsistencies at the user level. This ensures users always interact with the same instance, making them unaware of discrepancies across instances. However, this is not a recommended or definitive solution.

![Desktop View](/assets/img/posts/potential-drawbacks-of-in-memory-cache.png)
_How Can We Resolve This Drawback_

Another approach is to centralize the cache for all instances. By storing cached data in a shared location, all users can access the most consistent data from the cache. This approach requires using **Distributed Caching**, which will be the focus of our next article.

We’ve thoroughly explored the theory behind what **In-Memory** Caching is.
In our next content, we will provide a detailed explanation of **Distributed Caching** and its workings.

You can read here **[Distributed Cache](https://alparslanakbas.github.io/posts/what-is-distributed-cache/)**


![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
