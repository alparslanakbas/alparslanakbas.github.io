---
title: "Docker Container ile Redis Sunucusu Başlatmak"
description: "Windows'ta Docker container'ında yerel bir Redis sunucusu çalıştırmaya hızlı bir rehber, temel redis-cli SET ve GET komutlarıyla test etmek dahil."
date: 2026-08-25 00:15 +0300
translation_key: run-redis-with-docker
categories: [Data, Redis]
tags: [redis, docker, nosql]
image:
  path: /assets/img/posts/run-redis-with-docker/cover.webp
  alt: "Kapak görseli: Docker Container ile Redis Sunucusu Başlatmak"
  lqip: "data:image/webp;base64,UklGRmAAAABXRUJQVlA4IFQAAABwAwCdASoYAA0APu1kqk4ppaQiMAgBMB2JZQAAWpcmygAWhQAA/uwRiCRtUcoTIuljA2FJG93CXXcZUqYjTe4OA7nWKCO/W+qs6UhvBI6lB+g5MAA="
---

## Neden Docker Container?

Windows ortamında Redis'i Chocolatey ile kurarken, en son sürümü almakla ilgili sık sık sorunlarla karşılaşırız. Ama Linux ortamında çalışan Docker container'ları, en güncel Redis sistemleriyle çalışma avantajı sunar. Ayrıca Docker, Windows işletim sisteminde bir Redis sunucusu kurmak için gereken uğraşı ve alan tahsisini ortadan kaldırır. Bunun yerine, tek bir imaj kullanarak zahmetsizce bir Redis sunucusu başlatmamızı sağlar.

## Bir Container Başlatmak

Bir container içinde Redis sunucusu çalıştırmak için **[Redis](https://hub.docker.com/_/redis)**'te mevcut olan imajı kullanacağız.

PowerShell'de şu komutu çalıştır:

```bash
docker run --rm -p 6379:6379 --name rediscontainer -d redis
```

Redis imajı Docker platformunda mevcut değilse, otomatik olarak Docker Hub Registry'den çekilecektir. Container içinde 6379 portunda çalışacak Redis, `-p 6379:6379` port eşlemesi sayesinde dışarıdan da 6379 portu üzerinden erişilebilir olacak.

Şimdi, aşağıdaki komutla Redis'i çalıştıralım:

```bash
docker exec -it rediscontainer redis-cli
```

![Desktop View](/assets/img/posts/redis-1.webp)
_Redis Çalışıyor_

Görselde görebileceğin gibi, Redis artık çalışıyor. İçine bir mesaj kaydedelim:

```bash
set test "Redis now working"
```

"OK" yanıtını aldıktan sonra, mesajı geri alalım:

```bash
get test
```

![Desktop View](/assets/img/posts/redis-get-message.webp)
_Redis Çalışıyor_

Bu kadar. Gördüğün gibi, Redis çalışıyor. Umarım faydalı olmuştur.

[Valkey](https://valkey.io/)'yi — önceki yazının [lisanslama bölümünde](/posts/what-is-redis/#licensing) bahsedilen açık kaynak fork'u — çalıştırmayı tercih edersen, süreç birebir aynı, sadece imajı değiştir: `docker run --rm -p 6379:6379 --name valkeycontainer -d valkey/valkey`. Aşağıdaki `redis-cli` komutları her iki durumda da birebir aynı çalışır, çünkü Valkey, Redis ile protokol uyumludur.

Artık çalışan bir sunucun olduğuna göre, [sıradaki yazı](/posts/redis-data-types/) içinde saklayabileceğin gerçek veri tiplerini ele alıyor — string'ler, list'ler, set'ler, sorted set'ler ve hash'ler.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Okuduğunuz için teşekkürler_
