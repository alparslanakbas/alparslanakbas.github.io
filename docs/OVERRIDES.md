# Tema override kayıtları

`jekyll-theme-chirpy` bir gem olarak kullanılıyor (bkz. `CLAUDE.md` §4). Gem içindeki bir dosya
bu repoda override edildiğinde buraya satır eklenir. Format:

| Dosya yolu | Kaynak tema sürümü | Neden | Son senkron tarihi |
|---|---|---|---|
| `_layouts/post.html` | 7.6.0 | `tail_includes` listesine `series-nav` (yeni `_includes/series-nav.html`, `page.series` set olan yazılarda "bu seride: ..." kutusu gösteriyor) ve `author-card` (yeni `_includes/author-card.html`, her yazının altında foto+bio+takip linkleri kartı) eklemek için | 2026-08-24 |
| `_includes/metadata-hook.html` | 7.6.0 | Gem'deki hâli tek satırlık boş bir placeholder yorum ("A placeholder to allow defining custom metadata") — teknik olarak override ama CLAUDE.md §4'ün kendi tercih sıralamasında en ucuz/sancısız seçenek olarak zaten öngörülmüştü. EN/TR yazı çiftleri için `hreflang`/`x-default` linkleri üretiyor (`page.translation_key` set değilse tamamen no-op). | 2026-08-25 |
| `_includes/comments/giscus.html` | 7.6.0 | CLAUDE.md §8 kural 7'nin önceden öngördüğü bug gerçek çıktı — kök sebep `_config.yml`'de `comments.giscus.lang: en`'in i18n'den ÖNCE, tek global değer olarak hardcode edilmiş olmasıydı (ilk TR çevirisinde test edilip `data-lang: 'en'` render olduğu görüldü, config'e kadar iz sürüldü). `_config.yml`'deki değer kaldırıldı, bu dosyada fallback zinciri `page.lang`'ı (`lang.html`'in `_data/locales` dosya varlığı kontrolünü atlayarak — o kontrol Chirpy'nin kendi UI metinleriyle ilgili, giscus'un kendi (daha geniş) dil listesiyle alakasız) doğrudan okuyacak şekilde değiştirildi. | 2026-08-25 |
