---
title: "Redis Nedir ve Kullanım Alanları?"
description: "Redis'e giriş: bu in-memory NoSQL deposunu hızlı yapan şey, veriyi nasıl kalıcı hale getirdiği ve caching, queue gibi yaygın kullanım alanları."
date: 2026-08-25 02:45 +0300
translation_key: what-is-redis
categories: [Data, Redis]
tags: [redis, nosql, caching, use-cases]
image:
  path: /assets/img/posts/what-is-redis/cover.webp
  alt: "Kapak görseli: Redis Nedir ve Kullanım Alanları?"
  lqip: "data:image/webp;base64,UklGRloAAABXRUJQVlA4IE4AAACwAwCdASoYAA0APu1iqU2ppaQiMAgBMB2JZQAAWqFFJ/HP/q6kAAD+7BGIJG1RyaPBMZAXvVubRiNN6yMZiS9ZLkjRat90grv/H96kmAA="
---

## Redis Nedir?

Bir olguyu anlamak, o olguyu temsil eden kavramın etimolojisini bilmek demektir. Elbette yazılım dünyasının etimolojisi, 3 günlük bir teknolojinin ömrüne denk düşer, ve endüstrinin terminolojik kelimeleri kendi aralarında ilişkisel bağlantılar kurmak için yeterli zamana sahip olmadığından, kelime hazinesi açısından zengin bir kök beklemek gerçekçi değildir.

REmote DIctionary Server'ın kısaltması olan Redis, veriyi bellekte saklayarak mümkün olan en hızlı veri erişim yöntemini benimseyen açık kaynaklı bir veritabanı ve NoSQL çözümüdür. (Redis için "açık kaynak"ın bugün tam olarak ne anlama geldiği hakkında daha fazlası — bu, birden fazla kez değişti — aşağıdaki [Lisanslama](#lisanslama) bölümüne bak.)

Redis, bir NoSQL veritabanı olmasının yanı sıra, saklanacak veri tipine göre uyarlanmış temel veri yapıları da içerir. Bu özellik, Redis'i diğer veritabanlarına kıyasla önemli ölçüde güçlendirir. Redis'i tercih edilir kılan bir başka özellik de hızıdır — tüm ilişkisel veritabanlarının önüne geçer.

Redis **distributed** bir sistem olduğundan ve her uygulama için ayrı ayrı **in-memory** caching yapmak yerine tüm instance'ların cache'lerini tek bir uzak bellekte tuttuğundan, net bir veri tutarlılığına sahip bir sistem sağlar — daha önceki bir yazıda ele aldığımız [distributed caching](/posts/what-is-distributed-cache/) kavramının somut, gerçek dünya örneğidir.

Redis'in bellek tabanlı bir veritabanı olmasının bir başka avantajı da okuma ve yazma işlemlerini milisaniyeler içinde yapabilmesidir. Bu nedenle Twitter, GitHub, Tumblr, Pinterest, Instagram, Hulu, Flickr ve The New York Times gibi büyük markalar bu sunucuyu kullanır.

Redis öncelikle bir caching sunucusu olarak kullanılsa da, başka birçok senaryo için de kullanılabilir. Kullanıcıların oturum bilgilerini saklayabildiğinden bir Session Store görevi görür. Pub/Sub paradigmasını desteklediğinden Publish–Subscribe deseninin uygulanmasını sağlar. Ayrıca bir uygulamada sırayla işlenmesi gereken mesajları ölçeklenebilir şekilde işleyebildiğinden Queue'lar için uygundur. Son olarak, sayaç olarak işlev görebilme özelliği sayesinde Counter senaryolarında da kullanılabilir.

## Lisanslama

Yeni bir proje için Redis seçiyorsan bilmekte fayda var: lisanslama son zamanlarda gerçekten iki kez değişti, ve gerçekte ne yapmana izin verildiği açısından önemli.

* **Mart 2024'e kadar**, Redis standart, izin verici bir açık kaynak lisansı (BSD) altında yayınlanıyordu.
* **Mart 2024'te**, Redis, bulut sağlayıcıların katkıda bulunmadan Redis'i yeniden satmasını durdurmayı hedefleyen "source-available" bir lisans olan SSPL'e geçti. SSPL, OSI onaylı bir açık kaynak lisansı değil, ve bu değişiklik o kadar tartışmalıydı ki, birkaç büyük bulut sağlayıcının artık onun yerine kullandığı Linux Foundation destekli bir fork olan [Valkey](https://valkey.io/)'nin doğmasına yol açtı.
* **Redis 8 ile (2025)**, Redis, SSPL ve RSALv2'nin yanına OSI onaylı bir açık kaynak lisansı olan AGPLv3'ü de bir seçenek olarak geri ekledi. Redis 8 ayrıca daha önce ücretli katmanda olan Redis Stack özelliklerini (JSON, Time Series, olasılıksal veri tipleri, Query Engine) AGPL altında çekirdeğe dahil etti.

Pratik sonuç: açık kaynak Redis'i yerelde, Docker'da ya da kişisel/dahili bir proje için kendi barındırdığın bir ortamda çalıştırıyorsan (tam olarak bu serinin ele aldığı şey), bunların hiçbiri günlük kullanımında bir şey değiştirmez. Redis'i yönetilen bir servis olarak yeniden satan bir bulut sağlayıcıysan, ya da bir production deployment'ı için Redis ile Valkey arasında karar veren bir şirketsen daha çok önem taşır.

## Veri Kalıcılığı

Redis veriyi bellekte saklayan bir sistem olsa da, kalıcı veriyi de destekler. RAM'de kalıcı veriden bahsetmek tam olarak mümkün olmadığından, Redis sistemleri çeşitli yöntemlerle veriyi sabit disklere kaydedebilir. Bunun için iki yaklaşım benimsenir: **Snapshotting** ve **Slave**.

* **Snapshotting**, verinin anlık görüntülerini belirli zaman aralıklarında diske kaydetmeyi içerir.
* **Slave** yönteminde, veri slave'lerde saklanır, master'lardaki yükü azaltır ve kalıcılığı sağlar.

## Pipelining

Redis'in pipelining özelliği sayesinde, istenen tüm veri tek bir batch'te getirilir, bu da performansı ve hızı önemli ölçüde artırır.
Özetle:

### Avantajlar

* Geleneksel veritabanlarındaki CPU kullanımını belleğe kaydırarak CPU maliyetlerini azaltır.
* Bellekte saklanan veri çok hızlı işlendiğinden, performans artışı sağlar.
* Redis 8 itibarıyla tekrar açık kaynak (bkz. [Lisanslama](#lisanslama)).
* Bugün birçok programlama dili tarafından destekleniyor.
* Dokümantasyonu zengin.
* Temel veri tiplerini destekliyor.
* Senkron çalışıyor, bu da onu son derece hızlı yapıyor.
* Veriyi sadece bellekte değil, sabit disklere de kaydedebiliyor.

### Dezavantajlar

* Saklanabilecek veri, RAM kapasitesiyle sınırlıdır.
* İlişkisel veritabanı sistemlerindeki gibi karmaşık, rapor benzeri sorguları desteklemez.
* Transaction'lar olmadığından, işlem sırasında karşılaşılan hatalar telafi edilemez.

## Kullanım Alanları

* Caching
* Session Storage
* Queue'lar
* Pub/Sub
* Counter

Sırada: [Redis'i Docker ile yerelde kurmak](/posts/run-redis-with-docker/), sonra [Redis'in temel veri tiplerine](/posts/redis-data-types/) daha yakından bir bakış — string'ler, list'ler, set'ler, sorted set'ler ve hash'ler — her biri için gerçek komut örnekleriyle.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Okuduğunuz için teşekkürler_
