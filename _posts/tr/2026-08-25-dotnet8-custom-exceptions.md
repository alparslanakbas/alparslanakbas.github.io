---
title: "ASP.NET Core 8'de Exception'ları Otomatik Yönetmek"
description: "ASP.NET Core'un ExceptionFilterAttribute'uyla hata yönetimini merkezileştirmek: özel exception'ları otomatik tutarlı API yanıtlarına çevirmek."
date: 2026-08-25 02:30 +0300
translation_key: dotnet8-custom-exceptions
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-8, exception-handling, filters]
series: "ASP.NET Core Error Handling"
series_order: 1
image:
  path: /assets/img/posts/dotnet8-custom-exceptions/cover.webp
  alt: "Kapak görseli: ASP.NET Core 8'de Exception'ları Otomatik Yönetmek"
  lqip: "data:image/webp;base64,UklGRlwAAABXRUJQVlA4IFAAAABwAwCdASoYAA0APu1kqk4ppaQiMAgBMB2JZQAAWpRiXw9MB1AA/uwRiCRtUcoUJE87XV8nrcq8TTlUTahYVTsr5gSDyMMs4aCR1KD9ByYAAA=="
---

## Giriş

Merhaba,

Asp.NET Core'da API geliştiriyorsanız, eminim aşağıdaki yapı size oldukça tanıdık gelecektir:

```csharp
public IActionResult Get(Guid id)
{
    var product = _productService.GetById(id);
    if (product is null)
        return NotFound();
    return Ok(product);
}
```

Bu koda baktığınızda yanlış bir şey görüyor musunuz? Pek sayılmaz, değil mi? Basitçe bir ürünü id'sine göre sorgulayan ve ilgili nesne geldiyse döndüren, gelmediyse 'NotFound' ile hata döndüren bir action görüyoruz. Bu son derece doğal bir kodlama gibi görünüyor. Ve öyle de. Ancak her action'da bu tarz nesnelerin yokluğunu kontrol etmek ve kodumuzu bu kontrolün sonucuna göre kurgulamak, sürekli kendimizi tekrar ettiğimiz anlamına gelmiyor mu? Ayrıca böyle bir durumda, bir nesne null döndüğünde bunu loglamak istersek, aynı kodu her işlemde ayrı ayrı yazmamız gerekmez mi?

Dahası, bu işlemde, iş katmanı görevi gören servisin, ilgili id için sorgulama sonucunda hiçbir nesne dönmediğinde problemi farklı bir katmana, controller'a taşıması yersiz ve saçma olmaz mı? Sonuçta, gelen id için hiçbir nesne bulunamadığında iş mantığını çalıştıran katmanın bir exception fırlatarak mimariyi uyarması daha mantıklı olmaz mıydı?

O halde bu koddan nesne kontrolünü kaldırmayı ve bizi tekrara düşüren bu tarz durumları daha merkezi hale getirmeyi sorgulamalıyız... Ama bunu nasıl yapacağız? Cevap: Asp.NET Core mimarisinin damarlarından biri olan Action Filter'lar...

## Asp.NET Core'da 'Filter' Tam Olarak Nedir?

Asp.NET Core'daki filter'lar, istek pipeline'ının belirli aşamalarından önce veya sonra herhangi bir kod çalıştırmanın yollarından biridir — her istek için değil, belirli action'lar için çalışan, [middleware](/posts/using-request-response-middleware-and-install-nuget/)'in daha dar kapsamlı bir kuzenidir. C# dilinde bu filter'lar attribute olarak tasarlanmıştır. Asp.NET Core'da yukarıda bahsedilen gibi birçok filter olsa da, fırlatılan exception'a göre tetiklenecek filter **ExceptionFilterAttribute**'dur.
Şimdi hızlıca basit bir örnek uygulayalım.

'Product' entity'si:

```csharp
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }
}
```

'ProductService' sınıfı ve 'IProductService' arayüzü:

```csharp
public interface IProductService
{
    Product GetById(Guid id);
}
public class ProductService : IProductService
{
    List<Product> _products = new()
    {
        new() { Id = Guid.NewGuid(), Name = "Book" },
        new() { Id = Guid.NewGuid(), Name = "Pencil" }
    };
    public Product GetById(Guid id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        return product;
    }
}
```

Şimdiye kadar ihtiyacımız olan tek şey, 'ProductService'in 'GetById' metodunda ilgili id'ye karşılık gelen bir nesnenin gelip gelmediğini kontrol etmek ve gelmezse bir hata fırlatmak. Bunun için fırlatılacak exception'ı özel (custom) olarak tasarlamak faydalı olur.

```csharp
public class DataNotFoundException : Exception
{
    public DataNotFoundException(string type, object id) 
        : base($"The object with id {id} of type {type} was not found!") { }
}
```

Ve şimdi bahsedilen kontrolü 'GetById' fonksiyonunda gerçekleştirebiliriz:

```csharp
public Product GetById(Guid id)
{
    var product = _products.FirstOrDefault(p => p.Id == id);
    if (product is null)
        throw new DataNotFoundException(nameof(Product), id);
    return product;
}
```

## Özel Bir ExceptionFilterAttribute Oluşturmak

Yukarıda tasarlandığı gibi, id'ye karşılık gelen bir nesne yoksa bir hata fırlatılacak. Bu yüzden bu hataya karşılık etkinleşecek filter'ı özel olarak oluşturmamız gerekiyor.

```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
public class ExceptionFilter : ExceptionFilterAttribute
{
    public async override Task OnExceptionAsync(ExceptionContext context)
    {
        //Fırlatılan exception'ın status code'unu bilmediğimizde  
        //varsayılan olarak '500 Internal Server Error' ayarlıyoruz.
        var statusCode = HttpStatusCode.InternalServerError;
 
        //Fırlatılan exception DataNotFoundException ise
        //status code'u '404 Not Found' yapıyoruz.
        if (context.Exception is DataNotFoundException)
            statusCode = HttpStatusCode.NotFound;
 
        //Bu isteğe verilecek yanıtın status code'unu ve 
        //sonucunu değiştirerek dönebiliriz.
        context.HttpContext.Response.ContentType = "application/json";
        context.HttpContext.Response.StatusCode = (int)statusCode;
 
        context.Result = new JsonResult(new
        {
            error = new[] { context.Exception.Message },
            statusCode = (int)statusCode,
            stackTrace = context.Exception.StackTrace  
        });
    }
}
```

Görüldüğü gibi, bir hata sırasında devreye girecek action filter'ımız yukarıdaki gibi. Bu tabii ki daha fazla özelleştirilebilir, ama şimdilik bununla yetineceğiz. Şimdi geriye tek bir şey kalıyor: oluşturulan bu filter'ı Asp.NET Core mimarisine bildirmek. Bunun için iki farklı yöntem seçebiliriz.

### 1. Yöntem - Global Filter Olarak Eklemek

Bir filter'ı global olarak eklemek için, 'Program.cs' dosyasındaki 'AddControllers' servisinde aşağıdaki gibi belirtmek yeterlidir.

```csharp
        builder.Services.AddControllers(options => options.Filters.Add(typeof(ExceptionFilter)));
        .
        .
        .
    .
    .
    .
```

Global olarak eklenen filter'lar, kendi türlerine özgü tüm action durumlarında tetiklenir. Bu yüzden bir filter'ı yalnızca özelleştirilmiş durumlarda kullanmak istiyorsanız 2. yöntemi tercih etmelisiniz.

### 2. Yöntem - Controller veya Action Bazlı Attribute Olarak Eklemek

Oluşturulan filter aslında bir attribute'tur, dolayısıyla bu şekilde de kullanılabilir.

```csharp
[HttpGet("{id}")]
[ExceptionFilter]
public IActionResult Get(Guid id)
{
    var product = _productService.GetById(id);
    return Ok(product);
}
```

Bu kullanım, yapısal olarak daha tercih edilebilir bir davranış sergilememizi sağlar ve ilgili filter'ın gereksiz yerlerden tetiklenmesini engeller.

## Test Edelim

Bu kadar... Şimdi tek yapmamız gereken bu API'ye bir istek göndererek test etmek.

```text
/api/Products/1 sonra /api/Products/10
```

![Desktop View](/assets/img/posts/test-api-1.webp)
_Success-Test_

![Desktop View](/assets/img/posts/test-api-2.webp)
_Error-Test_

Görüldüğü gibi, iş mantığında üretilecek verinin kontrol sorumluluğunu bir filter aracılığıyla merkezileştirdik ve sonraki action'lardaki ihtiyaç yüzünden ortaya çıkabilecek kod israfını önledik.

Bunun daha profesyonel bir yaklaşım olduğu da açık.

## Bugün Nereye Oturuyor

`ExceptionFilterAttribute` hâlâ yukarıda gösterildiği gibi çalışıyor — MVC filter'larıyla ilgili hiçbir şey değişmedi. Ama daha yeni seçeneklere göre nereye oturduğunu bilmekte fayda var: bu tarz bir filter, hata yönetimini (tüm uygulama yerine) belirli bir controller ya da action'a özgü tutmak istediğinizde doğru araç — .NET 8'de tanıtılan [`IExceptionHandler` arayüzü](/posts/dotnet8-global-error-handling/) size bunu tam olarak sunmaz, o tasarım gereği tüm uygulama genelinde çalışır. "Tüm API için tek, tutarlı bir hata şekli" istediğiniz çoğu durumda .NET 8 ve sonrasında daha iyi varsayılan `IExceptionHandler` artı `ProblemDetails`'tır (aynı yazıda ele alınıyor); özellikle controller başına farklı davranış gerektiğinde bu tarz bir filter'a başvurun.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
