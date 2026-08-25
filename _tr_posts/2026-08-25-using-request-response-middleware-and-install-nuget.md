---
title: "RequestResponse Middleware Nedir? Nasıl Kurulur?"
description: "ASP.NET Core API'lerinde HTTP istek/yanıtlarını loglamak ve incelemek için RequestResponse Middleware NuGet paketini kurma ve yapılandırma."
date: 2026-08-25 02:10 +0300
translation_key: using-request-response-middleware-and-install-nuget
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-8, middleware, nuget]
image:
  path: /assets/img/posts/using-request-response-middleware-and-install-nuget/cover.webp
  alt: "Kapak görseli: RequestResponse Middleware Nedir? Nasıl Kurulur?"
  lqip: "data:image/webp;base64,UklGRl4AAABXRUJQVlA4IFIAAACwAwCdASoYAA0APu1kqU2ppaQiMAgBMB2JZQAAWpgEvVT/K3s8AAD+7BGIJG1RyT2etIKAMG02B2l4E2oWEgvQsoTAZzM7Hv/ImCqD7cf3qSYA"
---

## RequestResponse Middleware Kullanımı ve Test Yöntemleri

Merhaba, bu blog yazısında yeni yayınladığımız RequestResponse Middleware paketini nasıl kullanacağınızı, sunduğu özellikleri ve Web API projelerinizde nasıl test edebileceğinizi adım adım anlatacağız. Bu yazı özellikle ASP.NET Core geliştiricileri için faydalı olacak ve middleware'inizi etkili şekilde nasıl kullanacağınızı gösterecek. Okuma süresi: 3-5 dakika.

## RequestResponse Middleware Nedir?

RequestResponse Middleware, ASP.NET Core uygulamalarında HTTP istek ve yanıtlarının detaylı loglanmasını sağlayan bir kütüphanedir. Geliştiricilere uygulamalarının performansını izlemek, sorunları hata ayıklamak (debug) ve sistem olaylarını daha verimli analiz etmek için güçlü bir araç sunar. Bu middleware, HTTP istek ve yanıtları hakkında detaylı bilgi toplar ve bunları loglamak ya da özel bir handler ile ele almak üzere yapılandırılabilir — [global hata yönetimine](/posts/dotnet8-global-error-handling/) benzer bir fikir, sadece exception yerine loglama için: her endpoint'i tek tek enstrümante etmek yerine her isteği gören tek bir yer.

![Desktop View](/assets/img/posts/request-with-middleware.webp)
_Road-Map_

## Başlarken

### Kurulum

Middleware'i projenize eklemek oldukça basit. Öncelikle NuGet üzerinden paketi projenize ekleyin. Bunu .NET CLI ile yapabilirsiniz:

```bash
dotnet add package CD.RequestResponse.Middleware
```

Ya da NuGet paket yöneticisini kullanarak da ekleyebilirsiniz.

Ayrıca paketimi nuget.org'da da ziyaret edebilirsiniz:
[Nuget Package](https://www.nuget.org/packages/CD.RequestResponse.Middleware)

### Kullanım

Bu middleware'i Web API projenize entegre etmek için **Program.cs** dosyanıza şu satırları eklemeniz yeterli:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Container'a servisleri ekle
builder.Services.AddHttpClient();

var app = builder.Build();

// RequestResponse Middleware'i kullan
app.AddRequestResponseMiddleware(opts =>
{ 
    opts.UseHandler(async context =>
    {
        // İhtiyacınız olanı kullanabilirsiniz
        Console.WriteLine("--Handler--\n");
        Console.WriteLine($"Request: {context.Request}");
        Console.WriteLine($"Response: {context.Response}");
        Console.WriteLine($"Timer: {context.FormatedRequestTime}");
        Console.WriteLine($"Url: {context.Url}");
        Console.WriteLine($"Status Code: {context.StatusCode}");
        Console.WriteLine($"Method: {context.Method}");
        Console.WriteLine($"HTTP Version: {context.HttpVersion}");
        Console.WriteLine($"Client IP Address: {context.ClientIPAddress}");
        Console.WriteLine($"External IP Address: {context.ExternalIPAddress}");
        Console.WriteLine($"User Agent: {context.UserAgent}");
        Console.WriteLine($"Cookies: {context.Cookies}");

        await Task.CompletedTask;
    });

    
    opts.UseLogger(app.Services.GetRequiredService<ILoggerFactory>(), opts =>
    {
        // Log seviyesi tipini seç
        opts.LogLevel = LogLevel.Error;
        opts.LoggerCategoryName = "RRM-Api-Test";

        // İhtiyacınız olanı kullanabilirsiniz
        opts.LoggingFields = 
                         RRM_Library.Models.LoggingOptions.LogFields.Request |
                         RRM_Library.Models.LoggingOptions.LogFields.Response |
                         RRM_Library.Models.LoggingOptions.LogFields.ResponseTime |
                         RRM_Library.Models.LoggingOptions.LogFields.StatusCode |
                         RRM_Library.Models.LoggingOptions.LogFields.HostName |
                         RRM_Library.Models.LoggingOptions.LogFields.Path |
                         RRM_Library.Models.LoggingOptions.LogFields.QueryString 
                         ;
    });
});

app.MapGet("/GetUserInfo/{id}", (int id, ILogger<Program> logger) =>
{
        var response = new UserLoginResponseModel
        {
            Success = true,
            UserEmail = "alparslan@gmail.com"
        };
        logger.LogInformation("User info is requested");
        return Results.Ok(response);
})
.WithName("GetUserInfo")
.WithOpenApi();

app.Run();

internal class UserLoginRequestModel
{
    public string Username { get; set; }
    public string Password { get; set; }
}

internal class UserLoginResponseModel
{
    public bool Success { get; set; }
    public string UserEmail { get; set; }
}
```

Bu yapılandırmayla her HTTP istek ve yanıtı loglanır, loglar da belirttiğiniz log seviyesine ve kategoriye göre yönetilir.

## Detaylı Özellik Kullanımı

### Loglama Özellikleri

**RequestResponse Middleware**, HTTP istek ve yanıtlarının loglanmasını son derece özelleştirilebilir hale getirir. Örneğin **LoggingFields** ile hangi alanları loglamak istediğinizi belirtebilirsiniz:

* Request: İstek gövdesi ve header'ları.

* Response: Yanıt içeriği ve header'ları.

* StatusCode: Yanıt durum kodu (ör. 200, 404).

* ResponseTime: İstek ve yanıt arasındaki süre.

Bu alanlar, performans sorunlarını analiz etmek ve uygulamanız hakkında daha derin içgörüler edinmek için oldukça faydalıdır.

Ne loglamak istediğinizi belirtmenin yanı sıra, **UseLogger** metoduyla loglama davranışını da yapılandırabilirsiniz:

```csharp
opts.UseLogger(app.Services.GetRequiredService<ILoggerFactory>(), opts =>
{
    opts.LogLevel = LogLevel.Error;
    opts.LoggerCategoryName = "RRM-Api-Test";

    opts.LoggingFields = 
                     RRM_Library.Models.LoggingOptions.LogFields.Request |
                     RRM_Library.Models.LoggingOptions.LogFields.Response |
                     RRM_Library.Models.LoggingOptions.LogFields.ResponseTime |
                     RRM_Library.Models.LoggingOptions.LogFields.StatusCode |
                     RRM_Library.Models.LoggingOptions.LogFields.HostName |
                     RRM_Library.Models.LoggingOptions.LogFields.Path |
                     RRM_Library.Models.LoggingOptions.LogFields.QueryString;
});
```

**UseLogger** ile şunları yapabilirsiniz:

* Log Seviyesini Ayarlayın: Logların önem derecesini belirlemek için **LogLevel**'i kullanın (ör. Error, Information, Debug). Bu, logları önemlerine göre filtrelemenizi sağlar.

* Logger Kategorisi Belirleyin: **LoggerCategoryName**, loglarınız için bir kategori tanımlamanıza olanak tanır; karmaşık bir uygulamada logları ayırt etmeyi ve filtrelemeyi kolaylaştırır.

* Loglama Alanlarını Özelleştirin: **LoggingFields** özelliği, istek ve yanıtın tam olarak hangi kısımlarını loglamak istediğinizi tanımlamanızı sağlar. İstek gövdesi, yanıt gövdesi, header'lar, durum kodu gibi alanların herhangi bir kombinasyonunu seçebilirsiniz.

Bu sayede konsol loglama, hata ayıklama araçları ya da Serilog veya NLog gibi üçüncü taraf loglama servisleri gibi mevcut loglama altyapınızı, istek ve yanıt detaylarını yakalamak için kolayca kullanabilirsiniz.

Örneğin, loglama yapılandırmanızı şu şekilde kurduysanız:

```csharp
services.AddLogging(configure => 
{
    configure.AddConsole();
    configure.AddDebug();
    configure.AddEventLog();
});
```

**UseLogger**'ı bu loglama yapılandırmasıyla kullanabilirsiniz, tüm istek-yanıt logları yapılandırdığınız log sağlayıcılarına yönlendirilir. Bu, middleware'i konsol tabanlı ya da daha gelişmiş loglama servisleri fark etmeksizin mevcut loglama araçlarınızla kolayca entegre etmenizi sağlar.

### Handler Kullanımı

Loglamaya ek olarak, **UseHandler** metoduyla özel işlemler gerçekleştirecek bir handler fonksiyonu da tanımlayabilirsiniz:

```csharp
options.UseHandler(async context =>
{
    Console.WriteLine("--Request and Response Details--\n");
    Console.WriteLine($"Request URL: {context.Url}");
    Console.WriteLine($"Status Code: {context.StatusCode}");
    Console.WriteLine($"Response Time: {context.FormatedRequestTime}");
    Console.WriteLine($"Request Method: {context.Method}");
    Console.WriteLine($"HTTP Version: {context.HttpVersion}");
    Console.WriteLine($"Client IP Address: {context.ClientIPAddress}");
    Console.WriteLine($"External IP Address: {context.ExternalIPAddress}");
    Console.WriteLine($"User Agent: {context.UserAgent}");
    Console.WriteLine($"Cookies: {context.Cookies}");
    await Task.CompletedTask;
});
```

Bu handler her HTTP istek ve yanıtından sonra çağrılır, loglamanın ötesinde kendi mantığınızı uygulamanıza olanak tanır. Örneğin, belirli koşullar altında özel bir aksiyon almak isterseniz bu fonksiyonu kullanabilirsiniz. Ayrıca bu handler ile istek ve yanıt hakkında birçok detaya erişebilirsiniz:

* Request Method: İstek metodu (GET, POST vb.).

* HTTP Version: HTTP protokol sürümü.

* Client IP Address: İsteği yapan istemcinin IP adresi.

* External IP Address: Harici IP adresi (ör. bir proxy arkasında).

* User Agent: İsteği yapan istemcinin tarayıcı bilgisi.

* Cookies: İstekle birlikte gönderilen çerezler.

Bu detaylar, istekleri daha kapsamlı analiz etmenize ve gerekirse özel iş mantığı oluşturmanıza olanak tanır.

## API Testi

Bu middleware'i API'nizde kullanırken loglama ya da handler işlevselliğinin doğru çalıştığından emin olmak isteyebilirsiniz. Bu testleri gerçekleştirmek için birkaç adım:

1. Unit Testler: **Program.cs** dosyanızdaki middleware yapılandırmasını bir unit test içinde test ederek logların doğru şekilde oluşturulduğundan emin olun.

2. Postman veya Insomnia ile Test: Farklı istekler (GET, POST, PUT) yapın ve yanıt sürelerinin ve log çıktılarının beklendiği gibi olduğunu doğrulayın.

3. Sahte Log Sağlayıcıları: Logların middleware üzerinden doğru şekilde geçtiğini ve beklenen sonuçları verdiğini doğrulamak için **ILoggerFactory**'e sahte log sağlayıcıları eklemek üzere kullanın.

## Özet ve Sonuç

RequestResponse Middleware, ASP.NET Core projelerinizde HTTP istek ve yanıtlarını yönetmeyi kolaylaştırarak geliştirme ve hata ayıklama sürecini akıcı hale getirir. Bu paketi projelerinizde kullanarak loglama işlemlerini standartlaştırabilir ve daha verimli bir izleme yapısı kurabilirsiniz. Bu logların sadece yapılandırdığınız log sağlayıcılarına akmasını değil de diske de yazılmasını istiyorsanız, bunun için ayrı bir paket de var — bkz. [File Logger Middleware](/posts/using-file-logger-middleware-and-install-nuget/).

Bu paket hakkında sorularınız veya önerileriniz varsa, yorum bırakmaktan ya da GitHub sayfamız üzerinden bize ulaşmaktan çekinmeyin.

[Github Repository](https://github.com/alparslanakbas/request-response-nuget-package)

NuGet üzerinde bir 2.0 önizlemesi de geliştirme aşamasında, sırada ne olduğunu görmek isterseniz.

Bu middleware'i projelerinizi geliştirmek için nasıl kullandığınızı görmeyi sabırsızlıkla bekliyoruz. 😊

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
