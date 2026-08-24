---
title: ".NET'te Caching: Eksiksiz Rehber"
description: ".NET'te caching'e pratik bir bakış: in-memory ile distributed farkı, Output Caching, HybridCache ve doğru seçimi yapman için bir karar tablosu."
date: 2026-08-25 01:30 +0300
translation_key: what-is-caching
categories: [Data, Caching]
tags: [caching, redis, aspnet-core, performance]
image:
  path: /assets/img/posts/what-is-caching/cover.webp
  alt: "Kapak görseli: Caching'e Giriş"
  lqip: "data:image/webp;base64,UklGRloAAABXRUJQVlA4IE4AAACQAwCdASoYAA0APu1oqk6ppiQiMAgBMB2JZQAAWpgEFP0qiC1kAP7sEYgkbVHKExx4p/+8twyfCbOoIVp1qoRaZFqPNKQp1eBWfcmEAAA="
---

## Caching Nedir?

Modern yazılım uygulamalarında, özellikle web'de, kullanıcı sayısı arttıkça kaynak kısıtları sık sık bir soruna dönüşür. Bu durum, artan sistem kaynağı ihtiyacına yol açar ve beraberinde ek maliyetler nedeniyle daha büyük bir bütçe gerektirir.

Kaynak kapasitesini genişletmenin yanı sıra, kullanıcı etkileşimlerinden doğan maliyetleri azaltmak da gerekir. Bu maliyetlere katkıda bulunan birçok faktörden sadece birini — veritabanı işlemlerini — ele alalım: kullanıcı isteklerine bağlı olarak uygulama ile veritabanı arasında milyarlarca veri noktası taşınıyor. Bu devasa enerji tüketimi, zamanla veritabanının talepleri karşılamakta zorlanmasına ve sonunda daha fazla veritabanı sunucusu yatırımına ihtiyaç duyulmasına yol açabilir.

Caching, kaynak kullanımını optimize etmek, performansı artırmak ve bu tür maliyetleri en aza indirmek için stratejik bir çözüm sunar.

Bu tür durumlarda caching mekanizması, veritabanları üzerindeki yükü azaltmak ve isteklerin büyük çoğunluğunu ek yatırım gerektirmeden dinamik olarak karşılamak için kullanılır.

Caching, sık erişilen verinin veritabanı dışında alternatif konumlarda saklandığı bir tekniktir. Bu sayede veri, sistemi her istekte tekrar tekrar yormadan daha hızlı alınıp işlenebilir.

Caching doğru yerde ve doğru zamanda uygulandığında, uygulama performansını ve ölçeklenebilirliğini önemli ölçüde artırır. Trafiğin yoğunluğundan bağımsız olarak, ek kapasite yükseltmesine gerek kalmadan 1.000.000 kullanıcıya da 100 kullanıcıya sunduğu performansı tutarlı şekilde sunar.

## Neden Caching Kullanmalıyız?

Her istekte "stabil" veriyi tekrar tekrar veritabanından çekmek yerine, veri ilk sorgudan sonra cache'lenmeli ve sonraki istekler cache'ten karşılanmalıdır. Bu yaklaşım, **"stabil"** veri içeren tüm işlemler için ciddi bir performans artışı sağlar — her istekte değişmeyen, ara sıra değişse bile (bir ürün kataloğu, bir kullanıcının profili, saatte bir yenilenen bir döviz kuru) veri anlamında.

## Cache Invalidation ve Expiration

Akılda tutulması gereken temel kural şu: cache'lenmiş veri, orijinal verinin bir kopyasıdır. Veritabanındaki orijinal veride yapılan değişiklikler, cache'lenmiş verinin bayatlamasına (stale olmasına) yol açabilir. Doğru yönetilmezse, bayat veri beklenmedik sorunlara ve uygulama krizlerine neden olabilir. Bunu doğru yapmanın iki parçası var:

* **Expiration (Süre Sonu).** Cache'lenmiş kayıtların bir ömrü olması gerekir. **Absolute expiration (mutlak süre sonu)**, bir kaydı oluşturulduktan sabit bir süre sonra kaldırır — ne sıklıkla okunduğuna bakmaksızın. Belirli bir takvime göre değişen veriler için iyidir (günlük bir rapor, saatlik bir kur). **Sliding expiration (kayan süre sonu)** ise kayıt her okunduğunda zamanlayıcıyı sıfırlar — birisi gerçekten kullandığı sürece cache'te kalması, kimse kullanmayı bırakınca da kaybolması gereken "hâlâ güncel" veriler için iyidir.
* **Invalidation (Geçersiz Kılma).** Bazen expiration'ı beklemek istemezsin — altta yatan veri **şu anda** değişti ve cache'in bunu bilmesi gerekiyor. En basit yaklaşım, kaynak veriyi güncelleyen aynı kod yolunda cache kaydını da açıkça silmek (veya üzerine yazmak) olur. Bir cache'i baştan doldurmanın en yaygın deseni **cache-aside**'dır: önce cache'e bak, bulamazsan kaynaktan oku, sonucu cache'e kaydet, sonra döndür. Bu yazıdaki neredeyse her örnek — ve [In-Memory Cache](/posts/what-is-in-memory-cache/) ile [Distributed Cache](/posts/what-is-distributed-cache/) yazılarındaki her yardımcı metot — cache-aside'ın bir varyasyonudur.

## Caching Türleri

Caching iki ana türe ayrılabilir: **Local Caching** ve **Global Caching**.

* **Local Caching (In-Memory Caching)**
Bu tür caching, uygulamanın çalıştığı makinenin bellek alanında işler. **Private Caching** olarak da adlandırılır. Nasıl çalıştığını ve çoklu instance kurulumundaki en büyük dezavantajını görmek için **[In-Memory Cache](/posts/what-is-in-memory-cache/)** yazısına bak.
* **Global Caching (Distributed Caching)**
Bu caching sistemi birden fazla sunucuya dağılmıştır ama tek bir bütün gibi çalışır. **Public Caching** olarak da bilinir. Tam resim için **[Distributed Cache](/posts/what-is-distributed-cache/)** yazısına, en yaygın gerçek dünya implementasyonu için de **[Redis](/posts/what-is-redis/)** serisine bak.

## .NET'te Caching: Gerçekte Hangi API'ye İhtiyacın Var?

.NET'in bir şeyi cache'lemenin dört farklı yerleşik yolu var ve her biri farklı bir sorunu çözüyor. Yanlış olanı seçmek, gördüğüm en yaygın caching hatası — genelde alışkanlıktan `IMemoryCache`'e uzanılıyor ama aslında distributed bir şey gerekiyor, ya da hiç process dışına çıkması gerekmeyen bir şey için tam bir `IDistributedCache` gidiş-dönüşü ekleniyor. Her birinin gerçekte ne için olduğuna bakalım.

### IMemoryCache — process'e özel obje cache'i

`IMemoryCache`, çalışan process'in belleğinde herhangi bir .NET objesini saklar. En basit ve en hızlı seçenektir — serialization yok, ağ üzerinden gidiş-dönüş yok — ama tek bir instance'a özeldir, ki bu tam olarak [In-Memory Cache](/posts/what-is-in-memory-cache/) yazısında ele alınan veri tutarlılığı sorunudur. Uygulama tek bir instance olarak çalışıyorsa, ya da cache'lediğin şeyin instance'lar arasında biraz farklı olması sorun değilse bunu tercih et.

### IDistributedCache — paylaşılan, process-dışı obje cache'i

`IDistributedCache`, serialize edilmiş veriyi harici bir depoda (Redis, SQL Server veya benzeri) saklar, böylece uygulamanın her instance'ı aynı cache'i görür. Instance'lar arasında tutarlılık karşılığında küçük bir gecikme (cache deposuna bir ağ çağrısı) kabul eder. [Distributed Cache](/posts/what-is-distributed-cache/) yazısının ve [Redis](/posts/what-is-redis/) serisinin arkasındaki arayüz budur.

### Output Caching (.NET 7+) — tüm HTTP yanıtlarını cache'lemek

Output Caching, kendi kodundan çağırdığın bir cache objesi değil, bir middleware'dir — GET/HEAD isteklerinin **tüm HTTP yanıtını**, varsayılan olarak istek URL'ine göre anahtarlanmış şekilde cache'ler. Deklaratiftir: bir endpoint'i cache'lenebilir olarak işaretlersin, gerisini middleware halleder.

```csharp
builder.Services.AddOutputCache();

var app = builder.Build();
app.UseOutputCache();

app.MapGet("/weather", GetWeatherAsync).CacheOutput();
```

Buna başvurmadan önce bilmekte fayda var:

* Varsayılan olarak sadece GET/HEAD isteklerine verilen HTTP 200 yanıtları cache'lenir; cookie set eden veya kimliği doğrulanmış bir kullanıcıdan gelen istekler asla cache'lenmez — yani bir kullanıcının yanıtı yanlışlıkla başka birine sızamaz.
* **Tag'ler**, cache'lenmiş yanıt gruplarını birlikte silmeni sağlar (`.CacheOutput(b => b.Tag("tag-blog"))`, sonra `IOutputCacheStore.EvictByTagAsync("tag-blog")`) — bir güncellemeden sonra "bu ürünü gösteren her sayfayı geçersiz kıl" gibi durumlar için kullanışlıdır.
* Depolama varsayılan olarak process içi bellektir, `IMemoryCache` ile aynı kısıtlamayı taşır. Paylaşılan, çoklu instance'lı bir depo için `AddStackExchangeRedisOutputCache` kullan — **`AddStackExchangeRedisCache` DEĞİL**, o farklı bir API'dir (ve Microsoft'un kendi dokümanına göre bunun için önerilmiyor), çünkü output caching'in tag-based eviction'ı düz `IDistributedCache`'in garanti etmediği atomik işlemlere ihtiyaç duyar.

Tüm yanıtı olduğu gibi cache'lenebilen GET endpoint'leri için kullan — bir ürün listesi, bir hava durumu tahmini, bir RSS feed'i.

### HybridCache (.NET 9) — veri caching'i için modern varsayılan

HybridCache dördü arasında en yenisi ve bundan sonra doğrudan `IMemoryCache`/`IDistributedCache` kullanımının çoğunun yerini alması amaçlanıyor. İkisini tek bir API'nin arkasında iki katmanlı bir cache'te (hızlı process-içi L1, opsiyonel process-dışı L2) birleştiriyor, ve düz `IDistributedCache` kodunun her zaman elle etrafından dolaşmak zorunda kaldığı gerçek bir soruna çözüm getiriyor: **cache stampede**. Aynı anahtar için on eşzamanlı istek aynı anda cache'i ıskalarsa, saf cache-aside kodu pahalı factory'yi (DB sorgusu, API çağrısı) on kez tetikler. `HybridCache`, aynı anahtar için eşzamanlı çağıranları koordine eder, böylece factory bir kez çalışır ve geri kalan herkes o tek sonucu bekler.

```csharp
builder.Services.AddHybridCache();

public class ProductService(HybridCache cache)
{
    public async Task<Product> GetProductAsync(int id, CancellationToken ct)
    {
        return await cache.GetOrCreateAsync(
            $"product-{id}",
            async token => await LoadProductFromDbAsync(id, token),
            cancellationToken: ct);
    }
}
```

Daha önce `IMemoryCache` veya `IDistributedCache`'e uzanacağın her şey için iyi bir varsayılandır — HTTP yanıtı değil, uygulama verisi için. Ayrıca tag-based invalidation'a da sahiptir (fiziksel değil mantıksal: `RemoveByTagAsync`, o noktadan önce oluşturulan kayıtları hemen silmek yerine bayat olarak işaretler, yani eski değerler doğal olarak süresi dolana kadar bellekte yer kaplamaya devam eder). Beni şaşırtan bir detay: .NET 9 ile kutudan çıksa da, `HybridCache` .NET Standard 2.0 ve .NET Framework 4.7.2'yi de destekleyen sıradan bir NuGet paketi (`Microsoft.Extensions.Caching.Hybrid`) olarak dağıtılıyor — kullanmak için .NET 9'da olman gerekmiyor.

### Hangisini seçmeli

| Senaryo | Kullan |
| --- | --- |
| Tek instance, küçük/kısa ömürlü veri, restart'tan sağ çıkması gerekmiyor | `IMemoryCache` |
| Birden fazla instance, hepsinde tutarlı veri gerekiyor | `IDistributedCache` (genellikle Redis üzerinden — bkz. [Redis serisi](/posts/what-is-redis/)) |
| Tüm yanıtı olduğu gibi cache'lenebilen bir GET endpoint'i | Output Caching |
| Rastgele veri cache'lemek (tam bir HTTP yanıtı değil), özellikle yüksek eşzamanlı okuma yükünde | `HybridCache` |
| Bugün yeni bir projeye başlıyorsun, genel amaçlı veri caching'i | `HybridCache` — çoğu durumda ilk ikisinin yerini tutar ve üstüne ücretsiz stampede koruması ekler |

Bunların hiçbiri birbirini dışlamaz — tipik bir uygulama, okuma ağırlıklı birkaç GET endpoint'inde Output Caching, hesaplaması pahalı veri çektiği her yerde de HybridCache kullanabilir.

---

Bu serinin geri kalanı, en yaygın iki gerçek dünya yapı taşını derinlemesine ele alıyor: [In-Memory Cache](/posts/what-is-in-memory-cache/) ve [Distributed Cache](/posts/what-is-distributed-cache/) yazıları temelleri daha derinlemesine kapsıyor, [Redis](/posts/what-is-redis/) serisi de en yaygın distributed cache implementasyonunu uçtan uca ele alıyor — kurulumu, veri tipleri ve veritabanlarının içeride nasıl çalıştığı.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
*Okuduğunuz için teşekkürler*
