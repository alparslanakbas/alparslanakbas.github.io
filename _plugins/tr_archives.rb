# frozen_string_literal: true

# Generates Turkish equivalents of Chirpy's built-in category/tag/archive
# tabs, scoped to the tr_posts collection (see _config.yml's
# `collections:` block / docs/OVERRIDES.md for why Turkish posts live in
# their own collection rather than _posts/).
#
# jekyll-archives (the gem Chirpy uses for the English /categories/:name/
# and /tags/:name/ pages) is hardcoded to `site.posts` with no config
# option to point it at another collection - confirmed by reading
# lib/jekyll-archives.rb in the gem itself (`@posts = site.posts`). This
# reimplements the same category/tag grouping logic against
# site.tr_posts instead, since this repo's build (GitHub Actions +
# Bundler, not the restricted native GitHub Pages processor) allows
# custom plugins.
#
# Two things happen here:
#   1. Per-category and per-tag pages at /tr/categories/:slug/ and
#      /tr/tags/:slug/ - these reuse Chirpy's own `category`/`tag`
#      layouts UNCHANGED, since those only ever read `page.posts` /
#      `page.title` (verified: no site.categories/site.tags reference
#      in either layout), so a plain Page with the right data works.
#   2. The three TR tab INDEX pages (Kategoriler/Etiketler/Arşiv, see
#      _tabs/categories-tr.md etc.) get their listing data
#      (category_groups / tag_list / archive_posts) injected here,
#      pre-computed in Ruby rather than re-deriving `site.categories`-
#      shaped groupings in Liquid.

module TrArchives
  CATEGORIES_PERMALINK = "/tr/categories/%s/"
  TAGS_PERMALINK = "/tr/tags/%s/"

  # A minimal generator-created page, reusing an EXISTING Chirpy layout
  # (`category` or `tag`) by handing it the same `posts` / `title` data
  # jekyll-archives' own Archive page would.
  class ItemPage < Jekyll::PageWithoutAFile
    def initialize(site, layout, title, posts, permalink)
      super(site, site.source, "", "index.html")
      self.data.merge!(
        "layout" => layout,
        "title" => title,
        "lang" => "tr-TR",
        "posts" => posts,
        "permalink" => permalink
      )
      self.content = ""
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :low # run after tr_posts' `date`/front matter is fully loaded

    def generate(site)
      tr_posts = site.collections["tr_posts"]&.docs || []
      return if tr_posts.empty?

      sorted_posts = tr_posts.sort_by { |p| -p.date.to_i }

      by_tag = group_by_field(tr_posts, "tags")
      generate_tag_pages(site, by_tag)

      by_top_category, subcategories_by_top = group_categories(tr_posts)
      generate_category_pages(site, by_top_category, subcategories_by_top)

      inject_tab_data(site, sorted_posts, by_top_category, subcategories_by_top, by_tag)
    end

    private

    # {"Redis" => [doc, doc, ...], "Docker" => [...]}, from every value
    # in each doc's `field` front matter array (categories or tags).
    def group_by_field(docs, field)
      grouped = Hash.new { |h, k| h[k] = [] }
      docs.each do |doc|
        Array(doc.data[field]).each { |value| grouped[value] << doc }
      end
      grouped
    end

    # Mirrors categories.html's own two-level grouping: a post's FIRST
    # category is the top-level group, its SECOND (if any) is a
    # subcategory within that group.
    def group_categories(docs)
      top = Hash.new { |h, k| h[k] = [] }
      subs = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }

      docs.each do |doc|
        cats = Array(doc.data["categories"])
        next if cats.empty?

        top[cats[0]] << doc
        subs[cats[0]][cats[1]] << doc if cats[1]
      end

      [top, subs]
    end

    def generate_tag_pages(site, by_tag)
      by_tag.each do |name, posts|
        permalink = format(TAGS_PERMALINK, Jekyll::Utils.slugify(name))
        site.pages << ItemPage.new(site, "tag", name, posts.sort_by { |p| -p.date.to_i }, permalink)
      end
    end

    def generate_category_pages(site, by_top_category, subcategories_by_top)
      by_top_category.each_key do |name|
        all_posts = subcategories_by_top[name].values.flatten.concat(
          by_top_category[name].select { |d| Array(d.data["categories"]).size == 1 }
        )
        permalink = format(CATEGORIES_PERMALINK, Jekyll::Utils.slugify(name))
        site.pages << ItemPage.new(site, "category", name, all_posts.sort_by { |p| -p.date.to_i }, permalink)

        subcategories_by_top[name].each do |sub_name, sub_posts|
          sub_permalink = format(CATEGORIES_PERMALINK, Jekyll::Utils.slugify(sub_name))
          site.pages << ItemPage.new(site, "category", sub_name, sub_posts.sort_by { |p| -p.date.to_i }, sub_permalink)
        end
      end
    end

    # Finds the three static TR tab files (_tabs/categories-tr.md etc.,
    # identified by their own distinct `layout` value) and hands them
    # the pre-computed listing data their Liquid layout renders.
    def inject_tab_data(site, sorted_posts, by_top_category, subcategories_by_top, by_tag)
      tabs = site.collections["tabs"]&.docs || []

      categories_tab = tabs.find { |d| d.data["layout"] == "tr-categories" }
      if categories_tab
        categories_tab.data["category_groups"] = by_top_category.keys.sort.map do |name|
          subs = subcategories_by_top[name].keys.compact.sort.map do |sub_name|
            {
              "name" => sub_name,
              "url" => format(CATEGORIES_PERMALINK, Jekyll::Utils.slugify(sub_name)),
              "count" => subcategories_by_top[name][sub_name].size
            }
          end
          {
            "name" => name,
            "url" => format(CATEGORIES_PERMALINK, Jekyll::Utils.slugify(name)),
            "count" => by_top_category[name].size,
            "subcategories" => subs
          }
        end
      end

      tags_tab = tabs.find { |d| d.data["layout"] == "tr-tags" }
      if tags_tab
        tags_tab.data["tag_list"] = by_tag.keys.sort.map do |name|
          { "name" => name, "url" => format(TAGS_PERMALINK, Jekyll::Utils.slugify(name)), "count" => by_tag[name].size }
        end
      end

      archives_tab = tabs.find { |d| d.data["layout"] == "tr-archives" }
      archives_tab.data["archive_posts"] = sorted_posts if archives_tab
    end
  end
end
