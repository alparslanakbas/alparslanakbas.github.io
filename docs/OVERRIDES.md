# Tema override kayıtları

`jekyll-theme-chirpy` bir gem olarak kullanılıyor (bkz. `CLAUDE.md` §4). Gem içindeki bir dosya
bu repoda override edildiğinde buraya satır eklenir. Format:

| Dosya yolu | Kaynak tema sürümü | Neden | Son senkron tarihi |
|---|---|---|---|
| `_layouts/post.html` | 7.6.0 | `tail_includes` listesine `series-nav` (yeni `_includes/series-nav.html`, `page.series` set olan yazılarda "bu seride: ..." kutusu gösteriyor) ve `author-card` (yeni `_includes/author-card.html`, her yazının altında foto+bio+takip linkleri kartı) eklemek için | 2026-08-24 |
| `_includes/metadata-hook.html` | 7.6.0 | Gem'deki hâli tek satırlık boş bir placeholder yorum ("A placeholder to allow defining custom metadata") — teknik olarak override ama CLAUDE.md §4'ün kendi tercih sıralamasında en ucuz/sancısız seçenek olarak zaten öngörülmüştü. EN/TR yazı çiftleri için `hreflang`/`x-default` linkleri üretiyor (`page.translation_key` set değilse tamamen no-op). | 2026-08-25 |
