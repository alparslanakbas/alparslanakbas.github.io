---
title: "ASP.NET Core 8 – Global Hata Yönetimi"
description: "ASP.NET Core'da global hata yönetimi: özel middleware ile IExceptionHandler, ProblemDetails ve .NET 10'daki gerçek bir diagnostics değişikliği."
date: 2026-08-25 02:40 +0300
translation_key: dotnet8-global-error-handling
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-8, error-handling, middleware, problemdetails]
series: "ASP.NET Core Error Handling"
series_order: 2
image:
  path: /assets/img/posts/dotnet8-global-error-handling/cover.webp
  alt: "Kapak görseli: ASP.NET Core 8 – Global Hata Yönetimi"
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAAAQAwCdASoYAA0APu1kqU2ppaOiMAgBMB2JZQAAWpcmzMAA/uwRiCRtUcoUJE9JwHoggsSiFLDYWPNgCbWJn/kc5/idSLDlsBmHW987A+Q6y6iLlj/0gdgA"
---

## Giriş

Merhaba,

Uygulamalarımızı ne kadar dikkatli ve güvenli tasarlarsak tasarlayalım, yazılımın çalışmasının doğal bir parçası olan hatalar kaçınılmaz olarak ortaya çıkacaktır. Bu özellikle web uygulamaları için geçerlidir; burada bu tür durumlar neredeyse kaçınılmaz kabul edilebilir. Ancak iyi bir yazılım geliştirme sürecinde, olası hataların sayısı en aza indirilebilir ve uygulamalar doğru test stratejileri ve hataya dayanıklı bir kodlama yaklaşımıyla daha sağlam ve güvenilir hale getirilebilir.

Bu önlemler alınsa bile hatalar bize kaçınılmazlıklarını hatırlatmaya devam edecektir. Er ya da geç, dış dünyadan gelen girdiler, işlemin temelindeki veritabanı sorunları ya da tam olarak anlayamayacağımız sayısız bilinmeyen faktör yüzünden ortaya çıkacaklardır.

Böyle durumlarda sadece "elimizden geleni yaptık, kısmetmiş" demeyeceğiz. Bunun yerine hataları kullanıcılara açık etmeden yöneteceğiz. İstenen kullanıcı deneyimini korumak için gerekli manipülasyonları yaparak hataları ele almak üzere farklı davranışlar uygulayacağız.

Aynı zamanda, gerektiğinde izleme (tracing) ve loglama yaparak süreci en ideal haline getirmeye odaklanacak, yazılım yaşam döngüsündeki risk yönetiminin bu kritik bileşenlerinin etkili şekilde ele alınmasını sağlayacağız.

"[ASP.NET Core'da Exception'ları Otomatik Yönetmek](/posts/dotnet8-custom-exceptions/)" başlıklı önceki yazımızda, bu ideal duruma ulaşmak için uygulayabileceğimiz en etkili yöntemi keşfedip deneyimlemiştik.

## Başlayalım

Alternatif olarak, aşağıdaki gibi bir middleware kullanarak süreçteki tüm olası hataları ele almak için bir yaklaşım da benimseyebiliriz.

```csharp
public class ExceptionHandlingMiddleware(ILogger<ExceptionHandlingMiddleware> logger, RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception exception)
        {
            string errorMessage = $"An error occurred. Error message: {exception.Message}";
            logger.LogError(exception, errorMessage);
 
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            await context.Response.WriteAsJsonAsync(new
            {
                Title = "Server Error",
                Status = context.Response.StatusCode,
                Message = errorMessage
            });
        }
    }
}
```

Tabii bu middleware'in aşağıdaki gibi yapılandırılmış olması koşuluyla:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
builder.Services.AddLogging();
 
var app = builder.Build();
 
app.UseMiddleware<Global.Error.Handling.Example.Traditional_Method.ExceptionHandlingMiddleware>();
 
app.MapGet("/", () =>
{
    throw new Exception("bla bla bla error...");
});
 
app.Run();
```

Görüldüğü gibi ASP.NET Core, olası hata senaryolarına yanıt vermek için bize birkaç seçenek sunuyor. Bu seçeneklere ek olarak, ASP.NET Core 8 hata durumlarını etkili şekilde yönetmek için IExceptionHandler arayüzünü tanıtıyor.

```csharp
public class ExceptionHandler(ILogger<ExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = "Server Error",
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

Yukarıdaki kod bloğunda görüldüğü gibi bu arayüz, TryHandleAsync metodunun uygulanmasını zorunlu kılar. Bir boolean değer döndürür: olası hata için bir handle mevcutsa true, değilse false.

Bu özel exception handler sınıfını ASP.NET Core istek pipeline'ına dahil etmek için aşağıdaki yapılandırma yeterlidir:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
builder.Services.AddLogging();
 
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.ExceptionHandler>();
builder.Services.AddProblemDetails();
 
var app = builder.Build();
 
app.UseExceptionHandler();
 
app.MapGet("/", () =>
{
    throw new Exception("bla bla bla error...");
});
 
app.Run();
```

Görüldüğü gibi, 5. satırda ilgili servisi uygulamaya bağımlılık olarak eklemek için AddExceptionHandler metodunu kullanıyoruz. 6. satırda, olası hatalar hakkında detaylar içeren bir yanıt üretmek için AddProblemDetails servisini ekliyoruz. Son olarak, 10. satırda UseExceptionHandler middleware'ini çağırarak ExceptionHandlerMiddleware'i etkinleştiriyoruz.

Uygulamayı bu haliyle derleyip çalıştırdığımızda, exception handler sınıfının olası hata senaryolarında aşağıdaki gibi devreye girdiğini gözlemleyebiliriz:

```json
{
    "title": "Server Error",
    "status": 500,
    "Message": "An error occurred. Error message: bla bla bla errorr..."
}
```

Ayrıca uygulamaya birden fazla exception handler sınıfı ekleyip, kayıt sırasına göre olası hata senaryolarını yönetebilirsiniz. Örneğin:

```csharp
public class DivideByZeroExceptionHandler(ILogger<DivideByZeroExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        if (exception is not DivideByZeroException)
            return false;
 
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = exception.GetType().ToString(),
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

```csharp
public class NullReferenceExceptionHandler(ILogger<NullReferenceExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        if (exception is not NullReferenceException)
            return false;
 
        string errorMessage = $"An error occurred. Error message:  {exception.Message}";
        logger.LogError(exception, errorMessage);
 
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        await httpContext.Response.WriteAsJsonAsync(new
        {
            Title = exception.GetType().ToString(),
            Status = httpContext.Response.StatusCode,
            Message = errorMessage
        });
 
        return true;
    }
}
```

Burada oluşturduğumuz exception handler sınıflarına dikkat ederseniz, hatanın davranışsal olarak değerlendirildiğini fark edersiniz. Uygun değilse false değeri döner, bu da o exception'ın o sınıf tarafından ele alınmadığını gösterir. Bu, bir sonraki handler sınıfının devralmasını sağlar ve süreç, true döndüren handler sınıfına ulaşana kadar devam eder.

Bu nedenle, en genel hata tipini ele alan handler sınıfı aşağıdaki gibi en sona tanımlanmalıdır.

```csharp
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.DivideByZeroExceptionHandler>();
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.NullReferenceExceptionHandler>();
builder.Services.AddExceptionHandler<Global.Error.Handling.Example.New_Method.ExceptionHandler>();
```

Bu, bir hata oluştuğunda önce DivideByZeroExceptionHandler'ın kontrol edileceği anlamına gelir. False dönerse, sırada NullReferenceExceptionHandler kontrol edilir. O da false dönerse, en son ExceptionHandler kontrol edilir. Bunlardan herhangi biri true dönerse, diğerleri değerlendirilmez. Ancak hepsi false dönerse, kullanıcıya hiçbir sonuç dönülmez.

ASP.NET Core 8'de tanıtılan IExceptionHandler ile, middleware yaklaşımına kıyasla hata senaryolarını daha etkili ve esnek şekilde ele alabileceğimize inanıyorum.

## Güncelleme: .NET 10'da Gerçek Bir Breaking Change

Yukarıdakilerin hepsi .NET 10'da yazıldığı gibi çalışmaya devam ediyor — ama yükseltme yapıyorsanız bilmekte fayda olan davranışsal bir değişiklik var. Daha önce, bir `IExceptionHandler` bir exception'ı ele aldığında (`TryHandleAsync`'ten `true` döndürdüğünde) middleware yine de bunun için diagnostics kaydediyordu: `UnhandledException`'ı loglamak, bir `HandledException` event'i yazmak ve `http.server.request.duration` metriğini `error.type` ile etiketlemek.

.NET 10'dan itibaren bu, varsayılan olarak artık gerçekleşmiyor. Handler'ınız exception'ı ele alındı olarak raporluyorsa, gerçekten ele alınmış sayılır — kodunuzun zaten hallettiği hatalar için loglarınızda/metriklerinizde artık gürültü olmuyor. Bu bilinçli bir düzeltmeydi: pek çok kişi "ele alınmış" exception'larının telemetride hâlâ neden göründüğünü anlamakta zorlanıyordu.

Eski davranışı gerçekten geri istiyorsanız — örneğin catch-all bir handler içinde loglama yapıyorsunuz ve yine de middleware'in kendi diagnostics'ini de istiyorsanız — açık bir opt-out mevcut:

```csharp
app.UseExceptionHandler(new ExceptionHandlerOptions
{
    SuppressDiagnosticsCallback = context => false
});
```

Callback'ten `false` döndürmek .NET 10 öncesi davranışı geri getirir (diagnostics kaydedilir); `true` döndürmek (yeni varsayılan) onları bastırır.

## Modern Bir Yol Arkadaşı: ProblemDetails

Yukarıdaki iki yaklaşımın hiçbirinin bahsetmediği bir şey: .NET 8 itibarıyla ASP.NET Core, API hata yanıtları için standart bir JSON şekli (`type`, `title`, `status`, `detail`, `instance`) sunan [RFC 9457 Problem Details](https://www.rfc-editor.org/rfc/rfc9457)'i birinci sınıf destekliyor. Bağlamak tek satır:

```csharp
builder.Services.AddProblemDetails();
```

`UseExceptionHandler()` ile birlikte (varsayılan durum için özel bir handler'a bile gerek yok), ele alınmamış exception'lar artık aksi halde elle uyduracağınız rastgele bir şekil yerine tutarlı, makine tarafından okunabilir bir `application/problem+json` yanıtı olarak dönüyor — önceki yazıda ele alınan [özel exception filter](/posts/dotnet8-custom-exceptions/) ile aynı fikir, sadece action başına değil tüm uygulama genelinde standartlaştırılmış hali.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
*Thanks For Reading*
