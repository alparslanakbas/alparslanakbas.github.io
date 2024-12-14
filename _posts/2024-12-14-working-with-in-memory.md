---
title: Working with In-Memory Database Using Entity Framework Core
date: 2024-12-14 23:30 +0300
categories: [AspNetCore, EntityFramework]
tags: [Blog, Tutorial, Dotnet, EF, Memory]
---

## Introduction
Hello,

In daily life, when learning or implementing a new technology, structure, or method—or even when promoting a product you're developing—if your project requires a database and you're using **Entity Framework Core** as your **ORM**, you likely know how costly it can be to set up an actual database and establish the necessary connections. In such scenarios, Entity Framework Core provides **In-Memory** database support, allowing you to perform operations identical to those on a physical database but without the overhead. This lets you focus on your work more efficiently. Let’s explore how to use this feature.


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

To work with in-memory databases using **Entity Framework Core**, you need to install
```bash
Microsoft.EntityFrameworkCore.InMemory
```
libraries in your project.

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
    public DbSet<Employee> Employees { get; set; }
    public DbSet<Customer> Customers { get; set; }
 
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseInMemoryDatabase("InMemoryDb");
    }
}
```

The key point to note here is the **UseInMemoryDatabase** function on line 8. This function informs the context that it will store data in memory.

Thus, we have provided an in-memory database for testing purposes and reduced the extra overhead in our work.

See you in my upcoming articles, and happy coding..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_






















