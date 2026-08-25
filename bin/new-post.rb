#!/usr/bin/env ruby
# frozen_string_literal: true

# Scaffolds a new post: the _posts/en/ or _tr_posts/ file with a filled-in
# front matter skeleton (matching CLAUDE.md §5/§8) plus its
# assets/img/posts/<slug>/ folder (shared between an EN post and its TR
# translation, if any - the image is the same file).
#
# Usage: ruby bin/new-post.rb <en|tr> <kebab-case-slug>
#   ruby bin/new-post.rb en how-i-debugged-a-memory-leak
#   ruby bin/new-post.rb tr how-i-debugged-a-memory-leak

require "date"
require "fileutils"

KEBAB_CASE = /\A[a-z0-9]+(-[a-z0-9]+)*\z/.freeze
LANGS = %w[en tr].freeze
# Dir.pwd on purpose, not __dir__ — see the comment in
# tools/validate-front-matter.rb for why __dir__ is unreliable on a
# repo path with non-ASCII characters on this setup. Run this script
# from the repo root (ruby bin/new-post.rb <lang> <slug>), like every
# other script in bin/ and tools/.
REPO_ROOT = Dir.pwd

lang = ARGV[0]
slug = ARGV[1]

if lang.nil? || slug.nil? || slug.strip.empty?
  warn "Kullanım: ruby bin/new-post.rb <en|tr> <kebab-case-slug>"
  warn "Örnek:   ruby bin/new-post.rb en how-i-debugged-a-memory-leak"
  exit 1
end

unless LANGS.include?(lang)
  warn "❌ Dil \"#{lang}\" değil, \"en\" veya \"tr\" olmalı."
  exit 1
end

unless slug.match?(KEBAB_CASE)
  warn "❌ \"#{slug}\" lowercase-kebab-case değil (sadece a-z, 0-9 ve tire)."
  exit 1
end

today = Date.today
# EN posts are Jekyll's built-in `posts` collection (_posts/en/); TR
# posts are their own `tr_posts` collection (_tr_posts/, no language
# subfolder of its own) - see _config.yml's `collections:` block.
posts_dir = lang == "tr" ? "_tr_posts" : File.join("_posts", "en")
post_path = File.join(REPO_ROOT, posts_dir, "#{today}-#{slug}.md")
img_dir = File.join(REPO_ROOT, "assets", "img", "posts", slug)

if File.exist?(post_path)
  warn "❌ #{post_path} zaten var."
  exit 1
end

title_hint = lang == "tr" ? "TODO — 60 karakteri geçme, Türkçe" : "TODO — 60 karakteri geçme"
desc_hint = lang == "tr" ? "TODO — 120-160 karakter, Türkçe özet." : "TODO — 120-160 karakter, arama sonucunda görünecek özet."
category_hint = lang == "tr" ? "TODO_ÜST_KATEGORİ, TODO_ALT_KATEGORİ" : "TODO_PARENT, TODO_CHILD"

front_matter = <<~MARKDOWN
  ---
  title: "#{title_hint}"
  description: "#{desc_hint}"
  date: #{today} #{Time.now.strftime("%H:%M")} +0300
  # translation_key aynı yazının EN/TR çiftini birbirine bağlıyor (hreflang
  # bunun üzerinden üretiliyor) — çift varsa iki dosyada da AYNI değer,
  # yoksa alanı tamamen sil (CLAUDE.md §8 kural 5: çeviri zorunlu değil).
  translation_key: #{slug}
  categories: [#{category_hint}]
  tags: [TODO_TAG_1, TODO_TAG_2, TODO_TAG_3]
  image:
    path: /assets/img/posts/#{slug}/cover.webp
    alt: "TODO — görselin ne anlattığını söyleyen gerçek metin"
    # lqip: node scratchpad'deki gen-lqip.js benzeri bir script ile kapak
    #       görseli hazır olunca üretilip buraya eklenmeli (opsiyonel).
  ---

  ## TODO

  Yazının gövdesi burada.

  <!--
    Hatırlatmalar (CLAUDE.md §5-§8):
    - categories: en fazla 2 seviye, whitelist'ten (CLAUDE.md §6 kategori ağacı)
    - tags: 3-6 adet, lowercase-kebab-case, "blog"/"tutorial" YASAK
    - kod bloklarına dil etiketi zorunlu: ```csharp, ```bash, ```json ...
    - iç linkler göreli olmalı ([metin](/posts/slug/)), mutlak URL YASAK
    - en az 2 iç link (biri seri/pillar sayfasına)
    - kapak görseli önce assets/img/posts/#{slug}/ klasörüne WebP olarak eklenmeli
      (EN/TR çiftinde İKİSİ de aynı görseli paylaşır, ayrı ayrı eklenmez)
    - çeviri kelimesi kelimesine değil, doğal/akıcı olmalı — robotik çeviri
      okuyucu güvenini zedeler (bkz. CLAUDE.md §0)
    - bitmeden önce: ruby tools/validate-front-matter.rb
  -->
MARKDOWN

FileUtils.mkdir_p(File.dirname(post_path))
File.write(post_path, front_matter)
FileUtils.mkdir_p(img_dir)
File.write(File.join(img_dir, ".gitkeep"), "") if Dir.empty?(img_dir)

puts "✅ Oluşturuldu:"
puts "   #{post_path.sub("#{REPO_ROOT}/", "")}"
puts "   #{img_dir.sub("#{REPO_ROOT}/", "")}/"
puts
puts "Sıradaki adımlar:"
puts "  1. Kapak görselini #{img_dir.sub("#{REPO_ROOT}/", "")}/cover.webp olarak ekle."
puts "  2. Front matter'daki TODO'ları doldur (çift dilse translation_key'i koru, değilse sil)."
puts "  3. Bitince: ruby tools/validate-front-matter.rb"
