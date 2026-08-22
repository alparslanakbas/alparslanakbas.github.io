---
title: What is Redis Databases? How to Use It?
description: "An introduction to RedisInsight (Redis Databases), a graphical tool for connecting to and visualizing key-value data on a Redis server."
date: 2024-12-26 00:23 +0300
categories: [Data, Redis]
tags: [redis, redisinsight, nosql]
image:
  path: /assets/img/posts/redis-databases/cover.webp
  alt: 'Title card: What is Redis Databases?'
---

## Introduction
Hello,
I will briefly introduce **RedisInsight**, the official GUI that lets us view and modify real-time data on a Redis server through a graphical interface, instead of typing every command by hand in [`redis-cli`](/posts/run-redis-with-docker/).

## Download
RedisInsight is 100% free with no signup or trial required — download it directly from **[redis.io/insight](https://redis.io/insight/)** for Windows, macOS, or Linux, or run it as a Docker container if you'd rather not install anything locally.

## Interface Overview
After downloading and installing Redis Databases, simply click the "Add Redis Database" button to connect to the Redis server where the data will be visualized. Once you enter your information as shown in the image, you can test the connection using "Test Connection." When it says "Test Successful" at the bottom right, the addition process is complete.

![Desktop View](/assets/img/posts/redis-desktop.PNG)
_Redis Databases_


## Let's Test It

Previously, we had created and run a Redis container in Docker. If you haven’t deleted it, you can start that container again. Once it’s running successfully, you can access your connection through Redis Databases and view the message we created, as shown in the image below.

![Desktop View](/assets/img/posts/redis-3.PNG)
_Redis message_

For those who are new to Redis or just starting to learn it, I highly recommend using this application — it makes the [data types](/posts/redis-data-types/) covered earlier in this series much easier to see and understand than reading raw `redis-cli` output.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
