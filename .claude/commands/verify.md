---
description: Run the full local pre-commit check (front matter, markdown lint, build, htmlproofer)
---

Run this repo's standard pre-commit verification, in order, and stop
at the first failure rather than pushing through:

1. `ruby tools/validate-front-matter.rb` — CLAUDE.md §5-§7's contract
   for every post (title/description length, category+tag whitelist,
   image block, no absolute self-domain links, code fences have a
   language tag, minimum internal link count).
2. `npm run lint:md` — markdown style (`.markdownlint-cli2.jsonc`).
   Run `npx markdownlint-cli2 --fix` first if there's anything
   mechanical to clean up, then re-run to see what's left.
3. `bash tools/test.sh` — the same Jekyll build + htmlproofer
   (internal links/images/scripts) that CI runs before a deploy.

If everything passes, say so plainly. If something fails, fix it (or
explain clearly why it's a false positive worth ignoring, the way
past sessions have documented in `.github/workflows/
check-external-links.yml`) rather than just reporting the failure and
stopping.
