---
title: Redis Data Types
date: 2024-12-26 23:53 +0300
categories: [Redis, NoSql]
tags: [Blog, Tutorial, NoSql, Redis, Cache, RedisDataTypes]
---

## Introduction

Hello,
 
In this content, we will examine the Redis data types, which are one of the most important features that increase the preferability of Redis.

Redis is a rich database in terms of data types. The general feature of these data types, which we will examine shortly, is that they can be stored in key-value format up to a maximum of 512 MB. Now let's take a look at the data types.

## 1- Redis String

It is the simplest data type. Although its name suggests that it is only valid for textual data types, it can accommodate all kinds of data along with textual types. It can even store files such as images and PDFs in binary format. As you understand, it is a data type without limitations.

### a- Basic String Set/Get
```bash
SET name "Alparslan"
GET name # returns "Alparslan"
```

### b- Numeric String Operations
```bash
SET counter 10
INCR counter     # returns 11
INCRBY counter 5 # returns 16
DECR counter     # returns 15
```

### c- Multiple String Operations
```bash
MSET user:1:name "Alparslan" user:1:age "26"
MGET user:1:name user:1:age  # returns ["Alparslan", "26"]
```

### d- String Modifications
```bash
SET bestduo "Legolas"
APPEND message " Aragorn"  # becomes "Legolas Aragorn"
STRLEN message          # returns 14 (character count)
```

### e- Auto-Expiring String
```bash
SETEX session:token 3600 "mybestsecrettoken"  # automatically deletes after 1 hour
```

### f- Conditional String Setting
```bash
SETNX user:email "test@test.com"  # Sets only if key doesn't exist
```
These examples demonstrate the basic usage patterns of **Redis string** data type.

## 2- Redis List
It is a type that stores values in a collection. Elements can be added to the beginning or end of the collection. The methods are as follows:

### a- Adding Elements to List Start and End
```bash
LPUSH todos "Learn Redis"       # Add to start of list
RPUSH todos "Learn MongoDB"     # Add to end of list
LRANGE todos 0 -1              # Get all elements
```

### b- Removing Elements from List
```bash
LPOP todos   # Remove and return element from start
RPOP todos   # Remove and return element from end
```

### c- List Length and Getting Element by Index
```bash
LLEN users         # Returns list length
LINDEX todos 1     # Gets element at index 1
```

### d- Remove Specific Element
```bash
LREM tasks 1 "completed task"   # Removes 1 occurrence of "completed task"
```

### e- Practical Example - Social Media Recent Posts
```bash
LPUSH latest:posts "post:1"
LPUSH latest:posts "post:2"
LTRIM latest:posts 0 9    # Keep only last 10 posts
```

### f- Update Within List
```bash
LSET shopping:list 0 "computer"    # Replace element at index 0 with "computer"
```

### g- Get Elements Within Range
```bash
# List: ['task1', 'task2', 'task3', 'task4', 'task5']
LRANGE tasks 1 3    # Returns ['task2', 'task3', 'task4']
```

### h- Blocking List Operations
```bash
BLPOP queue:tasks 30    # Wait 30 seconds and get first element when available
```
These examples demonstrate the basic usage patterns of **Redis Lists**. The list structure is particularly suitable for scenarios like maintaining ordered data, implementing queue systems, and storing the last N elements.


## 3- Redis Set
It is the unique version of the Redis List. Additionally, the data is inserted in a random order.

### a- Basic Set Operations
```bash
SADD users "Alparslan"          # Add single member
SADD users "Gazi" "Serdar"   # Add multiple members
SMEMBERS users            # Get all members
SCARD users               # Get set size
```

### b- Check Member Existence
```bash
SISMEMBER users "Alparslan"    # Returns 1 if exists, 0 if not
```

### c- Remove Members
```bash
SREM users "Gazi"         # Remove single member
SPOP users               # Remove and return random member
```

### d- Set Operations (Union, Intersection, Difference)
```bash
# Team memberships
SADD team:backend "Alparslan" "Gazi"
SADD team:frontend "Serdar" "Alparslan"

SINTER team:backend team:frontend    # Members in both teams
SUNION team:backend team:frontend    # Members in either team
SDIFF team:backend team:frontend     # Members only in backend
```

### e- Practical Example - User Skills
```bash
SADD user:1:skills "dotnet" "redis" "blazor"
SADD user:2:skills "oracle" "redis" "mongodb"
```

### f- Random Member Selection
```bash
# Get random winner from participants
SADD raffle:users "user1" "user2" "user3"
SRANDMEMBER raffle:users      # Get random member without removing
```

### g- Move Member Between Sets
```bash
# Move user from active to inactive
SMOVE users:active users:inactive "Alparslan"
```

### h- Store Set Operations
```bash
# Store common skills between users
SINTERSTORE common:skills user:1:skills user:2:skills
```

These examples show how Redis Sets are useful for storing unique collections and performing set operations. They're particularly good for scenarios like:
* Managing unique relationships
* Tracking unique visitors
* Implementing tags
* Storing user roles/permissions
* Random selection systems


## 4- Redis Sorted Set
It is an ordered version of the **Redis Set**. You can add data in any order you want. Here are examples of **Redis Sorted Set**.

### a- Basic Sorted Set Operations
```bash
ZADD scores 100 "Legolas"         # Add member with score
ZADD scores 95 "Aragorn" 97 "Gimli" # Add multiple members with scores
ZRANGE scores 0 -1             # Get all members (ascending)
ZREVRANGE scores 0 -1          # Get all members (descending)
```

### b- Get Scores and Ranks
```bash
ZSCORE scores "Legolas"           # Get score of member
ZRANK scores "Legolas"           # Get rank of member (ascending)
ZREVRANK scores "Legolas"        # Get rank of member (descending)
```

### c- Range Operations with Scores
```bash
# Get members with their scores
ZRANGE scores 0 -1 WITHSCORES
```

### d- Score Range Queries
```bash
# Get users with scores between 90 and 95
ZRANGEBYSCORE leaderboard 90 95
```

### e- Practical Example - Leaderboard
```bash
ZADD leaderboard 1000 "player1"
ZADD leaderboard 2000 "player2"
ZADD leaderboard 3000 "player3"
ZREVRANGE leaderboard 0 2      # Top 3 players
```

### f- Increment Scores
```bash
# Increment user points
ZINCRBY points 50 "user1"     # Add 50 points to user1's score
```

### g- Remove Members
```bash
ZREM leaderboard "player1"    # Remove specific member
```

### h- Count Members in Score Range
```bash
# Count players with scores between 2000 and 3000
ZCOUNT leaderboard 2000 3000
```

### i- Time-Based Sorting Example
```bash
# Add posts with timestamp as score
ZADD posts 1703673600 "post:1"    # Unix timestamp as score
ZADD posts 1703760000 "post:2"
ZREVRANGE posts 0 10               # Get latest 10 posts
```

These examples demonstrate how Sorted **Sets** are perfect for:

* Leaderboards
* Priority queues
* Time-based data sorting
* Rating systems
* Ranking systems


## 5- Redis Hash
It is a type that stores data in key-value format. Here are examples of **Redis Hash** data type:


### a- Basic Hash Operations
```bash
HSET user:1 name "Alparslan" age "26" city "Ankara"    # Set multiple fields
HGET user:1 name                                    # Get single field
HGETALL user:1                                      # Get all fields and values
```

### b- Set/Get Single Field
```bash
HSET product:1 price "99.99"       # Set single field
HSETNX product:1 stock "50"        # Set only if field doesn't exist
```

### c- Multiple Field Operations
```bash
HMSET user:2 name "Alparslan" email "alparslan@email.com" age "26"
HMGET user:2 name email                            # Get multiple fields
```

### d- Check and Delete Fields
```bash
HEXISTS user:1 email               # Check if field exists
HDEL user:1 age                    # Delete field
```

### e- Increment Hash Fields
```bash
HSET inventory:1 quantity 10
HINCRBY inventory:1 quantity 5     # Increment by 5
```

### f- Get Field Information
```bash
HLEN user:1                        # Number of fields
HKEYS user:1                       # Get all field names
HVALS user:1                       # Get all values
```

### g- Practical Example - User Profile
```bash
# Store user profile
HSET user:100 username "Alparslan"
             password "hashed_password"
             email "alparslan@email.com"
             last_login "2024-12-27"
```

### h- Practical Example - Shopping Cart
```bash
# Store user profile
HSET cart:1 product:1 "2"          # 2 quantities of product 1
HSET cart:1 product:2 "1"          # 1 quantity of product 2
HINCRBY cart:1 product:1 1         # Add one more of product 1
```

These examples show how **Hashes** are useful for:

* User profiles
* Product details
* Configuration settings
* Session storage
* Shopping carts
* Object caching

I hope these data types are useful to you..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
