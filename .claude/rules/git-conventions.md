---
description: Branch naming, commit messages, and PR flow
---

# Git Conventions

## Branch naming

`<type>/<short-description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `hotfix`

Examples:
- `feat/portfolio-pnl-endpoint`
- `fix/order-quantity-rounding`
- `refactor/extract-market-data-client`

## Commit messages

Conventional Commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **Subject**: imperative mood, ≤72 chars, no trailing period
- **Body**: explain *why* and *what*, not *how*. Wrap at 72 chars.
- **Footer**: `BREAKING CHANGE:` notes, issue refs (`Closes #42`)

Good:
```
feat(orders): add idempotency key to order submission

Prevents duplicate orders when the client retries on network errors.
Idempotency key is hashed and stored for 24h.

Closes #142
```

Bad:
```
fixed stuff
```

## Pull requests

- One logical change per PR. If you're touching unrelated files, split it.
- PR description: what, why, how to test. Link the issue.
- Self-review the diff before requesting review. Catch your own debug prints.
- Squash-merge to main. Keep history readable.

## What Claude should NOT do without explicit instruction

- Force push to any branch (especially `main`/`master`)
- Rewrite published history (`rebase` on shared branches)
- Delete branches without checking they're merged
- Commit directly to `main`/`master`
