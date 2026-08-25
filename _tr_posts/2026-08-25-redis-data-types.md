---
title: "Redis Veri Tipleri"
description: "Redis'in temel veri tiplerine pratik bir tur: string'ler, list'ler, set'ler, sorted set'ler ve hash'ler, her biri için gerçek komut örnekleriyle."
date: 2026-08-25 00:30 +0300
translation_key: redis-data-types
categories: [Data, Redis]
tags: [redis, data-types, nosql]
image:
  path: /assets/img/posts/redis-data-types/cover.webp
  alt: "Kapak görseli: Redis Veri Tipleri"
  lqip: "data:image/webp;base64,UklGRlgAAABXRUJQVlA4IEwAAADwAgCdASoYAA0APu1kqU4ppaOiMAgBMB2JZQAAg8QFYAD+78iLmXpwy8fl86QdwBUNuR74KcoLSG2xGznpJKSWMQl4hXvYdF/vR4AA"
---

Redis'i tercih edilir kılan en önemli özelliklerden biri olan Redis veri tiplerini bu yazıda inceleyeceğiz. Henüz [çalışan bir Redis sunucun](/posts/run-redis-with-docker/) yoksa önce oradan başla — aşağıdaki her şey `redis-cli` ile bağlanabildiğini varsayıyor.

Redis, veri tipleri açısından zengin bir veritabanıdır. Birazdan inceleyeceğimiz bu veri tiplerinin genel özelliği, key-value formatında en fazla 512 MB'a kadar saklanabilmeleridir. Şimdi veri tiplerine bir göz atalım.

## 1- Redis String

En basit veri tipidir. Adı sadece metinsel veri tipleri için geçerli olduğunu düşündürse de, metinsel tiplerin yanı sıra her türlü veriyi barındırabilir. Görsel ve PDF gibi dosyaları bile binary formatta saklayabilir. Anlayacağın gibi, sınırlaması olmayan bir veri tipi.

### a- Temel String Set/Get

```bash
SET name "Alparslan"
GET name # "Alparslan" döner
```

### b- Sayısal String İşlemleri

```bash
SET counter 10
INCR counter     # 11 döner
INCRBY counter 5 # 16 döner
DECR counter     # 15 döner
```

### c- Çoklu String İşlemleri

```bash
MSET user:1:name "Alparslan" user:1:age "26"
MGET user:1:name user:1:age  # ["Alparslan", "26"] döner
```

### d- String Değişiklikleri

```bash
SET bestduo "Legolas"
APPEND message " Aragorn"  # "Legolas Aragorn" olur
STRLEN message          # 14 döner (karakter sayısı)
```

### e- Otomatik Süresi Dolan String

```bash
SETEX session:token 3600 "mybestsecrettoken"  # 1 saat sonra otomatik silinir
```

### f- Koşullu String Atama

```bash
SETNX user:email "test@test.com"  # Sadece key yoksa set eder
```

Bu örnekler **Redis string** veri tipinin temel kullanım desenlerini gösteriyor.

## 2- Redis List

Değerleri bir koleksiyonda saklayan bir tiptir. Elemanlar koleksiyonun başına veya sonuna eklenebilir. Metotlar şöyle:

### a- Listenin Başına ve Sonuna Eleman Ekleme

```bash
LPUSH todos "Learn Redis"       # Listenin başına ekle
RPUSH todos "Learn MongoDB"     # Listenin sonuna ekle
LRANGE todos 0 -1              # Tüm elemanları getir
```

### b- Listeden Eleman Silme

```bash
LPOP todos   # Baştaki elemanı sil ve döndür
RPOP todos   # Sondaki elemanı sil ve döndür
```

### c- Liste Uzunluğu ve İndeksle Eleman Getirme

```bash
LLEN users         # Liste uzunluğunu döndürür
LINDEX todos 1     # 1 indeksindeki elemanı getirir
```

### d- Belirli Bir Elemanı Silme

```bash
LREM tasks 1 "completed task"   # "completed task"ın 1 örneğini siler
```

### e- Pratik Örnek - Sosyal Medyada Son Gönderiler

```bash
LPUSH latest:posts "post:1"
LPUSH latest:posts "post:2"
LTRIM latest:posts 0 9    # Sadece son 10 gönderiyi tut
```

### f- Liste İçinde Güncelleme

```bash
LSET shopping:list 0 "computer"    # 0 indeksindeki elemanı "computer" ile değiştir
```

### g- Aralıktaki Elemanları Getirme

```bash
# Liste: ['task1', 'task2', 'task3', 'task4', 'task5']
LRANGE tasks 1 3    # ['task2', 'task3', 'task4'] döner
```

### h- Bloklayan Liste İşlemleri

```bash
BLPOP queue:tasks 30    # 30 saniye bekle ve müsait olunca ilk elemanı al
```

Bu örnekler **Redis List**'lerin temel kullanım desenlerini gösteriyor. List yapısı özellikle sıralı veri tutmak, kuyruk sistemleri kurmak ve son N elemanı saklamak gibi senaryolar için uygundur.

## 3- Redis Set

Redis List'in benzersiz (unique) versiyonudur. Ayrıca veri rastgele bir sırayla eklenir.

### a- Temel Set İşlemleri

```bash
SADD users "Alparslan"          # Tek üye ekle
SADD users "Gazi" "Serdar"   # Birden fazla üye ekle
SMEMBERS users            # Tüm üyeleri getir
SCARD users               # Set boyutunu getir
```

### b- Üye Varlığını Kontrol Etme

```bash
SISMEMBER users "Alparslan"    # Varsa 1, yoksa 0 döner
```

### c- Üye Silme

```bash
SREM users "Gazi"         # Tek üye sil
SPOP users               # Rastgele bir üyeyi sil ve döndür
```

### d- Set İşlemleri (Birleşim, Kesişim, Fark)

```bash
# Takım üyelikleri
SADD team:backend "Alparslan" "Gazi"
SADD team:frontend "Serdar" "Alparslan"

SINTER team:backend team:frontend    # Her iki takımda da olan üyeler
SUNION team:backend team:frontend    # Herhangi bir takımda olan üyeler
SDIFF team:backend team:frontend     # Sadece backend'de olan üyeler
```

### e- Pratik Örnek - Kullanıcı Yetenekleri

```bash
SADD user:1:skills "dotnet" "redis" "blazor"
SADD user:2:skills "oracle" "redis" "mongodb"
```

### f- Rastgele Üye Seçimi

```bash
# Katılımcılar arasından rastgele bir kazanan seç
SADD raffle:users "user1" "user2" "user3"
SRANDMEMBER raffle:users      # Silmeden rastgele bir üye getir
```

### g- Üyeyi Set'ler Arasında Taşıma

```bash
# Kullanıcıyı active'den inactive'e taşı
SMOVE users:active users:inactive "Alparslan"
```

### h- Set İşlemlerini Saklama

```bash
# İki kullanıcı arasındaki ortak yetenekleri sakla
SINTERSTORE common:skills user:1:skills user:2:skills
```

Bu örnekler, Redis Set'lerin benzersiz koleksiyonlar saklamak ve set işlemleri yapmak için nasıl kullanışlı olduğunu gösteriyor. Özellikle şu senaryolar için iyidir:

* Benzersiz ilişkileri yönetmek
* Benzersiz ziyaretçileri takip etmek
* Etiketleri (tag) uygulamak
* Kullanıcı rollerini/izinlerini saklamak
* Rastgele seçim sistemleri

## 4- Redis Sorted Set

**Redis Set**'in sıralı bir versiyonudur. Veriyi istediğin herhangi bir sırayla ekleyebilirsin. İşte **Redis Sorted Set** örnekleri.

### a- Temel Sorted Set İşlemleri

```bash
ZADD scores 100 "Legolas"         # Skorlu üye ekle
ZADD scores 95 "Aragorn" 97 "Gimli" # Skorlu birden fazla üye ekle
ZRANGE scores 0 -1             # Tüm üyeleri getir (artan)
ZREVRANGE scores 0 -1          # Tüm üyeleri getir (azalan)
```

### b- Skorları ve Sıralamaları Getirme

```bash
ZSCORE scores "Legolas"           # Üyenin skorunu getir
ZRANK scores "Legolas"           # Üyenin sırasını getir (artan)
ZREVRANK scores "Legolas"        # Üyenin sırasını getir (azalan)
```

### c- Skorlu Aralık İşlemleri

```bash
# Üyeleri skorlarıyla birlikte getir
ZRANGE scores 0 -1 WITHSCORES
```

### d- Skor Aralığı Sorguları

```bash
# Skoru 90 ile 95 arasında olan kullanıcıları getir
ZRANGEBYSCORE leaderboard 90 95
```

### e- Pratik Örnek - Skor Tablosu

```bash
ZADD leaderboard 1000 "player1"
ZADD leaderboard 2000 "player2"
ZADD leaderboard 3000 "player3"
ZREVRANGE leaderboard 0 2      # İlk 3 oyuncu
```

### f- Skorları Artırma

```bash
# Kullanıcı puanını artır
ZINCRBY points 50 "user1"     # user1'in skoruna 50 puan ekle
```

### g- Üye Silme

```bash
ZREM leaderboard "player1"    # Belirli bir üyeyi sil
```

### h- Skor Aralığındaki Üyeleri Sayma

```bash
# Skoru 2000 ile 3000 arasında olan oyuncuları say
ZCOUNT leaderboard 2000 3000
```

### i- Zaman Bazlı Sıralama Örneği

```bash
# Skor olarak timestamp'li gönderiler ekle
ZADD posts 1703673600 "post:1"    # Skor olarak Unix timestamp
ZADD posts 1703760000 "post:2"
ZREVRANGE posts 0 10               # Son 10 gönderiyi getir
```

Bu örnekler Sorted **Set**'lerin şunlar için ne kadar ideal olduğunu gösteriyor:

* Skor tabloları
* Öncelik kuyrukları
* Zaman bazlı veri sıralaması
* Değerlendirme (rating) sistemleri
* Sıralama sistemleri

## 5- Redis Hash

Veriyi key-value formatında saklayan bir tiptir. İşte **Redis Hash** veri tipi örnekleri:

### a- Temel Hash İşlemleri

```bash
HSET user:1 name "Alparslan" age "26" city "Ankara"    # Birden fazla alan set et
HGET user:1 name                                    # Tek bir alanı getir
HGETALL user:1                                      # Tüm alanları ve değerleri getir
```

### b- Tek Alan Set/Get

```bash
HSET product:1 price "99.99"       # Tek alan set et
HSETNX product:1 stock "50"        # Sadece alan yoksa set et
```

### c- Çoklu Alan İşlemleri

```bash
HMSET user:2 name "Alparslan" email "alparslan@email.com" age "26"
HMGET user:2 name email                            # Birden fazla alanı getir
```

### d- Alan Kontrolü ve Silme

```bash
HEXISTS user:1 email               # Alan var mı kontrol et
HDEL user:1 age                    # Alanı sil
```

### e- Hash Alanlarını Artırma

```bash
HSET inventory:1 quantity 10
HINCRBY inventory:1 quantity 5     # 5 artır
```

### f- Alan Bilgisi Getirme

```bash
HLEN user:1                        # Alan sayısı
HKEYS user:1                       # Tüm alan isimlerini getir
HVALS user:1                       # Tüm değerleri getir
```

### g- Pratik Örnek - Kullanıcı Profili

```bash
# Kullanıcı profilini sakla
HSET user:100 username "Alparslan"
             password "hashed_password"
             email "alparslan@email.com"
             last_login "2024-12-27"
```

### h- Pratik Örnek - Alışveriş Sepeti

```bash
# Kullanıcı profilini sakla
HSET cart:1 product:1 "2"          # Ürün 1'den 2 adet
HSET cart:1 product:2 "1"          # Ürün 2'den 1 adet
HINCRBY cart:1 product:1 1         # Ürün 1'den bir tane daha ekle
```

Bu örnekler **Hash**'lerin şunlar için ne kadar kullanışlı olduğunu gösteriyor:

* Kullanıcı profilleri
* Ürün detayları
* Konfigürasyon ayarları
* Session storage
* Alışveriş sepetleri
* Obje caching

Bu beşi — String, List, Set, Sorted Set ve Hash — Redis'in orijinal, temel veri tipleridir ve gerçek kullanım vakalarının büyük çoğunluğunu kapsar. Redis 8'den itibaren, eskiden ayrı ücretli bir eklenti olan (Redis Stack) birkaç veri tipi daha — JSON dokümanları, Time Series ve Bloom filter gibi olasılıksal tipler — artık çekirdek, açık kaynak Redis'in bir parçası olarak geliyor. Bir kullanım vakası yukarıdaki beşinin hiçbirine tam oturmuyorsa var olduklarını bilmekte fayda var, ama bu yazının kapsamı dışındalar.

Bu veri tiplerinin sana faydalı olduğunu umuyorum. Sırada: oluşturmayı yeni öğrendiğin her şeye göz atmak için bir GUI olan [RedisInsight](/posts/redis-databases/)'e bir bakış.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Okuduğunuz için teşekkürler_
