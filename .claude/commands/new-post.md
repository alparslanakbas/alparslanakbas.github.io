---
description: Scaffold a new blog post and help fill it in
argument-hint: <kebab-case-slug> [what the post is about]
---

Scaffold a new post for this blog.

1. Take the slug from the first word of `$ARGUMENTS` (kebab-case). If
   there's no slug, ask for one before doing anything else — don't
   guess a slug from a topic description.
2. Run `ruby bin/new-post.rb <slug>` from the repo root.
3. If the rest of `$ARGUMENTS` describes what the post should cover,
   open the newly created file and fill in the TODOs (title,
   description, categories/tags from CLAUDE.md §6's whitelist, a
   first draft of the body) based on that description. If there's no
   topic description, just report the scaffolded file paths and stop
   — don't invent post content nobody asked for.
4. Remind whoever's writing it: the cover image at
   `assets/img/posts/<slug>/cover.webp` still needs to be added by
   hand (this command doesn't generate images), and to run
   `ruby tools/validate-front-matter.rb` before committing.
