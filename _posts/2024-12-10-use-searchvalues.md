---
title: Improving Array Search Performance with SearchValues
date: 2024-12-10 19:00 +0300
categories: [AspNetCore, Dotnet9]
tags: [Blog, Tutorial, AspNetCore, Dotnet8, Dotnet9, Array]
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

This feature proves especially effective in scenarios where conditions are evaluated on collections, such as during LINQ and EF Core querying processes, as demonstrated below:
```csharp
using System.Buffers;
 
SearchValues<string> _roles = SearchValues.Create(["Admin", "Moderator"], StringComparison.OrdinalIgnoreCase);
 
var roles = context.Roles.Where(r => _roles
                            .Contains(r.Name))
                         .ToList();
```
Additionally, as seen in the example above, the **SearchValues** class is accessed from the System.Buffers namespace.

See you in my upcoming articles, and happy coding..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_