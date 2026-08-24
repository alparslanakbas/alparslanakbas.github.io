---
title: What is Redis And Use Cases?
description: "An introduction to Redis: what makes this in-memory NoSQL store fast, how it persists data, and its common use cases like caching and queues."
date: 2024-12-23 23:25 +0300
categories: [Data, Redis]
tags: [redis, nosql, caching, use-cases]
series: "Caching & Redis"
series_order: 4
image:
  path: /assets/img/posts/what-is-redis/cover.webp
  alt: 'Title card: What is Redis And Use Cases?'
  lqip: "data:image/webp;base64,UklGRloAAABXRUJQVlA4IE4AAACwAwCdASoYAA0APu1iqU2ppaQiMAgBMB2JZQAAWqFFJ/HP/q6kAAD+7BGIJG1RyaPBMZAXvVubRiNN6yMZiS9ZLkjRat90grv/H96kmAA="
---

## What is Redis ?

To understand a phenomenon means to know the etymology of the concept representing that phenomenon. Of course, the etymology of the software world corresponds to the lifespan of a 3-day-old technology, and since the terminological words of the industry haven’t had enough time to establish relational connections among themselves, it is unrealistic to expect a rich root in terms of vocabulary.

Redis, which stands for REmote DIctionary Server, is an open-source database and a NoSQL solution that adopts the fastest possible method of data access by storing data in memory. (More on exactly what "open-source" means for Redis today, since it's changed more than once — see [Licensing](#licensing) below.)

In addition to being a NoSQL database, Redis includes fundamental data structures tailored to the type of data to be stored. This feature significantly strengthens Redis compared to other databases. Another characteristic that makes Redis preferable is its speed, outperforming all relational databases.

Since Redis is a **distributed** system and keeps all instances' caches in a single remote memory rather than **in-memory** caching for each application, it provides a system with clear data consistency — it's a concrete, real-world example of the [distributed caching](/posts/what-is-distributed-cache/) concept covered in an earlier post.

Another advantage of Redis being a memory-based database is that it can perform read and write operations in milliseconds. For this reason, major brands such as Twitter, GitHub, Tumblr, Pinterest, Instagram, Hulu, Flickr, and The New York Times use this server.

Although Redis is primarily used as a caching server, it can also be utilized for various other scenarios. Since it can store users' session information, it serves as a Session Store. By supporting the Pub/Sub paradigm, it facilitates the Publish–Subscribe Pattern. Additionally, it can handle messages that need to be processed sequentially in an application, making them scalable, which makes it suitable for Queues. Lastly, Redis can be used in Counters scenarios due to its ability to function as a counter.

## Licensing

Worth knowing if you're picking Redis for a new project: the licensing has genuinely changed twice recently, and it matters for what you're actually allowed to do with it.

* **Until March 2024**, Redis was released under a standard permissive open-source license (BSD).
* **In March 2024**, Redis switched to SSPL — a "source-available" license aimed at stopping cloud providers from reselling Redis without contributing back. SSPL isn't OSI-approved open source, and the change was controversial enough that it prompted a Linux Foundation-backed fork, [Valkey](https://valkey.io/), which several major cloud providers now ship instead.
* **With Redis 8 (2025)**, Redis added AGPLv3 — an OSI-approved open-source license — back as an option, alongside SSPL and RSALv2. Redis 8 also folded the previously paid-tier Redis Stack features (JSON, Time Series, probabilistic data types, the Query Engine) into core under AGPL.

The practical upshot: if you're running open-source Redis locally, in Docker, or self-hosted for a personal or internal project (exactly what this series covers), none of this changes anything about how you use it day to day. It matters more if you're a cloud provider reselling Redis as a managed service, or a company deciding between Redis and Valkey for a production deployment.

## Data Persistence

Although Redis is a system that stores data in memory, it also supports persistent data. Since it is not entirely feasible to talk about persistent data in RAM, Redis systems can save data to hard disks using various methods. Two approaches are adopted for this purpose: **Snapshotting** and **Slave**.

* **Snapshotting** involves saving snapshots of the data to the disk at specific time intervals.
* In the **Slave** method, data is stored on slaves, reducing the load on masters and ensuring persistence.

## Pipelining

Thanks to Redis' pipelining feature, it retrieves all requested data in a single batch, significantly boosting performance and speed.
In summary:

### Advantages

* Reduces CPU costs by shifting CPU usage in traditional databases to memory.
* Since data stored in memory is processed very quickly, it provides a performance boost.
* It is open source again as of Redis 8 (see [Licensing](#licensing)).
* Supported by many programming languages today.
* Rich in documentation.
* Supports basic data types.
* Works synchronously, making it extremely fast.
* Can save data not only in memory but also to hard disks.

### Disadvantages

* The data to be stored is limited by the capacity of the RAM.
* Does not support complex, report-like queries as in relational database systems.
* Since there are no transactions, errors encountered during the process cannot be compensated.

## Use Cases

* Caching
* Session Storage
* Queues
* Pub/Sub
* Counter

Next up: [installing Redis locally with Docker](/posts/run-redis-with-docker/), then a closer look at [Redis's core data types](/posts/redis-data-types/) — strings, lists, sets, sorted sets, and hashes — with real command examples for each.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
