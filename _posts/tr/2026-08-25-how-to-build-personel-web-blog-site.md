---
title: "GitHub Pages Üzerinde Bir Blog Başlatmak"
description: "Jekyll ve Chirpy tema ile GitHub Pages üzerinde ücretsiz bir geliştirici blogu açmak için pratik bir rehber — özel alan adı kurulumu dahil."
date: 2026-08-25 02:50 +0300
translation_key: how-to-build-personel-web-blog-site
categories: [Meta, Blogging]
tags: [jekyll, github-pages, blogging, custom-domain]
image:
  path: /assets/img/posts/how-to-build-personel-web-blog-site/cover.webp
  alt: "Kapak görseli: GitHub Pages Üzerinde Bir Blog Başlatmak"
  lqip: "data:image/webp;base64,UklGRmIAAABXRUJQVlA4IFYAAABQAwCdASoYAA0APu1iqU2ppaOiMAgBMB2JZQAAWo6r2+2MYAD+7BGIJG1RyhQfceGIxMp+E3oDvdMzsTahYWr3NJgLY++bWpI2ahyF/fyGmf71JMAAAA=="
---

## İlk Blog Yazım

Bir süredir blog başlatmayı düşünüyordum ama epey erteliyordum. Sonunda yaptım ve işte ilk blog yazımı yazıyorum. İlginç bir şekilde konusu, blogumu nasıl kurduğum ve sizin de nasıl yapabileceğiniz olacak.

![Desktop View](/assets/img/posts/blog_meme.webp)
_Blog başlatan bir geliştiricinin senaryosu_

### [YouTube Videosu: Jekyll Rehberi](https://www.youtube.com/watch?v=F8iOU1ci19Q)

## Neden GitHub Pages ?

Bir programcıyım. Her zaman projelerimi sergileyebileceğim, düşüncelerimi paylaşabileceğim kişisel bir web sitem olsun istedim. [Wordpress](https://wordpress.com/), [Medium](https://medium.com/), [Substack](https://substack.com) ve [Ghost](https://ghost.org/) gibi çeşitli blog platformlarına baktım. Ama GitHub Pages'i Jekyll ile seçtim, çünkü şunları istiyordum:

1. Blogum üzerinde tam kontrol ve kendi zevkime göre özelleştirebilmek.
2. Ücretsiz olan, hosting için para ödemem gerekmeyen bir blog.
3. Basit, hızlı ve yapılandırmak için saatler harcamama gerek kalmayan, kolay bakımı olan bir blog.

İkna oldunuz mu? Tamam, şimdi blog sitenizi kurma adımlarına geçelim.

## Adım 1: Temanızı Belirleyin

Bu adımda çeşitli sitelerdeki Jekyll temalarına hızlıca göz atıp zevkinize uyanı seçiyorsunuz.

Bu şablonları bulabileceğiniz birkaç site:

* <https://jekyllthemes.io/>
* <https://jekyllthemes.org/>
* <https://jekyll-themes.com/>
* <https://jamstackthemes.dev/ssg/jekyll/>

Ben kişisel olarak [Chirpy tema](https://github.com/cotes2020/chirpy-starter/)'sını seçtim, çünkü beklentilerime uyuyordu ve bir Koyu tema seçeneği vardı.

## Adım 2: GitHub Pages'i Etkinleştirin

Jekyll temanızı seçtikten sonra sırada onu GitHub Pages üzerinde barındırmak var. Seçtiğiniz tema genellikle bir yapılandırma talimat seti ile gelir ve bu talimatlar temadan temaya değişir.

Chirpy teması için talimatlar şöyle:

1. Kendi repository'nizi oluşturmak için [şablonu](https://github.com/cotes2020/chirpy-starter/generate) kullanın.
    * `<github-kullanıcı-adınız>.github.io` şeklinde isimlendirdiğinizden emin olun
    * Bu adımdan sonra GitHub Actions blogunuzu otomatik olarak `<github-kullanıcı-adınız>.github.io` adresine build edip deploy edecek
    * Ama sadece bir şablon istemiyorsunuz, onu kendinize özgü hale getirmek istiyorsunuz. O yüzden sıradaki adıma geçelim.
2. Az önce oluşturduğunuz repository'yi klonlayın.
3. Makinenize Ruby ve Jekyll'i [resmi rehber](https://jekyllrb.com/docs/installation/) üzerinden kurun.
4. Gerekli gem'leri kurmak için `bundle install` çalıştırın.
5. `_config.yml` dosyasındaki değişkenleri ihtiyacınıza göre güncelleyin. Bazıları tipik seçeneklerdir.
    * `url` web sitenizin adresidir
    * `avatar` kenar çubuğundaki profil resmidir
    * `timezone` yazılarınızın tarih/saatini göstermek için kullanılır
    * `lang` sitenin dilidir
6. Yerel sunucuyu başlatmak için `bundle exec jekyll s` çalıştırın.

![Template Blog](/assets/img/posts/template-blog.webp)
_Göreceğiniz orijinal şablon_

Herhangi bir sorunla karşılaşırsanız [Chirpy temasının Başlangıç rehberine](https://chirpy.cotes.page/posts/getting-started/) bakabilirsiniz.

## Adım 3: Özel Kök Alan Adınızı Kurun

Özel bir alan adı satın almak için alan adı kayıt kuruluşlarından (registrar) birine gitmeniz gerekiyor. Seçebileceğiniz birkaç registrar:

* [GoDaddy](https://www.godaddy.com/)
* [Namecheap](https://www.namecheap.com/)
* [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/) — alan adlarını maliyetine satıyor (kâr marjı yok), bu registrar'lar arasında sıra dışı bir durum

(Burada eskiden yaygın bir öneri olan Google Domains, 2024'te kapandı ve tüm müşterilerini Squarespace'e taşıdı — artık yeni kayıtlar için bir seçenek değil.)

### Alan Adınızı Yapılandırın

Alan adınızı satın aldıktan sonra alan adı yönetim panelinize gidin, DNS'i yönet'e tıklayın ve GitHub Pages için `A` tipi DNS kayıtları ekleyin.

| Tip   | Veri                   |
|-------|------------------------|
| A     | 185.199.108.153        |
| A     | 185.199.109.153        |
| A     | 185.199.110.153        |
| A     | 185.199.111.153        |
| CNAME | gh-username.github.io  |

_(Bu `A` tipi DNS kayıtları, alan adınızı GitHub'ın IP adresine eşler)_

### GitHub Pages'i Yapılandırın

Alan adınızın DNS ayarları hazır olduğuna göre, GitHub'a dönüp GitHub Pages'i özel alan adınızı kullanacak şekilde yapılandıralım.

1. **Repository'nizin ayarlar** sayfasına gidin.
2. **Pages** bölümüne kadar aşağı inin.
3. **Custom domain** altına alan adınızı girin ve **Save**'e tıklayın.

![Custom Domain](/assets/img/posts/custom-domain.webp)
_GitHub Pages özel alan adı sayfam_

_**En İyi Uygulama:**_ Blogunuzu güvenli bir SSL bağlantısı üzerinden sunmak için **Enforce HTTPS**'e tıklayın. Siteniz [Let's Encrypt](https://letsencrypt.org/)'ten ücretsiz bir SSL sertifikasıyla yapılandırılacak.

Bu yazıyı faydalı bulduğunuzu umarım. Sorularınız varsa GitHub'daki [blogumun repo'suna](https://github.com/alparslanakbas/alparslanakbas.github.io) bakabilir ya da [LinkedIn](https://www.linkedin.com/in/alparslanakbas/) üzerinden benimle iletişime geçebilirsiniz.

## Kısa Bir Güncelleme

Bu yazı blogdaki en eski yazı ve bazı şeyler diğerlerinden daha iyi ayakta kaldı. Chirpy tema hâlâ burada (şimdi birkaç major sürüm daha yeni). Yukarıdaki özel alan adı adımları hâlâ doğru — GitHub'ın DNS kayıtları değişmedi. Değişen şey şu: bu blog için özel bir alan adı satın almamaya karar verdim, `alparslanakbas.github.io` ile devam ettim — GitHub Pages alt alan adında kalmanın SEO açısından bir cezası yok, ayrıca bakımı gereken bir şey daha eksildi. İkisinin de gerçekten sorunsuz olduğunu bilmek faydalı.

Bu adımları takip ederek nereye varıldığını görmek isterseniz [rate limiting yazısı](/tr/posts/dotnet7-how-to-use-rate-limitter/) yazının nereye evrildiğine iyi bir örnek, [/projects](/projects/) sayfasında da bugüne kadar gerçekten neler inşa ettiğim var.
