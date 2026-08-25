---
title: "ASP.NET Core'da Rate Limiting: Pratik Bir Rehber"
description: "ASP.NET Core'un rate limiting middleware'ine pratik bir bakış — dört yerleşik algoritma, istemci başına bölümleme ve özel red yanıtları."
date: 2026-08-25 01:00 +0300
translation_key: dotnet7-how-to-use-rate-limitter
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-7, rate-limiting, middleware, partitioning]
image:
  path: /assets/img/posts/dotnet7-how-to-use-rate-limitter/cover.webp
  alt: "Kapak görseli: .NET'te Rate Limiting"
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAACwAwCdASoYAA0APu1mqk2ppaQiMAgBMB2JZQAAWpgq8Wrz40wigAD+7BGIJG1RyhMi6Unn9NUx5da0MScTahYQHTKYKWM3fJ30U3eDyc1l1EXLH+hnjAAA"
---

## Rate Limiting Nedir?

Ağ programlamada rate limiting, bir sunucuya gönderilen ya da sunucu tarafından işlenen isteklerin hızını kontrol altında tutmak için kullanılan bir tekniktir. Herkese açık bir API'ye ekleyebileceğin en basit ama en yüksek getirili şeylerden biridir — DoS trafiğine karşı korur, kontrolsüz scraping'i durdurur ve gürültücü tek bir istemcinin herkesin hakkını yemesini engeller. Bu açıdan [caching](/posts/what-is-caching/)'e yakın bir kuzeni sayılır: ikisi de backend'in üstündeki yükü sorun hâline gelmeden azaltmak için var, sadece ters yönlerden — caching gerçekten iş yapması gereken istek sayısını azaltır, rate limiting ise baştan kaç isteğin içeri gireceğine bir tavan koyar.

ASP.NET Core, .NET 7 ile birlikte kendi yerleşik rate limiting middleware'ine (`Microsoft.AspNetCore.RateLimiting`) kavuştu ve API, .NET 8, 9 ve 10 boyunca stabil kaldı — kırıcı bir değişiklik olmadı, yol boyunca sadece birkaç ekleme geldi (esas olarak yerleşik metrikler). Bugün .NET 10 kullanıyor olsan bile bu yazıdaki her şey hâlâ geçerli.

![Desktop View](/assets/img/posts/rate-limitter-schema.webp)
_Rate limiter şeması_

## Rate Limiter Algoritmaları

Yerleşik dört algoritma var. Fixed window, sliding window ve token bucket limiter'ların üçü de belirli bir zaman aralığındaki istek sayısına bir tavan koyar; concurrency limiter ise her isteğin ne kadar sürdüğüne bakmaksızın, **aynı anda** kaç isteğin çalışabileceğine tavan koyar. Hangisini seçeceğin, endpoint'in maliyetine bağlı — ucuz bir okuma isteğiyle pahalı bir rapor dışa aktarımı aynı politikayı paylaşmak zorunda değil.

### Fixed Window Limiter

Dördü arasında en basiti: sabit bir zaman penceresi, o pencere içinde izin verilen maksimum istek sayısı, ve pencere dolunca sert bir sıfırlama.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("Window", _options =>
    {
        _options.Window = TimeSpan.FromSeconds(12); // Politika her 12 saniyede bir geçerli.
        _options.PermitLimit = 5; // 12 saniyelik pencere içinde en fazla 5 istek yapılabilir.
        _options.QueueLimit = 5; // 5 istek kabul edildikten sonra, sonraki 5 istek kuyruğa alınır.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // İstekler alınış sırasına göre işlenir.
    });
});

app.UseRateLimiter();
```

#### Açıklama (Fixed Window)

* `Window`: Rate limit politikasının uygulandığı zaman aralığı. Burada 12 saniye.
* `PermitLimit`: Pencere içinde izin verilen maksimum istek sayısı. Burada, 12 saniyede 5 istek.
* `QueueLimit`: Limit dolduğunda, doğrudan reddetmek yerine kaç ek isteğin kuyruğa alınabileceği.
* `QueueProcessingOrder`: Kuyruktaki isteklerin hangi sırayla işleneceği — `OldestFirst`, en önce kuyruğa giren isteği önce işler.

Politikayı bir controller'a veya endpoint'e `[EnableRateLimiting]` attribute'uyla uygula (minimal API endpoint'inde `.RequireRateLimiting("Window")`):

```csharp
[EnableRateLimiting("Window")]
```

**Dikkat edilmesi gereken nokta:** fixed window, pencerenin sınırında beklenen limitin 2 katına kadar isteğin geçmesine izin verebilir — pencere sıfırlanmadan hemen önce bir patlama, hemen ardından pencere sıfırlanır sıfırlanmaz bir patlama daha. Sliding window limiter tam olarak bu sorunu çözmek için var.

### Sliding Window Limiter

Sliding window limiter, her pencereyi segmentlere bölüp her segmentteki istekleri ayrı ayrı takip ederek fixed window'u iyileştirir — tüm sayacı tek seferde sıfırlamak yerine.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddSlidingWindowLimiter("Sliding", _options =>
    {
        _options.Window = TimeSpan.FromSeconds(12); // Politika her 12 saniyede bir geçerli.
        _options.PermitLimit = 5; // 12 saniyelik pencere içinde en fazla 5 istek yapılabilir.
        _options.QueueLimit = 5; // 5 istek kabul edildikten sonra, sonraki 5 istek kuyruğa alınır.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // İstekler alınış sırasına göre işlenir.
        _options.SegmentsPerWindow = 5; // Pencere 5 segmente bölünür.
    });
});

app.UseRateLimiter();
```

**Nasıl çalışır:** 12 saniyelik pencere, her biri 2.4 saniyelik 5 segmente bölünür. Her segment süresi dolduğunda, o segmentte kullanılan istekler mevcut segment için tekrar havuza eklenir — tüm pencere birden sıfıra dönmek yerine, kapasite kademeli olarak geri gelir. Fixed window'daki sınır-patlaması sorununu yumuşatan şey tam olarak bu.

```csharp
[EnableRateLimiting("Sliding")]
```

### Token Bucket Limiter

Kayan bir pencereyi takip etmek yerine, token bucket limiter sabit bir hızla dolan bir token kovası tutar. Her istek bir token tüketir; kova boşsa istek kuyruğa alınır ya da reddedilir.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddTokenBucketLimiter("Token", _options =>
    {
        _options.TokenLimit = 4; // Kullanılabilir toplam token sayısı.
        _options.TokensPerPeriod = 4; // Periyot başına üretilen token sayısı.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Kuyruktaki istekler alınış sırasına göre işlenir.
        _options.QueueLimit = 2; // Tokenlar tükendikten sonra, sonraki 2 istek kuyruğa alınır.
        _options.ReplenishmentPeriod = TimeSpan.FromSeconds(12); // Tokenların yenilendiği periyot.
    });
});

app.UseRateLimiter();
```

#### Açıklama (Token Bucket)

* `TokenLimit`: Kovanın tutabileceği maksimum token sayısı — tek seferde kabul etmeye razı olduğun patlamanın büyüklüğü.
* `TokensPerPeriod` / `ReplenishmentPeriod`: Kaç token geri eklenir ve ne sıklıkla. Burada, her 12 saniyede 4 token.
* `QueueLimit` / `QueueProcessingOrder`: Diğer limiter'larla aynı anlama gelir.

```csharp
[EnableRateLimiting("Token")]
```

Bu, sürdürülen ortalama hızı artırmadan ara sıra patlamalara (normalde sessiz ama arada bir anda birkaç istek gönderen bir istemci) izin vermek istediğinde tercih edeceğin seçenek.

### Concurrency Limiter

Dördün en farklısı — **zaman içinde kaç istek** geldiğiyle değil, **şu an aynı anda kaç istek** çalıştığıyla ilgilenir. Maliyeti isteklerin ne kadar sürdüğüne bağlı olan, gerçekten pahalı bir işlem yapan bir endpoint'i (bir rapor üretimi, büyük bir dosya yükleme) korumak için kullanışlıdır — isteklerin ne sıklıkla geldiğine değil.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.AddConcurrencyLimiter("Concurrency", _options =>
    {
        _options.PermitLimit = 5; // Maksimum eşzamanlı istek sayısı.
        _options.QueueLimit = 2; // 5 istek kabul edildikten sonra, sonraki 2 istek kuyruğa alınır.
        _options.QueueProcessingOrder = QueueProcessingOrder.OldestFirst; // Kuyruktaki istekler alınış sırasına göre işlenir.
    });
});

app.UseRateLimiter();
```

Bir istek başladığında bir izin alır, bittiğinde bırakır — yani yavaş bir istek, çalıştığı sürece kendi yerini işgal eder; bu, sadece istek **sayısıyla** ilgilenen diğer üç limiter'dan farklıdır.

```csharp
[EnableRateLimiting("Concurrency")]
```

## Hepsini Bir Araya Getirmek: Gerçekten Çalıştırabileceğin Bir Minimal API

Yukarıdaki her şey tek başına bir politika tanımı. İşte tamamının gerçek, çalıştırılabilir bir minimal API'ye bağlanmış hâli — `dotnet new`'den bir isteğin gerçekten reddedildiğini görmeye kadar.

```bash
dotnet new webapi -n RateLimitDemo -minimal
cd RateLimitDemo
```

`Program.cs`'i şununla değiştir:

```csharp
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("fixed", opt =>
    {
        opt.PermitLimit = 3;
        opt.Window = TimeSpan.FromSeconds(10);
        opt.QueueLimit = 0;
    });
});

var app = builder.Build();

app.UseRateLimiter();

app.MapGet("/ping", () => Results.Ok(new { message = "pong", at = DateTime.UtcNow }))
   .RequireRateLimiting("fixed");

app.Run();
```

`dotnet run` ile çalıştır, yazdırdığı portu not et, sonra başka bir terminalden art arda birkaç kez istek at:

```bash
for i in {1..5}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:5000/ping; done
```

Üç kez `200` göreceksin, sonra kalanı için `429` — ta ki 10 saniyelik pencere sıfırlanıp limit tekrar müsait olana kadar.

## Sadece Genel Değil, İstemci Başına Rate Limiting

Şimdiye kadarki tüm örnekler her çağıran arasında tek bir limiter paylaşıyor — bu bir demo için gayet iyi ama üretimde genelde istediğin şey bu değil: agresif bir istemci, herkesin bütçesini tek başına tüketebilmemeli. `PartitionedRateLimiter`, trafiği senin için "istemci"yi neyin tanımladığına göre (kullanıcı ID'si, IP adresi, API anahtarı) ayrı kovalara böler.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.User.Identity?.Name
                ?? httpContext.Connection.RemoteIpAddress?.ToString()
                ?? "anonymous",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 20,
                Window = TimeSpan.FromMinutes(1)
            }));
});
```

Her farklı partition anahtarı kendi bağımsız sayacına sahip olur — böylece kimliği doğrulanmış bir kullanıcı (ya da anonim trafik için IP), paylaşılan bir bütçe için herkesle yarışmak yerine kendi dakikada-20-istek bütçesine sahip olur.

Bunu üretimde kullanmadan önce bilinmesi gereken bir şey: sadece istemcinin bildirdiği IP'ye göre bölümleme, `RemoteIpAddress`'e güvenmek anlamına gelir — bu değer sahtelenebilir. Düzgün yapılandırılmış bir reverse proxy'nin arkasında makul bir varsayılandır, ama gerçekten kararlı bir saldırganı durdurman gerekiyorsa (sadece normal trafiği yumuşatmak değil) kimlik doğrulamanın yerini tutmaz.

## Red Yanıtını Özelleştirmek

Varsayılan olarak, reddedilen bir istek gövdesiz, çıplak bir `503` alır. Neredeyse her zaman daha faydalı bir şey istersin — bir `Retry-After` header'ı taşıyan bir `429`, böylece düzgün davranan istemciler körlemesine tekrar denemek yerine ne zaman tekrar denemenin anlamlı olduğunu bilir. Bu, [merkezi hata yönetimi](/posts/dotnet8-global-error-handling/)'nin aynı fikri — her yerde try/catch bloğu dağıtmak yerine tek bir handler'ın karar vermesi: reddedilen bir isteğin nasıl göründüğüne her endpoint'in kendi başına karar vermesi yerine, tek bir yer bunu belirler.

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;

        if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
        {
            context.HttpContext.Response.Headers.RetryAfter =
                ((int)retryAfter.TotalSeconds).ToString();
        }

        await context.HttpContext.Response.WriteAsJsonAsync(new
        {
            error = "Too many requests. Please try again later."
        }, cancellationToken);
    };

    // ...limiter'ların buraya gelir, öncekiyle aynı
});
```

`RetryAfter` metadata'sı sadece bunu gerçekten hesaplayabilen limiter'lar tarafından doldurulur — fixed ve sliding window limiter'lar pencerelerinin ne zaman sıfırlanacağını bilir, ama token bucket ve concurrency limiter'lar bunu set etmez, çünkü ikisinin de sabit bir sıfırlanma noktası yoktur.

## Metrikler Üzerine Bir Not

Bunu üretimde çalıştırıyorsan, middleware ayrıca `Microsoft.AspNetCore.RateLimiting` altında yerleşik metrikler de üretir (politika başına kiralanan, kuyruğa alınan ve reddedilen istekler) — bunlar `System.Diagnostics.Metrics`'e ve zaten sahip olduğun OpenTelemetry/dashboard kurulumuna bağlanır. Limitleri tahmine dayalı değil gerçek trafiğe göre ayarlamadan önce bunu kurmaya değer.

## Sonuç

Yerleşik rate limiting middleware'i, üçüncü taraf bir pakete ya da Redis bağımlılığına hiç gerek kalmadan gerçek dünyadaki vakaların büyük çoğunluğunu karşılıyor. Karşı korunmak istediğin trafiğin şekline göre bir algoritma seç, bir çağıranın diğerlerini aç bırakmaması gerekiyorsa istemci başına böl, ve reddedilen isteklere çağırana gerçekten ne yapması gerektiğini söyleyen bir yanıt ver.

Faydalı bulmuşsundur umarım. Sorun olursa [LinkedIn](https://www.linkedin.com/in/alparslanakbas/)'den ulaşabilirsin.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Okuduğunuz için teşekkürler_
