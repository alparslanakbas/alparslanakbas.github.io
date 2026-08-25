---
title: "Projeler"
icon: fas fa-diagram-project
order: 4
lang: tr-TR
translation_key: projects
permalink: /tr/projeler/
description: >-
  Alparslan Akbaş'ın inşa ettiği birkaç şey — canlı bir production uygulaması,
  yayınlanmış NuGet paketleri ve .NET'te açık kaynak denemeler.
---

Kısa bir seçki — her şey değil, sadece zamanınıza değecek olanlar. Gerisi [GitHub](https://github.com/alparslanakbas?tab=repositories)'da.

## ProteinAvcısı

Türkiye'deki spor takviyesi markaları için canlı bir fiyat takip sitesi. .NET ve Angular ile geliştirildi, birden fazla satıcıdaki fiyatları çekiyor, markaların kendi beyan ettiği "eski/yeni fiyat" iddiasına güvenmek yerine gerçek bir fiyat geçmişi tutuyor ve gerçek indirimleri ortaya çıkarıyor. Deploy edildi ve çalışıyor.

[proteinavcisi.com.tr](https://www.proteinavcisi.com.tr) · [Kaynak Kod](https://github.com/alparslanakbas/protein-avcisi)

## ASP.NET Core İçin Middleware Paketleri

Müşteri projelerinde tekrar tekrar yazdığım desenlerden doğan iki küçük NuGet paketi. **CD.RequestResponse.Middleware**, yapılandırılabilir alanlar ve log seviyeleriyle HTTP istek ve yanıtlarını loglar; **CD.File-Logger.Middleware** bunu genişletip logları diske kalıcı olarak kaydeder.

[CD.RequestResponse.Middleware](https://www.nuget.org/packages/CD.RequestResponse.Middleware) · [CD.File-Logger.Middleware](https://www.nuget.org/packages/CD.File-Logger.Middleware) · [Kaynak Kod](https://github.com/alparslanakbas/request-response-nuget-package)

## CD.GenericRepository

.NET için Entity Framework Core ile hafif bir generic repository pattern implementasyonu — proje başına tekrar tekrar yazmaktan yorulduğum CRUD ve sorgu boilerplate'i.

[Kaynak Kod](https://github.com/alparslanakbas/CD.GenericRepository)

## ReqMint

.NET'te sıfırdan geliştirilen bir HTTP istemcisi — şişkin bir arayüze özellik eklemek yerine hızlı ve sade olacak şekilde tasarlanıyor. Aktif olarak geliştiriliyor.

[Kaynak Kod](https://github.com/alparslanakbas/ReqMint)

## Çok Kiracılı Sosyal Medya Platformu

Multi-tenancy'yi gerçek anlamda keşfetmek için .NET Core ile geliştirilen, Twitter'dan ilham alan bir sosyal platform — genellikle yapılan kestirmeler olmadan, paylaşılan altyapıda kiracı başına izole veri.

[Kaynak Kod](https://github.com/alparslanakbas/multi-tenancy-social-media)

## AutoCodeGenerationVSIX

Hızlı kod üretme kısayolları için bir Visual Studio uzantısı — bu listedeki tek tooling projesi, gerisi backend/web.

[Kaynak Kod](https://github.com/alparslanakbas/AutoCodeGenerationVSIX)
