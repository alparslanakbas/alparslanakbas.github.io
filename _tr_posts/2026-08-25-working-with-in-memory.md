---
title: "Entity Framework Core ile Bellek İçi Veritabanı Kullanımı"
description: "Gerçek bir veritabanı bağlantısı olmadan veri erişimini hızlıca modelleyip test etmek için EF Core'un in-memory sağlayıcısını kullanma."
date: 2026-08-25 02:05 +0300
translation_key: working-with-in-memory
categories: [.NET, Entity Framework]
tags: [entity-framework, in-memory-database, testing]
image:
  path: /assets/img/posts/working-with-in-memory/cover.webp
  alt: "Kapak görseli: Entity Framework Core ile Bellek İçi Veritabanı Kullanımı"
  lqip: "data:image/webp;base64,UklGRmQAAABXRUJQVlA4IFgAAACQAwCdASoYAA0APu1kq04ppaQiMAgBMB2JZQAAWpgEFP6iVluAAP7sEYgkbVHKEyLpTmARihIeAK2oyX82I03uEv7fr8K9jBy7dZd/Q5R8q04C/cmEAAAA"
---

## Giriş

Merhaba,

Günlük hayatta yeni bir teknolojiyi, yapıyı ya da yöntemi öğrenirken ya da uygularken — hatta geliştirdiğiniz bir ürünü tanıtırken — projeniz bir veritabanı gerektiriyorsa ve **ORM**'unuz olarak **Entity Framework Core** kullanıyorsanız, gerçek bir veritabanı kurup gerekli bağlantıları oluşturmanın ne kadar maliyetli olabileceğini muhtemelen biliyorsunuzdur. Bu tür senaryolarda Entity Framework Core, fiziksel bir veritabanındakiyle aynı işlemleri bu ek yük olmadan gerçekleştirmenizi sağlayan **In-Memory** (bellek içi) veritabanı desteği sunar. Bu da işinize daha verimli odaklanmanızı sağlar. Bu özelliği nasıl kullanacağımızı inceleyelim — ve sizi buraya asıl getiren şey kalıtım eşlemesiyse, [TPH yazısı](/posts/what-is-tph/) örneklerini gerçek bir veritabanı olmadan çalıştırılabilir tutmak için tam olarak bu sağlayıcıyı kullanıyor.

## Başlayalım

Öncelikle **Entity Framework Core**'da In-Memory bir veritabanıyla çalışmanın artılarını ve eksilerini konuşalım;

**Artıları**:

* Test ve tanıtım uygulamalarında, gerçek/fiziksel veritabanları oluşturup yapılandırmak yerine, tüm veritabanını bellekte modelleyip gerekli işlemleri gerçek bir veritabanında çalışıyormuş gibi gerçekleştirebilirsiniz.
* Bellekte çalışmak geçici bir deneyim olduğu için, test veritabanlarının veritabanı sunucularında gereksiz depolama kullanımını önler.
* Veritabanını bellekte modellemek, kodun daha hızlı test edilmesini sağlar.

**Eksileri**:

* In-Memory bir veritabanıyla yapılan veritabanı işlemlerinde ilişkisel modelleme mümkün değildir. Sonuç olarak veri tutarlılığı zayıflayabilir, bu da yanlış istatistiksel sonuçlara yol açabilir.

Bellekte tasarlanan bir veritabanı üzerinde hızlı testler yaptıktan sonra, uygulamanın gerçek bir veritabanına geçmeye hazır olduğuna karar verildiğinde, gerekli yapılandırmalar kolayca uygulanabilir ve uygulama doğrudan fiziksel bir veritabanına bağlanabilir.

### Kütüphane Kurulumu

Entity Framework Core ile in-memory veritabanlarıyla çalışmak için sağlayıcı paketini kurun:

```bash
dotnet add package Microsoft.EntityFrameworkCore.InMemory
```

### Örnek Uygulama

Gösterim amacıyla birkaç entity modeli oluşturarak başlayalım. İşte bir **Employee** entity'sinin örneği:

```csharp
class Employee
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public List<Customer> Customers { get; set; }
}
```

#### Customer

```csharp
class Customer
{
    public int Id { get; set; }
    public string Name { get; set; }
    public Employee Employee { get; set; }
}
```

Ardından, context sınıfını aşağıdaki gibi tasarlayın.

```csharp
class Context : DbContext
{
    public Context() { }
    public Context(DbContextOptions<Context> options) : base(options) { }

    public DbSet<Employee> Employees { get; set; }
    public DbSet<Customer> Customers { get; set; }
 
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
            optionsBuilder.UseInMemoryDatabase("InMemoryDb");
    }
}
```

Burada dikkat edilmesi gereken kilit nokta, `OnConfiguring` içindeki **UseInMemoryDatabase** çağrısı. Bu, context'e gerçek bir veritabanına bağlanmak yerine veriyi bellekte saklayacağını bildirir.

Böylece test amaçlı bir bellek içi veritabanı sağlamış ve işimizdeki ekstra yükü azaltmış olduk.

## Daha Yaygın Bir Desen: Testler İçin Değiştirilebilir Hale Getirmek

Sağlayıcıyı `OnConfiguring` içine sabit kodlamak hızlı bir demo için işe yarar, ama bu, context'inizin *yalnızca* bellek içinde çalışabileceği anlamına gelir — aynı `DbContext`'in production'da gerçek bir veritabanına karşı da çalışması gerekiyorsa istediğiniz şey bu değildir. Daha yaygın yaklaşım, context'i sağlayıcıdan bağımsız bırakıp bunun yerine dependency injection ile yapılandırmaktır; böylece bir test projesi, context sınıfına hiç dokunmadan in-memory sağlayıcıyı devreye sokabilir:

```csharp
// Test projenizin kurulumunda:
var options = new DbContextOptionsBuilder<Context>()
    .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
    .Options;

using var context = new Context(options);
```

Veritabanı adı olarak `Guid.NewGuid()` kullanmak, her teste kendi izole bellek içi veritabanını verir; böylece testler paralel çalıştığında birbirlerinin durumuna sızmaz — bir test paketinde aynı veritabanı adını tekrar kullanıp bir testin artakalan verisinin başka bir testi neden bozduğunu merak ederseniz karşınıza çıkan gerçek bir tuzak.

Sonraki yazılarımda görüşmek üzere, iyi kodlamalar..

![Desktop View](/assets/img/posts/thanks-for-reading.webp)
*Thanks For Reading*
