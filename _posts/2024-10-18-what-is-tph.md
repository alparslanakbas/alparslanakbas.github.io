---
title: What does mean TPH ? (Table Per Hierarchy)
date: 2024-10-18 19:38 +0300
categories: [AspNetCore, EntityFramework]
tags: [Blog, Tutorial, Orm, AspNetCore, Dotnet8, EF]
---

## Table Per Hierarchy (TPH): A Database Inheritance Strategy
Table Per Hierarchy (TPH) is one of the popular strategies used to map inheritance relationships from object-oriented programming to the database. TPH is frequently used in Object-Relational Mapping (ORM) tools like Entity Framework, allowing all entities in an inheritance hierarchy to be stored in a single database table.

In this post, we’ll explore what TPH is, how it works, its pros and cons, and we’ll also look at an example scenario to see how TPH can be implemented. We will also assess TPH from a performance standpoint, which is essential when working with large datasets.


## What is TPH?

Inheritance is a common feature in object-oriented programming (OOP) that allows one class (a child or derived class) to inherit properties and methods from another class (a parent or base class). When mapping these OOP relationships into a relational database, we must decide how to store inherited properties. This is where TPH comes into play.

TPH stores all properties of a class hierarchy in a single table and uses a discriminator column to determine which class each record belongs to. As a result, some fields in the table might be null depending on which specific subclass the record represents.


### Example Scenario: Product Management

Let’s consider an example in an e-commerce system where we manage different types of products. Suppose we have a base class called Product, and we want to categorize products into subclasses like Book and ElectronicProduct, where each subclass has unique properties.

<strong>Class Structure for Products</strong>

``` csharp
public class Product
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public float Price { get; set; }
}

public class Book : Product
{
    public required string Author { get; set; }
    public int Pages { get; set; }
}

public class ElectronicProduct : Product
{
    public required string Manufacturer { get; set; }
    public int WarrantyPeriod { get; set; }
}
```

In this structure, both Book and ElectronicProduct inherit from the Product class, but each subclass has unique fields. Now, let's see how we can store this hierarchy using TPH in a database.


## Database Structure (TPH)
Using TPH, we store all the data from the class hierarchy in a single table. The table includes columns for all possible fields, even though only certain rows will use specific columns based on the subclass type.
Here’s what the table might look like:

![Desktop View](/assets/img/posts/tph-table-view.PNG)
_Table-Per Hierarchy_table-view_

In this table:
* The <strong>Discriminator</strong> column identifies which subclass the row represents. For example, "Book" or "ElectronicProduct."
* Rows for the <strong>Book</strong> class will only populate the Author and Pages columns, while the other fields are null.
* Rows for the <strong>ElectronicProduct</strong> class will use the Manufacturer and WarrantyPeriod columns, and the book-specific fields will remain null.


## Advantages of TPH
* <strong>Single Table Management:</strong> No need to create multiple tables for different subclasses, simplifying the database schema.
* <strong>Performance:</strong> Since all data is stored in a single table, queries don't require joins between multiple tables, potentially speeding up simple queries.
* <strong>Simplicity:</strong> The schema is straightforward, as all inheritance hierarchy data is stored in one table.

### Disadvantages of TPH
* <strong>Null Values:</strong> Some columns will always contain nulls because certain fields are only relevant to specific subclasses. This can lead to data redundancy and waste.
* <strong>Readability:</strong> Managing multiple types of entities in a single table can make understanding and maintaining the database schema more difficult as the system grows.
* <strong>Performance Trade-Offs:</strong> In large datasets, constantly checking the Discriminator field and handling nulls could impact performance, especially if the table grows very large.


## How to Implement TPH in Code ?
Implementing TPH in an ORM like Entity Framework is straightforward. You can use the Discriminator property to specify how to distinguish between the different subclasses:
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Product>()
        .HasDiscriminator<string>("Discriminator")
        .HasValue<Book>("Book")
        .HasValue<ElectronicProduct>("ElectronicProduct");
}
```
This will configure Entity Framework to store Book and ElectronicProduct entities in the same Product table while using the Discriminator column to differentiate between them.

## Conclusion
TPH is a powerful inheritance mapping strategy when you need to keep your database schema simple. It works well for smaller projects or scenarios where the inheritance hierarchy is not too complex. However, as the project grows, you may encounter performance bottlenecks or challenges related to handling null values. Therefore, while TPH is an attractive choice for simple inheritance relationships, you should carefully assess its trade-offs and evaluate if it fits your long-term needs.
<hr>
I hope this helps you understand how to implement Table Per Hierarchy (TPH) in your projects.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
