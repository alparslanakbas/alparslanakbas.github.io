---
title: "TPH (Table Per Hierarchy) Ne Demek?"
description: "Entity Framework Core'da Table Per Hierarchy (TPH) tanıtımı: sınıf kalıtımını tek bir tabloya nasıl eşler, artı ve eksileriyle."
date: 2026-08-25 02:55 +0300
translation_key: what-is-tph
categories: [.NET, Entity Framework]
tags: [aspnet-core, dotnet-8, entity-framework, orm]
image:
  path: /assets/img/posts/what-is-tph/cover.webp
  alt: "Kapak görseli: TPH (Table Per Hierarchy) Ne Demek?"
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAACQAwCdASoYAA0APu1iqU2ppaQiMAgBMB2JZQAAWpcmygMAWxwAAP7sEYgkbVHKEyNe+2tq5AO9gKyWSyytiNN7fRQMzIpveCNhuNqml73sQS3Xf3qSYAAA"
---

## Table Per Hierarchy (TPH): Bir Veritabanı Kalıtım Stratejisi

Table Per Hierarchy (TPH), nesne yönelimli programlamadaki kalıtım ilişkilerini veritabanına eşlemek için kullanılan popüler stratejilerden biridir. TPH, Entity Framework gibi Nesne-İlişkisel Eşleme (ORM) araçlarında sıkça kullanılır ve bir kalıtım hiyerarşisindeki tüm varlıkların tek bir veritabanı tablosunda saklanmasını sağlar.

Bu yazıda TPH'nin ne olduğunu, nasıl çalıştığını, artılarını ve eksilerini inceleyeceğiz; ayrıca TPH'nin nasıl uygulanabileceğini görmek için örnek bir senaryoya bakacağız. Büyük veri setleriyle çalışırken önem taşıyan performans açısından da TPH'yi değerlendireceğiz. Aşağıdaki örneği önce gerçek bir veritabanı kurmadan denemek isterseniz, EF Core'un [bellek içi (in-memory) sağlayıcısı](/posts/working-with-in-memory/) böyle bir hiyerarşiyi prototiplemek için gayet uygun çalışır.

## TPH Nedir?

Kalıtım, nesne yönelimli programlamada (OOP) bir sınıfın (alt veya türetilmiş sınıf) başka bir sınıftan (üst veya taban sınıf) özellik ve metotları devralmasını sağlayan yaygın bir özelliktir. Bu OOP ilişkilerini ilişkisel bir veritabanına eşlerken, devralınan özelliklerin nasıl saklanacağına karar vermemiz gerekir. TPH tam da burada devreye girer.

TPH, bir sınıf hiyerarşisinin tüm özelliklerini tek bir tabloda saklar ve her kaydın hangi sınıfa ait olduğunu belirlemek için bir discriminator (ayırt edici) sütun kullanır. Sonuç olarak, kayıt hangi alt sınıfı temsil ediyorsa ona göre tablodaki bazı alanlar null kalabilir.

### Örnek Senaryo: Ürün Yönetimi

Farklı ürün tiplerini yönettiğimiz bir e-ticaret sistemi örneğini ele alalım. Product adında bir taban sınıfımız olduğunu ve ürünleri, her biri kendine özgü özelliklere sahip Book ve ElectronicProduct gibi alt sınıflara ayırmak istediğimizi varsayalım.

<strong>Ürünler İçin Sınıf Yapısı</strong>

```csharp
public class Product
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public float Price { get; set; }
}

public class Book : Product
{
    public required string Author { get; set; }
    public int Pages { get; set; }
}

public class ElectronicProduct : Product
{
    public required string Manufacturer { get; set; }
    public int WarrantyPeriod { get; set; }
}
```

Bu yapıda hem Book hem de ElectronicProduct, Product sınıfından kalıtım alır, ancak her alt sınıfın kendine özgü alanları vardır. Şimdi bu hiyerarşiyi bir veritabanında TPH kullanarak nasıl saklayabileceğimize bakalım.

## Veritabanı Yapısı (TPH)

TPH kullanarak sınıf hiyerarşisindeki tüm veriyi tek bir tabloda saklarız. Tablo, olası tüm alanlar için sütunlar içerir; ancak yalnızca belirli satırlar, temsil ettikleri alt sınıf tipine göre belirli sütunları kullanır.
Tablo şu şekilde görünebilir:

![Desktop View](/assets/img/posts/tph-table-view.webp)
_Table-Per Hierarchy_table-view_

Bu tabloda:

* <strong>Discriminator</strong> sütunu, satırın hangi alt sınıfı temsil ettiğini belirtir. Örneğin "Book" ya da "ElectronicProduct."
* <strong>Book</strong> sınıfına ait satırlar yalnızca Author ve Pages sütunlarını doldurur, diğer alanlar null kalır.
* <strong>ElectronicProduct</strong> sınıfına ait satırlar Manufacturer ve WarrantyPeriod sütunlarını kullanır, kitaba özgü alanlar null kalır.

## TPH'nin Avantajları

* <strong>Tek Tablo Yönetimi:</strong> Farklı alt sınıflar için birden fazla tablo oluşturmaya gerek kalmaz, veritabanı şeması sadeleşir.
* <strong>Performans:</strong> Tüm veri tek bir tabloda saklandığı için, sorgular birden fazla tablo arasında join gerektirmez; bu da basit sorguları hızlandırabilir.
* <strong>Basitlik:</strong> Tüm kalıtım hiyerarşisi verisi tek bir tabloda saklandığından şema oldukça sade kalır.

### TPH'nin Dezavantajları

* <strong>Null Değerler:</strong> Bazı alanlar yalnızca belirli alt sınıflarla ilgili olduğu için bazı sütunlar sürekli null içerir. Bu, veri fazlalığına ve israfa yol açabilir.
* <strong>Okunabilirlik:</strong> Birden fazla varlık tipini tek bir tabloda yönetmek, sistem büyüdükçe veritabanı şemasını anlamayı ve sürdürmeyi zorlaştırabilir.
* <strong>Performans Ödünleşimleri:</strong> Büyük veri setlerinde, Discriminator alanını sürekli kontrol etmek ve null değerleri idare etmek, özellikle tablo çok büyüdüğünde performansı etkileyebilir.

## TPH Kodda Nasıl Uygulanır?

TPH'yi Entity Framework gibi bir ORM'de uygulamak oldukça basittir. Farklı alt sınıfları nasıl ayırt edeceğinizi belirtmek için Discriminator özelliğini kullanabilirsiniz:

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Product>()
        .HasDiscriminator<string>("Discriminator")
        .HasValue<Book>("Book")
        .HasValue<ElectronicProduct>("ElectronicProduct");
}
```

Bu, Entity Framework'ü Book ve ElectronicProduct varlıklarını aynı Product tablosunda saklayacak, aralarındaki farkı da Discriminator sütunuyla ayırt edecek şekilde yapılandırır.

## Sonuç

TPH, veritabanı şemanızı sade tutmanız gerektiğinde güçlü bir kalıtım eşleme stratejisidir. Küçük projeler ya da kalıtım hiyerarşisinin çok karmaşık olmadığı senaryolar için iyi çalışır. Ancak proje büyüdükçe performans darboğazlarıyla ya da null değerlerin yönetimiyle ilgili zorluklarla karşılaşabilirsiniz. Bu yüzden TPH, basit kalıtım ilişkileri için cazip bir seçim olsa da, ödünleşimlerini dikkatle değerlendirip uzun vadeli ihtiyaçlarınıza uyup uymadığına bakmalısınız.

Yukarıdakilerin hepsi güncel EF Core için hâlâ geçerli — TPH'nin kendisi değişmedi. Alternatifleriyle karşılaştırmak isterseniz, EF Core ayrıca Table-Per-Type (TPT, join'lerle çalışan sınıf başına ayrı tablo) ve Table-Per-Concrete-Type (TPC, hiç paylaşılan tablo olmayan) eşleme stratejilerini ve (EF Core 8'de yeniden getirilen) complex type'ları — kalıtım dışı bir yolla ilgili özellikleri gruplamak için — destekler. TPH, tam da diğer ikisinin gerektirdiği join'lerden kaçındığı için okuma performansında üçü arasında en hızlısı kalır — null'lara katlanmaya değer ödünleşim de bu. Şemasız (schema-less) bir depo olan [Redis](/posts/redis-data-types/)'in "farklı şekillerdeki veriyi" nasıl ele aldığıyla da ilginç bir zıtlık oluşturuyor — baştan sabit bir şema olmadığında discriminator sütununa da hiç gerek kalmıyor.
<hr>
Bu yazının, Table Per Hierarchy (TPH)'yi projelerinizde nasıl uygulayacağınızı anlamanıza yardımcı olduğunu umuyorum.

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
_Thanks For Reading_
