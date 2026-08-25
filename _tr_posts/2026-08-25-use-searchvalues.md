---
title: "SearchValues ile Dizi Arama Performansını İyileştirmek"
description: "Vektörleştirilmiş, donanım hızlandırmalı SearchValues sınıfının .NET'te dizide çoklu değer aramasını nasıl hızlandırdığına genel bakış."
date: 2026-08-25 02:15 +0300
translation_key: use-searchvalues
categories: [.NET, Performance]
tags: [dotnet-8, dotnet-9, performance, arrays]
image:
  path: /assets/img/posts/use-searchvalues/cover.webp
  alt: "Kapak görseli: SearchValues ile Dizi Arama Performansını İyileştirmek"
  lqip: "data:image/webp;base64,UklGRlwAAABXRUJQVlA4IFAAAACwAwCdASoYAA0APu1kqU4ppaOiMAgBMB2JZQAAWpgq7feakeXO8AD+7BGIJG1RyhMceKhJTwVBaZBN0xNqFhUEVZYStst0p90gJf3JhAAAAA=="
---
## Giriş

Merhaba,

Bildiğiniz gibi, belirli işlemler için dizilerde veri aramak iş süreçlerinde yaygın bir davranıştır. Ancak bu tür işlemler önemli maliyetlere ve ciddi performans kayıplarına yol açabilir. Bu yazıda, bu tür senaryolarda uygulama performansını iyileştirmek için tasarlanmış, .NET 8 ile tanıtılan **SearchValues** özelliğini inceleyeceğiz.

**SearchValues**, büyük veri setleriyle çalışırken hesaplama hızını ve verimliliği artırmak için vektörleştirme ve donanım hızlandırma gibi optimizasyonlarla geliştirilmiş özel bir sınıftır. Bu sınıf, aranacak değerleri bir dizide değişmez (immutable) ve salt okunur (readonly) olarak saklar.

## Örnek

SearchValues sınıfı aşağıdaki örnekte gösterildiği gibi kullanılabilir:

```csharp
using System.Buffers;
 
string[] names = ["Samwise", "Frodo", "Elrond", "Aragorn", "Legolas", "Gimli", "Galadriel", "Arwen"];
 
SearchValues<string> selectedNames = SearchValues.Create(["Aragorn", "Legolas"], StringComparison.OrdinalIgnoreCase);
var _names = names.Where(t => selectedNames
                    .Contains(t))
                  .ToList();
 
_names.ForEach(name => Console.WriteLine(name));
```

Bir koleksiyon içinde birden fazla belirli değeri aramanın en hızlı yollarından birini sunar. .NET 8 ile ilk tanıtıldığında yalnızca char ve byte dizilerini destekliyordu, ancak .NET 9 ile yetenekleri string dizilerini de destekleyecek şekilde genişletildi.

Bu özellik özellikle bellek içi (in-memory) LINQ filtrelemede — yukarıdaki ilk örnekte olduğu gibi zaten yüklenmiş bir `List<T>` ya da dizide arama yaparken — oldukça etkili.

**Bunu bir [EF Core](/posts/working-with-in-memory/) sorgusunda kullanmayı düşünüyorsanız dikkat edilmesi gereken önemli bir nokta var:** `SearchValues<T>` tamamen bellek içi, istemci tarafı bir API'dir — SQL çevirisi yoktur. Gerçek bir veritabanı sağlayıcısına karşı `context.Roles.Where(r => _roles.Contains(r.Name))` yazarsanız, EF Core ya "could not be translated" hatası fırlatır ya da (eski EF Core sürümlerinde) sessizce yavaş istemci taraflı değerlendirmeye düşer, filtrelemeden önce tüm satırları belleğe çeker. `SearchValues`, veri zaten bellekteyken anlamlıdır:

```csharp
using System.Buffers;
 
SearchValues<string> _roles = SearchValues.Create(["Admin", "Moderator"], StringComparison.OrdinalIgnoreCase);
 
var roles = context.Roles
    .AsEnumerable() // önce materialize et - SearchValues SQL'e çevrilemez
    .Where(r => _roles.Contains(r.Name))
    .ToList();
```

Ayrıca yukarıdaki örnekte görüldüğü gibi, **SearchValues** sınıfına System.Buffers namespace'inden erişilir.

.NET 9'un string desteği eklemesinden bu yana API'de hiçbir şey değişmedi — bugün .NET 10'da gösterilen aynı `SearchValues.Create`. Önceki bir yazıda ele alınan [rate limiting middleware](/tr/posts/dotnet7-how-to-use-rate-limitter/) ile aynı türden, dar kapsamlı, amaca özel bir performans kazanımı: varsayılan olarak başvurduğunuz bir şey değil, ama çözdüğü spesifik durum için var olduğunu bilmeye değer.

Sonraki yazılarımda görüşmek üzere, iyi kodlamalar..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
