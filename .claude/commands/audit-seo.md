---
description: Review a post (or all posts) against CLAUDE.md's SEO rules for things the automated validator can't check
argument-hint: "[post slug or filename, or 'all']"
---

`ruby tools/validate-front-matter.rb` already enforces the mechanical
parts of CLAUDE.md §5-§7 (lengths, whitelist membership, presence of
required fields). This command is for the parts that need actual
judgment, which that script deliberately doesn't attempt.

Target: `$ARGUMENTS` (a post slug/filename), or every file in
`_posts/` if empty or "all".

For each post in scope, read it and check:

- **Title and description actually match the content** — not just
  correct length, but would someone searching for this topic
  recognize this post from the title/description alone?
- **Internal links are genuinely relevant**, not just present. CLAUDE.md
  requires ≥2, but a link stuffed in just to hit the count is worse
  than no rule at all — check where they point and whether that's the
  right target (a category/series page, a genuinely related post).
- **Alt text describes the actual image**, not a generic label like
  "Desktop View" (the validator catches the literal Chirpy default,
  but a vague-but-technically-non-generic alt text like "screenshot"
  or "diagram" would slip through it).
- **Heading structure makes sense** — logical H2/H3 nesting, no
  heading skips, no bolded pseudo-headings that should be real
  headings (see the `MD036` fixes in the markdownlint PR for what that
  looked like the last time this repo had some).
- **Not thin content** — CLAUDE.md §7 says under 300 words shouldn't
  be its own page. Note the rough word count for anything that looks
  short.
- **Code blocks have a language tag** (also covered by markdownlint,
  but re-check for hand-obvious cases like a `bash` snippet mislabeled
  `text`).

Report findings per post, most significant first. Don't rewrite
anything without being asked — this is a review, not an edit pass.
