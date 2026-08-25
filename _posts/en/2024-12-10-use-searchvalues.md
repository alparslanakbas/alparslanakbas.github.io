---
title: Improving Array Search Performance with SearchValues
description: "An overview of .NET's SearchValues class and how its vectorized, hardware-accelerated lookups speed up searching arrays for multiple values."
date: 2024-12-10 19:00 +0300
translation_key: use-searchvalues
categories: [.NET, Performance]
tags: [dotnet-8, dotnet-9, performance, arrays]
image:
  path: /assets/img/posts/use-searchvalues/cover.webp
  alt: 'Title card: Improving Array Search Performance with SearchValues'
  lqip: "data:image/webp;base64,UklGRlwAAABXRUJQVlA4IFAAAACwAwCdASoYAA0APu1kqU4ppaOiMAgBMB2JZQAAWpgq7feakeXO8AD+7BGIJG1RyhMceKhJTwVBaZBN0xNqFhUEVZYStst0p90gJf3JhAAAAA=="
---
## Introduction

Hello,

As you know, searching for data within arrays for specific operations is a common behavior in business processes. However, such operations can lead to significant costs and substantial performance losses. In this article, we will explore the **SearchValues** feature introduced with .NET 8, designed to improve application performance in such scenarios.

**SearchValues** is a specialized class developed with optimizations such as vectorization and hardware acceleration to enhance computational speed and efficiency when working with large datasets. This class stores the values to be searched in an array as immutable and readonly.

## Example

The SearchValues class can be used as shown in the following example:

```csharp
using System.Buffers;
 
string[] names = ["Samwise", "Frodo", "Elrond", "Aragorn", "Legolas", "Gimli", "Galadriel", "Arwen"];
 
SearchValues<string> selectedNames = SearchValues.Create(["Aragorn", "Legolas"], StringComparison.OrdinalIgnoreCase);
var _names = names.Where(t => selectedNames
                    .Contains(t))
                  .ToList();
 
_names.ForEach(name => Console.WriteLine(name));
```

It offers one of the fastest ways to search for multiple specific values within a collection. When first introduced in .NET 8, it only supported char and byte arrays, but with .NET 9, its capabilities have been expanded to support string arrays as well.

This feature proves especially effective in in-memory LINQ filtering — searching a `List<T>` or array you already have loaded, like the first example above.

**One important caveat if you're reaching for this in an [EF Core](/posts/working-with-in-memory/) query:** `SearchValues<T>` is a purely in-memory, client-side API — it has no SQL translation. If you write `context.Roles.Where(r => _roles.Contains(r.Name))` against a real database provider, EF Core will either throw a "could not be translated" exception or (on older EF Core versions) silently fall back to slow client-side evaluation, pulling every row into memory before filtering. `SearchValues` only makes sense once the data is already in memory:

```csharp
using System.Buffers;
 
SearchValues<string> _roles = SearchValues.Create(["Admin", "Moderator"], StringComparison.OrdinalIgnoreCase);
 
var roles = context.Roles
    .AsEnumerable() // materialize first - SearchValues can't be translated to SQL
    .Where(r => _roles.Contains(r.Name))
    .ToList();
```

Additionally, as seen in the example above, the **SearchValues** class is accessed from the System.Buffers namespace.

Nothing about the API has changed since .NET 9 added string support — it's the same `SearchValues.Create` shown above on .NET 10 today. It's the same kind of narrowly-scoped, purpose-built performance win as the [rate limiting middleware](/posts/dotnet7-how-to-use-rate-limitter/) covered in an earlier post: not something you reach for by default, but worth knowing exists for the specific case it solves.

See you in my upcoming articles, and happy coding..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
