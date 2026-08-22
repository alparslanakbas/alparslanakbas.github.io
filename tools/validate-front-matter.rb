#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates every post in _posts/ against the front matter contract in
# CLAUDE.md §5-§7. Pure Ruby stdlib only (YAML, no bundler needed) so it
# can run as a fast, dependency-free CI step before the full Jekyll build.
#
# Usage: ruby tools/validate-front-matter.rb

require "yaml"
require "date"

POSTS_DIR = File.join(__dir__, "..", "_posts")

CATEGORY_TREE = {
  ".NET" => ["ASP.NET Core", "Entity Framework", "C# Language", "Performance"],
  "Data" => ["Redis", "SQL", "Caching"],
  "DevOps" => ["Docker", "CI/CD", "GitHub Actions"],
  "Architecture" => ["Patterns", "Microservices"],
  "Meta" => ["Blogging"]
}.freeze

BANNED_TAGS = %w[blog tutorial].freeze
KEBAB_CASE = /\A[a-z0-9]+(-[a-z0-9]+)*\z/.freeze
GENERIC_ALT_PATTERNS = [/\Adesktop view\z/i].freeze

errors = Hash.new { |h, k| h[k] = [] }

def front_matter_and_body(path)
  content = File.read(path, encoding: "utf-8")
  return [nil, nil] unless content.start_with?("---")

  parts = content.split(/^---\s*$/, 3)
  # parts = ["", front_matter_yaml, body]
  return [nil, nil] if parts.length < 3

  [YAML.safe_load(parts[1], permitted_classes: [Date, Time]), parts[2]]
end

Dir.glob(File.join(POSTS_DIR, "*.md")).sort.each do |path|
  filename = File.basename(path)
  fm, body = front_matter_and_body(path)

  if fm.nil?
    errors[filename] << "front matter bulunamadı veya YAML parse edilemedi"
    next
  end

  # --- title ---
  title = fm["title"]
  if title.nil? || title.to_s.strip.empty?
    errors[filename] << "title eksik"
  elsif title.to_s.length > 60
    errors[filename] << "title #{title.to_s.length} karakter (limit: 60)"
  end

  # --- description ---
  desc = fm["description"]
  if desc.nil? || desc.to_s.strip.empty?
    errors[filename] << "description eksik"
  elsif !(120..160).cover?(desc.to_s.length)
    errors[filename] << "description #{desc.to_s.length} karakter (aralık: 120-160)"
  end

  # --- date vs filename ---
  date_field = fm["date"]
  if date_field.nil?
    errors[filename] << "date eksik"
  else
    fm_date = date_field.is_a?(String) ? DateTime.parse(date_field) : date_field
    file_date_str = filename[0, 10]
    begin
      file_date = Date.parse(file_date_str)
      if fm_date.to_date != file_date
        errors[filename] << "dosya adındaki tarih (#{file_date}) ile front matter date (#{fm_date.to_date}) uyuşmuyor"
      end
    rescue ArgumentError
      errors[filename] << "dosya adı geçerli bir YYYY-MM-DD ile başlamıyor"
    end
  end

  # --- categories ---
  categories = fm["categories"]
  if categories.nil? || !categories.is_a?(Array) || categories.empty?
    errors[filename] << "categories eksik veya boş"
  elsif categories.length > 2
    errors[filename] << "categories #{categories.length} seviye (max 2)"
  else
    parent = categories[0]
    unless CATEGORY_TREE.key?(parent)
      errors[filename] << "categories[0] (\"#{parent}\") whitelist'te yok"
    end
    if categories.length == 2
      child = categories[1]
      allowed_children = CATEGORY_TREE[parent] || []
      unless allowed_children.include?(child)
        errors[filename] << "categories[1] (\"#{child}\") \"#{parent}\" altında whitelist'te yok"
      end
    end
  end

  # --- tags ---
  tags = fm["tags"]
  if tags.nil? || !tags.is_a?(Array)
    errors[filename] << "tags eksik"
  else
    unless (3..6).cover?(tags.length)
      errors[filename] << "tags #{tags.length} adet (aralık: 3-6)"
    end
    tags.each do |tag|
      tag_str = tag.to_s
      if BANNED_TAGS.include?(tag_str.downcase)
        errors[filename] << "tag \"#{tag_str}\" yasaklı (bkz. CLAUDE.md §6)"
      end
      unless tag_str.match?(KEBAB_CASE)
        errors[filename] << "tag \"#{tag_str}\" lowercase-kebab-case değil"
      end
    end
  end

  # --- image ---
  image = fm["image"]
  if image.nil? || !image.is_a?(Hash)
    errors[filename] << "image bloğu eksik"
  else
    img_path = image["path"]
    if img_path.nil? || !img_path.to_s.start_with?("/assets/img/posts/")
      errors[filename] << "image.path eksik veya /assets/img/posts/ ile başlamıyor"
    end
    alt = image["alt"]
    if alt.nil? || alt.to_s.strip.empty?
      errors[filename] << "image.alt eksik"
    elsif GENERIC_ALT_PATTERNS.any? { |pat| alt.to_s.match?(pat) }
      errors[filename] << "image.alt jenerik (\"#{alt}\") — gerçek açıklama yazılmalı"
    end
    lqip = image["lqip"]
    if lqip && !lqip.to_s.start_with?("data:image")
      errors[filename] << "image.lqip \"data:image\" ile başlamıyor"
    end
  end

  # --- body checks ---
  if body
    # Only flag actual links TO the blog's own domain (]( https://alparslanakbas.github.io...).
    # A prose mention or a github.com/alparslanakbas/alparslanakbas.github.io repo link is fine.
    if body.match?(%r{\]\(https?://alparslanakbas\.github\.io})
      errors[filename] << "gövdede mutlak self-domain URL var (bkz. CLAUDE.md §5 — iç linkler göreli olmalı)"
    end

    # Bare ``` fences (no language tag), ignoring the closing fence of a pair.
    fences = body.scan(/^```(\S*)/m).flatten
    fences.each_slice(2) do |open_lang, _close|
      next if open_lang.nil?

      if open_lang.strip.empty?
        errors[filename] << "dil etiketsiz kod bloğu var (``` yerine ```csharp gibi bir etiket gerekli)"
      end
    end

    internal_links = body.scan(%r{\]\(/[^)]+\)}).length + body.scan(/\{%\s*post_url/).length
    if internal_links < 2
      errors[filename] << "en az 2 iç link gerekli, #{internal_links} bulundu"
    end
  end
end

if errors.empty?
  puts "✅ Tüm yazılar front matter sözleşmesine uyuyor (#{Dir.glob(File.join(POSTS_DIR, '*.md')).length} yazı kontrol edildi)."
  exit 0
end

puts "❌ Front matter doğrulaması başarısız:\n\n"
errors.each do |filename, msgs|
  puts filename
  msgs.each { |m| puts "  - #{m}" }
  puts
end
puts "#{errors.length} dosyada sorun bulundu."
exit 1
