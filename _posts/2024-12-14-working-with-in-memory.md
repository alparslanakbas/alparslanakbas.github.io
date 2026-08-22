---
title: Working with In-Memory Database Using Entity Framework Core
description: "How to use Entity Framework Core's in-memory database provider to model and test data access quickly, without a real database connection."
date: 2024-12-14 23:30 +0300
categories: [.NET, Entity Framework]
tags: [entity-framework, in-memory-database, testing]
image:
  path: /assets/img/posts/working-with-in-memory/cover.webp
  alt: 'Title card: Working with In-Memory Database Using Entity Framework Core'
---

## Introduction
Hello,

In daily life, when learning or implementing a new technology, structure, or method—or even when promoting a product you're developing—if your project requires a database and you're using **Entity Framework Core** as your **ORM**, you likely know how costly it can be to set up an actual database and establish the necessary connections. In such scenarios, Entity Framework Core provides **In-Memory** database support, allowing you to perform operations identical to those on a physical database but without the overhead. This lets you focus on your work more efficiently. Let's explore how to use this feature — and if inheritance mapping is what actually brought you here, the [TPH post](/posts/what-is-tph/) uses this exact provider to keep its examples runnable without a real database.


## Let's starting
First, let’s discuss the advantages and disadvantages of working with an In-Memory database in **Entity Framework Core**;

**Advantages**:
* In test and promotional applications, instead of creating and configuring actual/physical databases, you can model the entire database in memory and perform necessary operations as if working on a real database.
* Since working in memory is a temporary experience, it prevents unnecessary storage usage by test databases on database servers.
* Modeling the database in memory allows for faster testing of the code.

**Disadvantages**:
* Relational modeling is not possible in database operations performed with an In-Memory database. As a result, data consistency may be compromised, leading to inaccurate statistical results.

After conducting rapid tests on a database designed in-memory, once it is determined that the application is ready to transition to a real database, the necessary configurations can be easily implemented, and the application can directly connect to a physical database.

### Library Installation

To work with in-memory databases using **Entity Framework Core**, install the provider package:
```bash
dotnet add package Microsoft.EntityFrameworkCore.InMemory
```

### Example Implementation

Let's start by creating a few entity models for demonstration purposes. Here's an example of an **Employee** entity:
```csharp
class Employee
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public List<Customer> Customers { get; set; }
}
```

**Customer**

```csharp
class Customer
{
    public int Id { get; set; }
    public string Name { get; set; }
    public Employee Employee { get; set; }
}
```

Then, design the context class as follows.

```csharp
class Context : DbContext
{
    public Context() { }
    public Context(DbContextOptions<Context> options) : base(options) { }

    public DbSet<Employee> Employees { get; set; }
    public DbSet<Customer> Customers { get; set; }
 
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
            optionsBuilder.UseInMemoryDatabase("InMemoryDb");
    }
}
```

The key point to note here is the **UseInMemoryDatabase** call inside `OnConfiguring`. This informs the context that it will store data in memory instead of connecting to a real database.

Thus, we have provided an in-memory database for testing purposes and reduced the extra overhead in our work.

## A More Common Pattern: Swapping It In for Tests

Hardcoding the provider inside `OnConfiguring` works for a quick demo, but it means your context can *only* ever run in-memory — not what you want if the same `DbContext` also needs to run against a real database in production. The more common approach is to leave the context provider-agnostic and configure it through dependency injection instead, so a test project can swap in the in-memory provider without touching the context class at all:

```csharp
// In your test project's setup:
var options = new DbContextOptionsBuilder<Context>()
    .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
    .Options;

using var context = new Context(options);
```

Using `Guid.NewGuid()` as the database name gives each test its own isolated in-memory database, so tests don't leak state into each other when they run in parallel — a real gotcha if you reuse the same database name across a test suite and wonder why one test's leftover data is breaking another.

See you in my upcoming articles, and happy coding..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_






















