---
title: "Distributed Caching Nedir?"
description: "Distributed caching'in ne olduğu, birden fazla uygulama instance'ında veriyi nasıl tutarlı tuttuğu ve in-memory caching ile karşılaştırması."
date: 2026-08-25 02:30 +0300
translation_key: what-is-distributed-cache
categories: [Data, Caching]
tags: [caching, distributed-systems, redis]
image:
  path: /assets/img/posts/what-is-distributed-cache/cover.webp
  alt: "Kapak görseli: Distributed Caching Nedir?"
  lqip: "data:image/webp;base64,UklGRl4AAABXRUJQVlA4IFIAAADQAwCdASoYAA0APu1kqU2ppaQiMAgBMB2JZQAAWqFFJ/HPRaY/8AAA/uwRiCRtUcmjwTGQF7hHI37Eab1zQG0mzQ9U+KBes5rLqIuWP/SB2AAA"
---

[Caching'e giriş](/posts/what-is-caching/) yazısının devamında, **Distributed Caching**'in ne olduğunu ele alıp gerekli detaylara inelim.

## Distributed Caching Nedir?

Distributed caching, cache'lenmiş veriyi uygulamayı çalıştıran sunucuların belleği yerine, tamamen ayrı bir cache servisinde saklamayı içerir.

![Desktop View](/assets/img/posts/what-is-distributed-cache.webp)
_Distributed Cache_

Önceki **[In-Memory Caching Nedir?](/posts/what-is-in-memory-cache/)** yazımızda bahsettiğimiz gibi, uygulama sunucularının belleğini cache deposu olarak kullanırken, veri tutarsızlığını önlemek için bu cache'leri merkezileştirmek gerekir. Distributed caching, ekteki diyagramda gösterildiği gibi, farklı sunucularda çalışan uygulama instance'larının paylaşılan bir cache'e erişmesini sağlar. Bu, hangi instance'ın işlediğinden bağımsız olarak her kullanıcı isteğinin aynı veriyi almasını sağlayarak veri tutarlılığını korur.

## Temel Avantajlar

Distributed caching'in önemli bir avantajı, in-memory caching'e kıyasla dayanıklılığıdır. In-memory caching kullanıldığında, uygulamayı barındıran sunucudaki herhangi bir arıza tüm cache'lenmiş verinin kaybolmasına yol açabilir. Ama distributed caching'de cache, bağımsız bir serviste saklanır, bu da onu güvenli ve uygulama sunucusundaki sorunlardan etkilenmez hale getirir.

Distributed caching, harici bir servisle iletişim nedeniyle in-memory caching'e göre biraz daha yavaş performans gösterebilir, ama bu ödünleşim genelde ihmal edilebilir düzeydedir. Kullanım kolaylığı, güvenilirlik ve ölçeklenebilirlik faydaları, küçük performans etkisinden çok daha ağır basar.

Distributed caching, bir uygulamanın tüm instance'larında tutarlı ve güvenilir veri sunumu sağlayan sağlam bir çözüm olup, daha iyi performans ve ölçeklenebilirliğin önünü açar. Distributed cache verisinin, özellik karşılaştırmalarında görünmeyen ama production'da önemli olan iki pratik avantajı daha var: her instance'da tutarlı kalır ve bir sunucu yeniden başlatmasından ya da yeni bir deployment'tan sağ çıkar — in-memory cache her seferinde sıfırlanırken, distributed olan kaldığı yerden servis vermeye devam eder.

## IDistributedCache Arayüzü

.NET'te `IDistributedCache`, her distributed cache implementasyonunun (Redis, SQL Server ve diğerleri) uyguladığı arayüzdür, yani uygulama kodunun arkada gerçekte hangisinin olduğunu bilmesine gerek yoktur. Dört işlemi vardır:

* `GetAsync(key)` / `Get(key)` — cache'lenmiş bir öğeyi `byte[]` olarak getirir.
* `SetAsync(key, value)` / `Set(key, value)` — bir öğeyi, yine `byte[]` olarak saklar.
* `RefreshAsync(key)` / `Refresh(key)` — öğenin değerini değiştirmeden sliding expiration'ını sıfırlar, "bu okundukça hayatta kalsın" senaryoları için kullanışlıdır.
* `RemoveAsync(key)` / `Remove(key)` — öğeyi kaldırır.

İlk seferinde herkesi şaşırtan bir detay: her şey `byte[]`, `IMemoryCache`'in çalıştığı gibi rastgele bir obje değil. Bir `Product` ya da DTO listesi gibi bir şeyi cache'lemek istiyorsan, `SetAsync`'i çağırmadan önce bunu kendin serialize etmekten (genelde `System.Text.Json` ile) ve `GetAsync`'ten sonra tekrar deserialize etmekten sen sorumlusun. Minimal bir cache-aside implementasyonu şöyle görünür:

```csharp
public async Task<Product?> GetProductAsync(int id, CancellationToken ct)
{
    var cacheKey = $"product-{id}";
    var cached = await _cache.GetAsync(cacheKey, ct);

    if (cached is not null)
    {
        return JsonSerializer.Deserialize<Product>(cached);
    }

    var product = await _dbContext.Products.FindAsync([id], ct);
    if (product is null) return null;

    var serialized = JsonSerializer.SerializeToUtf8Bytes(product);
    await _cache.SetAsync(cacheKey, serialized, new DistributedCacheEntryOptions
    {
        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
    }, ct);

    return product;
}
```

Bu, tam olarak [HybridCache](/posts/what-is-caching/#hybridcache-net-9--the-modern-default-for-data-caching)'in ortadan kaldırmak için yapıldığı byte-taşıma yükü — `IDistributedCache`'i sarmalayıp serialization'ı senin için hallediyor, üstüne bir de stampede koruması ekliyor. Yine de `IDistributedCache`'i doğrudan anlamaya değer: HybridCache'in arka planda ikinci katmanı olarak kullandığı şey bu, ve bugün var olan çoğu .NET kod tabanında karşılaşacağın da bu.

## Backing Store'lar

`IDistributedCache` sadece bir arayüz — veriyi gerçekten saklamak için arkasında hâlâ bir şeye ihtiyacın var. Framework birkaç seçenek için birinci taraf destek sunuyor:

* **Redis** (`AddStackExchangeRedisCache`) — en yaygın seçim, ve Microsoft'un kendi dokümanının production için en iyi performansı verdiğini söylediği seçenek. Bu serinin geri kalanının derinlemesine ele aldığı implementasyon da bu.
* **SQL Server** (`AddDistributedSqlServerCache`) — cache kayıtlarını bir SQL Server tablosunda saklar. Zaten SQL Server çalıştırıyorsan ve ayrı bir cache servisi kurmak istemiyorsan kullanışlıdır, bedeli Redis'e göre belirgin şekilde daha yavaş olmasıdır.
* **Postgres, Azure Cosmos DB, ve NCache gibi üçüncü taraf seçenekler** — bunlar da destekleniyor, biri zaten stack'in bir parçası değilse daha az tercih edilirler.

Çoğu yeni proje için Redis varsayılan seçimdir — ki bu serinin geri kalanının özellikle onu derinlemesine ele almasının sebebi de tam olarak bu: [Redis nedir ve neden bu kadar hızlı](/posts/what-is-redis/), [Docker ile yerelde çalıştırmak](/posts/run-redis-with-docker/), [veri tipleri](/posts/redis-data-types/) ve [veritabanlarının nasıl çalıştığı](/posts/redis-databases/).

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Okuduğunuz için teşekkürler_
