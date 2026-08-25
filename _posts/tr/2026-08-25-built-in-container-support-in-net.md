---
title: ".NET'te Yerleşik Container Desteği: Dockerfile'a Gerek Yok"
description: "dotnet publish ile bir .NET uygulamasını Dockerfile yazmadan/yönetmeden doğrudan SDK üzerinden container'a nasıl dönüştürürsünüz."
date: 2026-08-25 02:45 +0300
translation_key: built-in-container-support-in-net
categories: [DevOps, Docker]
tags: [dotnet-7, docker, containers, aspnet-core]
image:
  path: /assets/img/posts/built-in-container-support-in-net/cover.webp
  alt: "Kapak görseli: .NET'te Yerleşik Container Desteği"
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAACQAwCdASoYAA0APu1iqU2ppaQiMAgBMB2JZQAAWph700DxGeJgAP7sEYgkbVHHOD0zK2ThNQwmJEPCoQC0LL7Eab25IqiUqpFJK3okFcychmsL/x/epJgA"
---

## Giriş

Merhaba,

Bu yazıda .NET 7 ve sonraki sürümlerle birlikte tanıtılan, uygulamaları Dockerfile'a ihtiyaç duymadan container'a dönüştürmeyi sağlayan özelliği inceleyeceğiz. Aynı zamanda .NET'teki yerleşik container desteğini ele alacağız.

Evet, Microsoft, .NET 7 SDK'sından itibaren, uygulamaları container'a dönüştürmede Dockerfile'a olan bağımlılığı ortadan kaldıran tamamen yeni bir yaklaşım sundu. Bu, ek bir dosyayı sürdürme ihtiyacını ortadan kaldırarak DevOps sürecini kolaylaştırıyor ve iş yükünü basitleştiriyor. Sonuç olarak, uygulamaların container'a dönüştürülme süreci daha kolay ve doğrudan hale geldi.

Bu yaklaşımın arkasındaki temel fikir, birçok yazılım uygulamasında geliştiricilerin container'a dönüştürmeyi mümkün kılmak için uzun Dockerfile yapılandırmalarıyla uğraşmaya önemli zaman ve efor harcaması gerçeğinden geliyor. Ancak .NET 7'den itibaren, yerleşik yeteneklerden faydalanarak Docker image'larını doğrudan .NET CLI aracıyla oluşturup dağıtabilmek sayesinde bu efor azaltıldı. Bu, süreci daha verimli ve yönetilebilir hale getiriyor.

Şimdi, bir .NET uygulamasının bir Dockerfile kullanılarak nasıl container'a dönüştürüldüğünü tekrar gözden geçirip, paralel olarak bunun Dockerfile olmadan nasıl yapılabileceğini göstereceğiz. İki yöntemi karşılaştırmalı olarak değerlendireceğiz. Daha önce Docker kullandıysanız — örneğin [bir Redis sunucusunu container içinde çalıştırmak](/posts/run-redis-with-docker/) gibi — aşağıdaki komutlar size tanıdık gelecek. Hadi başlayalım!

## Başlayalım

Öncelikle şu endpoint'e sahip bir ASP.NET Core WEB API uygulaması geliştirelim:

```csharp
var builder = WebApplication.CreateBuilder(args);
 
var app = builder.Build();
 
app.MapGet("/", () => "Hello World!");
 
app.Run();
```

Sonra, bu uygulamayı dockerize etmek için şu içeriğe sahip bir Dockerfile oluşturalım:

```yml
FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /publish
 
FROM mcr.microsoft.com/dotnet/aspnet:8.0 as runtime
WORKDIR /publish
COPY --from=build /publish .
ENV ASPNETCORE_URLS=http://+:5000
EXPOSE 5000
ENTRYPOINT ["dotnet", "Docker.Example.dll"]
```

Dockerfile hazır olduğuna göre, şu komutla bir image oluşturalım:

```bash
docker build -t docker-example .
```

Bu işlemi tamamladıktan sonra, oluşturulan image'dan şu komutla bir container oluşturabiliriz:

```bash
docker run -p 5000:5000 --name docker-example-container docker-example
```

Ve şu çıktıyı göreceksiniz:

```bash
Hello World!
```

"Bunda tam olarak zor ya da karmaşık olan ne?" diye merak ediyor olabilirsiniz. Ve evet, yukarıda görüldüğü gibi burada özellikle zorlayıcı bir şey yok. En basit haliyle, bir .NET uygulamasını dockerize ederken izlediğimiz yaklaşım bu. Ancak uygulamanın gereksinimleri ve proje karmaşıklığı arttıkça, Dockerfile'ın içeriği kaçınılmaz olarak büyüyecektir. Sonuç olarak, bu dosyayı sürdürmek ek bir yük haline gelir.

Bu tür senaryoları ele almak için Microsoft, .NET'te yerleşik container desteğini tanıttı; bu sayede geliştiriciler bir Dockerfile'a bağımlı kalmadan uygulamaları dockerize edebiliyor.

Bu destekle, tek bir komutla bir Docker image'ı oluşturup ondan bir container başlatabiliriz:

```bash
dotnet publish --os linux --arch x64 /t:PublishContainer
```

> Bu komut eskiden `-p:PublishProfile=DefaultContainer -p:ContainerImageName=docker-example` şeklinde yazılıyordu. Bu hâlâ çalışıyor ama bu eski, .NET 7 dönemine ait bir biçim — güncel dokümanların kullandığı `/t:PublishContainer`, publish target'ını doğrudan hedefliyor; `ContainerImageName`'in kendisi de .NET 8'den itibaren `ContainerRepository` lehine deprecated (aynı fikir, yeni isim). Hiç isim belirtmezseniz, image adı varsayılan olarak projenizin `AssemblyName`'ine düşer.
{: .prompt-info }

Image adını ve birkaç başka seçeneği, her seferinde komut satırında geçmek yerine .csproj dosyanızda ayarlayabilirsiniz:

```csharp
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    .
    .
    .
    <ContainerRepository>docker-example-container</ContainerRepository>
    <ContainerImageTags>1.1.0;latest</ContainerImageTags>
  </PropertyGroup>
  <ItemGroup>
    .
    .
    .
  </ItemGroup>
</Project>
```

Bunlar ayarlandığında, komut şuna küçülür:

```bash
dotnet publish --os linux --arch x64 /t:PublishContainer
```

Bir `RuntimeIdentifier` eklerseniz, komut satırında `--os`/`--arch` geçmenize bile gerek kalmaz:

```csharp
<ContainerRepository>docker-example-container</ContainerRepository>
<ContainerImageTags>1.1.0;latest</ContainerImageTags>
<RuntimeIdentifier>linux-x64</RuntimeIdentifier>
```

```bash
dotnet publish /t:PublishContainer
```

Bu işlemin sonucunda, Docker'daki image'larınızı kontrol ederseniz, belirttiğiniz isimle bir image'ın oluşturulduğunu göreceksiniz.

![Desktop View](/assets/img/posts/Built-In-Container-Support-in-NET-Dockerizing-NET-Applications-Without-a-Dockerfile-1.webp)
_NET-Dockerizing-NET-Applications-Without-a-Dockerfile_

Bu seçeneklerin ötesinde, oluşturulacak image'ı aşağıda açıklanan özelliklerle de özelleştirebilirsiniz:

* **ContainerBaseImage**: Bu özellik, .NET uygulamalarını build etmek için kullanılan taban image'ı kontrol etmenizi sağlar. Varsayılan olarak SDK, **mcr.microsoft.com/dotnet/aspnet** image'ını kullanır.
* **ContainerRepository**: Bu özellik, image'ın adını değiştirmenizi sağlar (`ContainerImageName`'in modern karşılığı).
* **ContainerPort**: Bu özellik, container'ın portunu belirtmenizi sağlar.
Ayrıca aşağıda gösterildiği gibi **ContainerEnvironmentVariable** özelliğiyle ortam değişkenleri de tanımlayabilirsiniz.

```csharp
<Project Sdk="Microsoft.NET.Sdk.Web">
  .
  .
  .
  <ItemGroup>
    <ContainerEnvironmentVariable Include="Example_Environment_Variable" Value="Trace" />
  </ItemGroup>
</Project>
```

## .NET 7'den Bu Yana Değişenler

Yukarıdaki temel iş akışı .NET 7'nin onu tanıttığı günden bu yana değişmedi, ama birkaç detay değişti:

* **ASP.NET Core ve Worker SDK projeleri (burada kullanılan gibi) bunu zaten kutudan çıktığı gibi destekliyor.** Console uygulamaları farklı bir konumdaydı — açık bir `<EnableSdkContainerSupport>true</EnableSdkContainerSupport>` opt-in'i gerektiriyorlardı. .NET 10 bu farkı ortadan kaldırdı: console uygulamaları artık aynı sıfır-yapılandırma deneyimine sahip.
* **Çok mimarili image'lar** (ör. hem `linux-x64` hem `linux-arm64` üzerinde çalışan tek bir image oluşturmak), karma mimarili bir altyapıya deploy ediyorsanız SDK 8.0.405+ ve 9.0.102+'dan itibaren destekleniyor.

Image oluşturulduktan sonra, herhangi bir yere push etmeden önce yerelde çalıştırıp sağlamasını yapmak diğer image'lardan farksız:

```bash
docker run -p 5000:5000 --rm docker-example-container
curl http://localhost:5000/
```

## Sonuç

.NET mimarisi, standart Dockerfile yaklaşımlarına ihtiyaç duymadan uygulamalarımız için çok daha basit ve esnek bir şekilde Docker image'ları oluşturmamızı sağlamaya odağını kaydırdı. Bu yaklaşım yalnızca geliştirme sürecimizi hızlandırmakla kalmıyor, bence container'a dönüştürmeyi basitleştirmede de önemli bir fark yaratıyor. Önceki bir yazıda ele alınan [rate limiting middleware](/tr/posts/dotnet7-how-to-use-rate-limitter/) ile de iyi eşleşiyor — ikisi de eskiden üçüncü taraf araçlar gerektiren, artık doğrudan SDK içinde gelen production kaygılarına örnek.

Sonraki yazılarımda görüşmek üzere, iyi kodlamalar..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
