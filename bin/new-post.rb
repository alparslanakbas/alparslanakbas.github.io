#!/usr/bin/env ruby
# frozen_string_literal: true

# Scaffolds a new post: the _posts/ file with a filled-in front matter
# skeleton (matching CLAUDE.md §5) plus its assets/img/posts/<slug>/
# folder. Doesn't touch i18n (lang/translation_key) — that's still
# postponed (Faz 3), see CLAUDE.md §0.
#
# Usage: ruby bin/new-post.rb <kebab-case-slug>
#   ruby bin/new-post.rb how-i-debugged-a-memory-leak

require "date"
require "fileutils"

KEBAB_CASE = /\A[a-z0-9]+(-[a-z0-9]+)*\z/.freeze
# Dir.pwd on purpose, not __dir__ — see the comment in
# tools/validate-front-matter.rb for why __dir__ is unreliable on a
# repo path with non-ASCII characters on this setup. Run this script
# from the repo root (ruby bin/new-post.rb <slug>), like every other
# script in bin/ and tools/.
REPO_ROOT = Dir.pwd

slug = ARGV[0]

if slug.nil? || slug.strip.empty?
  warn "Kullanım: ruby bin/new-post.rb <kebab-case-slug>"
  warn "Örnek:   ruby bin/new-post.rb how-i-debugged-a-memory-leak"
  exit 1
end

unless slug.match?(KEBAB_CASE)
  warn "❌ \"#{slug}\" lowercase-kebab-case değil (sadece a-z, 0-9 ve tire)."
  exit 1
end

today = Date.today
post_path = File.join(REPO_ROOT, "_posts", "#{today}-#{slug}.md")
img_dir = File.join(REPO_ROOT, "assets", "img", "posts", slug)

if File.exist?(post_path)
  warn "❌ #{post_path} zaten var."
  exit 1
end

front_matter = <<~MARKDOWN
  ---
  title: "TODO — 60 karakteri geçme"
  description: "TODO — 120-160 karakter, arama sonucunda görünecek özet."
  date: #{today} #{Time.now.strftime("%H:%M")} +0300
  categories: [TODO_PARENT, TODO_CHILD]
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
    Hatırlatmalar (CLAUDE.md §5-§7):
    - categories: en fazla 2 seviye, whitelist'ten (CLAUDE.md §6 kategori ağacı)
    - tags: 3-6 adet, lowercase-kebab-case, "blog"/"tutorial" YASAK
    - kod bloklarına dil etiketi zorunlu: ```csharp, ```bash, ```json ...
    - iç linkler göreli olmalı ([metin](/posts/slug/)), mutlak URL YASAK
    - en az 2 iç link (biri seri/pillar sayfasına)
    - kapak görseli önce assets/img/posts/#{slug}/ klasörüne WebP olarak eklenmeli
    - bitmeden önce: ruby tools/validate-front-matter.rb
  -->
MARKDOWN

File.write(post_path, front_matter)
FileUtils.mkdir_p(img_dir)
File.write(File.join(img_dir, ".gitkeep"), "") if Dir.empty?(img_dir)

puts "✅ Oluşturuldu:"
puts "   #{post_path.sub("#{REPO_ROOT}/", "")}"
puts "   #{img_dir.sub("#{REPO_ROOT}/", "")}/"
puts
puts "Sıradaki adımlar:"
puts "  1. Kapak görselini #{img_dir.sub("#{REPO_ROOT}/", "")}/cover.webp olarak ekle."
puts "  2. Front matter'daki TODO'ları doldur."
puts "  3. Bitince: ruby tools/validate-front-matter.rb"
