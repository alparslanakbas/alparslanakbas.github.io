---
title: "File Logger Middleware Nedir? Nasıl Kurulur?"
description: "ASP.NET Core HTTP istek/yanıt loglarını diske kaydedip hata ayıklamayı kolaylaştıran File Logger Middleware NuGet paketine rehber."
date: 2026-08-25 02:20 +0300
translation_key: using-file-logger-middleware-and-install-nuget
categories: [.NET, ASP.NET Core]
tags: [aspnet-core, dotnet-8, middleware, logging, nuget]
image:
  path: /assets/img/posts/using-file-logger-middleware-and-install-nuget/cover.webp
  alt: "Kapak görseli: File Logger Middleware Nedir? Nasıl Kurulur?"
  lqip: "data:image/webp;base64,UklGRmgAAABXRUJQVlA4IFwAAABQAwCdASoYAA0APu1iqU2ppaOiMAgBMB2JZQAAg8SROalgAAD+715YGl0el1My8fl865Bzq/ayn+maTr3g0vrq0OSbY3CfYMrRhluaUE/Z7g8RTx26iP+kDsAAAA=="
---

## Giriş

Web geliştirmede loglama, API'lerin beklendiği gibi çalışmasını sağlamada kritik bir rol oynar. Loglar hata ayıklama sürecini kolaylaştırır ve sistemin işleyişi hakkında detaylı bilgi sunar. Bu yazıda, loglamayı daha kolay ve etkili hale getiren yeni yayınlanmış **CD.File-Logger.Middleware** paketini inceleyeceğiz. Bu kütüphane, HTTP istek ve yanıtlarını bir dosyaya kaydederek daha verimli bir şekilde loglamanıza yardımcı olur.

## File Logger Middleware Nedir ve Neden Kullanmalısınız?

**CD.File-Logger.Middleware**, ASP.NET Core uygulamaları için HTTP istek ve yanıt verilerinin bir dosyaya loglanmasını sağlayan bir uzantı paketidir. Bu kütüphane, özellikle yoğun işlemler sırasında detaylı takip gerektiren durumlarda faydalı olabilir.

* **Kalıcı Loglama**: Logları daha sonraki analizler için diske kaydedin.
* **Kolay Analiz**: Kaydedilen loglar üzerinden performans sorunlarını ve hataları kolayca tespit edin.
* **Hata Takibi**: Kaydedilen loglar, özellikle hata ayıklama sırasında hata analiz sürecini daha şeffaf hale getirir.

## Nasıl Kurulur?

Bu kütüphaneyi kullanmak için **CD.File-Logger.Middleware** paketini kurmanız gerekir.

```bash
dotnet add package CD.File-Logger.Middleware
```

### Kullanım

Paketler kurulduktan sonra middleware'i Program.cs dosyanızda yapılandırabilirsiniz. Aşağıda, dosya loglama middleware'inin, genişletmek üzere inşa edildiği paket olan [CD.RequestResponse.Middleware](/posts/using-request-response-middleware-and-install-nuget/) ile birlikte nasıl kullanılacağını gösteren bir örnek var — bu paket, o middleware'in zaten yakaladığı verinin üzerine dosyaya kalıcı yazma özelliği ekliyor.

```csharp
using Microsoft.Extensions.Logging;
using RRM_File_Logger.Library;
using RRM_Library;

var builder = WebApplication.CreateBuilder(args);

// Loglamayı ekle
builder.Services.AddLogging(opts =>
{
    opts.AddConsole();
});

// HttpClient'ı ekle
builder.Services.AddHttpClient();

var app = builder.Build();

// RequestResponse Middleware'i File Logger Middleware ile birlikte ekle
app.AddRequestResponseMiddleware(opts =>
{
    opts.UseHandler(async context =>
    {
        Console.WriteLine("--Handler--");
        Console.WriteLine($"Request: {context.Request}");
        Console.WriteLine($"Response: {context.Response}");
        await Task.CompletedTask;
    });
});

app.AddRequestResponseFileLoggerMiddleware(opts =>
{
    // İstediğiniz dosya yolunu belirtebilirsiniz.
    opts.FileDirectory = AppDomain.CurrentDomain.BaseDirectory;
    opts.FileName = "alparslan_log";
    opts.Extension = ".txt";
    opts.UseJsonFormat = true;
    opts.ForceCreateDirectory = true;
});
```

## Parametreler ve Yapılandırmalar

**AddRequestResponseFileLoggerMiddleware** extension metodu, file logger seçeneklerini şu şekilde yapılandırmanızı sağlar:

* **FileDirectory**: Log dosyalarının kaydedileceği dizini belirtin.
* **FileName**: Log dosyasının temel adını ayarlayın.
* **Extension**: Log dosyasının uzantısını ayarlayın (ör. .txt, .log, .json).
* **UseJsonFormat**: JSON format tipini seçebilirsiniz (ör. true veya false)
* **ForceCreateDirectory**: true olarak ayarlanırsa, dizin mevcut değilse middleware onu oluşturur.

## Örnek Loglama Çıktısı

Middleware entegre edildikten sonra, her istek ve yanıtı belirtilen dosya dizinine loglar. Aşağıda bir log dosyasının nasıl görünebileceğine dair bir örnek var:

```text
datetime: 18.11.2024 13:25:30 - [GET /api/test] [200 OK] [Request Time: 00:00:01.025]
Request: ...
Response: ...
```

## Sonuç

**CD.File-Logger.Middleware**, ASP.NET Core uygulamalarında HTTP istek ve yanıtlarını loglamak için kullanışlı bir kütüphanedir. Özellikle hata takibi ve performans izleme için faydalıdır — [hata yönetimini merkezileştirmenin](/posts/dotnet8-global-error-handling/) arkasındaki güdüyle aynı: loglama çağrılarını her endpoint'e dağıtmak yerine tek yerde toplamak. Bu kütüphaneyi uygulamanıza entegre ederek loglama altyapınızı güçlendirebilir, hata ayıklama süreçlerinizi daha akıcı hale getirebilirsiniz.

Bu paket hakkında sorularınız veya önerileriniz varsa, yorum bırakmaktan ya da GitHub sayfamız üzerinden bize ulaşmaktan çekinmeyin.

[Github Repository](https://github.com/alparslanakbas/request-response-nuget-package/tree/main/src/CD.File-Logger.Middleware)

Bu middleware'i projelerinizi geliştirmek için nasıl kullandığınızı görmeyi sabırsızlıkla bekliyoruz. 😊

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
