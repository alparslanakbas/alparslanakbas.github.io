---
title: What is Redis And Use Cases?
date: 2024-12-23 23:25 +0300
categories: [Redis, NoSql]
tags: [Blog, Tutorial, NoSql, Redis, Cache]
---

## What is Redis ?

To understand a phenomenon means to know the etymology of the concept representing that phenomenon. Of course, the etymology of the software world corresponds to the lifespan of a 3-day-old technology, and since the terminological words of the industry haven’t had enough time to establish relational connections among themselves, it is unrealistic to expect a rich root in terms of vocabulary.

Redis, which stands for REmote DIctionary Server, is an open-source database and a NoSQL solution that adopts the fastest possible method of data access by storing data in memory.

In addition to being a NoSQL database, Redis includes fundamental data structures tailored to the type of data to be stored. This feature significantly strengthens Redis compared to other databases. Another characteristic that makes Redis preferable is its speed, outperforming all relational databases.

Since Redis is a **distributed** system and keeps all instances' caches in a single remote memory rather than **in-memory** caching for each application, it provides a system with clear data consistency.

Another advantage of Redis being a memory-based database is that it can perform read and write operations in milliseconds. For this reason, major brands such as Twitter, GitHub, Tumblr, Pinterest, Instagram, Hulu, Flickr, and The New York Times use this server.

Although Redis is primarily used as a caching server, it can also be utilized for various other scenarios. Since it can store users' session information, it serves as a Session Store. By supporting the Pub/Sub paradigm, it facilitates the Publish–Subscribe Pattern. Additionally, it can handle messages that need to be processed sequentially in an application, making them scalable, which makes it suitable for Queues. Lastly, Redis can be used in Counters scenarios due to its ability to function as a counter.

## Data Persistence
Although Redis is a system that stores data in memory, it also supports persistent data. Since it is not entirely feasible to talk about persistent data in RAM, Redis systems can save data to hard disks using various methods. Two approaches are adopted for this purpose: **Snapshotting** and **Slave**.

* **Snapshotting** involves saving snapshots of the data to the disk at specific time intervals.
* In the **Slave** method, data is stored on slaves, reducing the load on masters and ensuring persistence.


## Pipelining
Thanks to Redis' pipelining feature, it retrieves all requested data in a single batch, significantly boosting performance and speed.
In summary:

**Advantages**
* Reduces CPU costs by shifting CPU usage in traditional databases to memory.
* Since data stored in memory is processed very quickly, it provides a performance boost.
* It is open source.
* Supported by many programming languages today.
* Rich in documentation.
* Supports basic data types.
* Works synchronously, making it extremely fast.
* Can save data not only in memory but also to hard disks.

**Disadvantages**
* The data to be stored is limited by the capacity of the RAM.
* Does not support complex, report-like queries as in relational database systems.
* Since there are no transactions, errors encountered during the process cannot be compensated.

## Use Cases
* Caching
* Session Storage
* Queues
* Pub/Sub
* Counter

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
























