---
title: "Redis Databases (RedisInsight) Nedir? Nasıl Kullanılır?"
description: "Redis sunucusundaki key-value verilerine bağlanıp görselleştirmeyi sağlayan resmi grafik arayüzü RedisInsight'a (Redis Databases) kısa bir giriş."
date: 2026-08-25 02:35 +0300
translation_key: redis-databases
categories: [Data, Redis]
tags: [redis, redisinsight, nosql]
image:
  path: /assets/img/posts/redis-databases/cover.webp
  alt: "Kapak görseli: Redis Databases (RedisInsight) Nedir?"
  lqip: "data:image/webp;base64,UklGRloAAABXRUJQVlA4IE4AAACQAwCdASoYAA0APu1kqU4ppaOiMAgBMB2JZQAAWpcmygA3Ce0wAP7sEYgkbVHKYMKjnPkgjfBV5iNN7g9gXF3aDm44uDGVCKeMI/QcmAA="
---

## Giriş

Merhaba,

Her komutu tek tek [`redis-cli`](/posts/run-redis-with-docker/) üzerinden elle yazmak yerine, bir Redis sunucusundaki gerçek zamanlı veriyi grafik bir arayüzle görüp değiştirmemizi sağlayan resmi araç **RedisInsight**'ı kısaca tanıtacağım.

## İndirme

RedisInsight'ı üyeliğe/denemeye gerek kalmadan tamamen ücretsiz kullanabilirsiniz — Windows, macOS veya Linux için **[redis.io/insight](https://redis.io/insight/)** adresinden doğrudan indirebilir, ya da yerelinize hiçbir şey kurmak istemiyorsanız bir Docker container'ı olarak da çalıştırabilirsiniz.

## Arayüze Genel Bakış

Redis Databases'i indirip kurduktan sonra, verinin görselleştirileceği Redis sunucusuna bağlanmak için "Add Redis Database" butonuna tıklamanız yeterli. Görseldeki gibi bilgilerinizi girdikten sonra "Test Connection" ile bağlantıyı test edebilirsiniz. Sağ altta "Test Successful" yazısını gördüğünüzde ekleme işlemi tamamlanmış olur.

![Desktop View](/assets/img/posts/redis-desktop.webp)
_Redis Databases_

## Şimdi Deneyelim

Daha önce Docker üzerinde bir Redis container'ı oluşturup çalıştırmıştık. Onu silmediyseniz aynı container'ı tekrar başlatabilirsiniz. Sorunsuz çalışmaya başladığında Redis Databases üzerinden bağlantınıza erişip, aşağıdaki görseldeki gibi daha önce oluşturduğumuz mesajı görebilirsiniz.

![Desktop View](/assets/img/posts/redis-3.webp)
_Redis message_

Redis'e yeni başlayanlara ya da henüz öğrenmeye çalışanlara bu uygulamayı kesinlikle öneririm — serinin önceki yazısında ele aldığımız [veri tiplerini](/posts/redis-data-types/) ham `redis-cli` çıktısını okumaktan çok daha kolay görüp anlamanızı sağlıyor.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
