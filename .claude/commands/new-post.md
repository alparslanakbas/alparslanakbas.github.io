---
description: Scaffold a new blog post and help fill it in
argument-hint: <en|tr> <kebab-case-slug> [what the post is about]
---

Scaffold a new post for this blog.

1. Take the language (`en` or `tr`) as the first word of `$ARGUMENTS`
   and the slug as the second (kebab-case). If either is missing, ask
   before doing anything else — don't guess a slug from a topic
   description, and don't assume a language.
2. Run `ruby bin/new-post.rb <lang> <slug>` from the repo root.
3. If the rest of `$ARGUMENTS` describes what the post should cover,
   open the newly created file and fill in the TODOs (title,
   description, categories/tags from CLAUDE.md §6's whitelist, a
   first draft of the body) based on that description. If there's no
   topic description, just report the scaffolded file paths and stop
   — don't invent post content nobody asked for. If this is a `tr`
   post translating an existing `en` one, write natural, idiomatic
   Turkish - not a literal word-for-word translation - and set
   `translation_key` to match the English original's value.
4. Remind whoever's writing it: the cover image at
   `assets/img/posts/<slug>/cover.webp` still needs to be added by
   hand (this command doesn't generate images, and an EN/TR pair
   shares the same one - don't add it twice), and to run
   `ruby tools/validate-front-matter.rb` before committing.
