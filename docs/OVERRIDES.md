# Tema override kayıtları

`jekyll-theme-chirpy` bir gem olarak kullanılıyor (bkz. `CLAUDE.md` §4). Gem içindeki bir dosya
bu repoda override edildiğinde buraya satır eklenir. Format:

| Dosya yolu | Kaynak tema sürümü | Neden | Son senkron tarihi |
|---|---|---|---|
| `_layouts/post.html` | 7.6.0 | `tail_includes` listesine `series-nav` (yeni `_includes/series-nav.html`, `page.series` set olan yazılarda "bu seride: ..." kutusu gösteriyor) ve `author-card` (yeni `_includes/author-card.html`, her yazının altında foto+bio+takip linkleri kartı) eklemek için | 2026-08-24 |
