---
description: How env vars and secrets are organized — .env / .env.example pattern, per-environment isolation, deploy-target vs app-runtime
---

# Secrets and Environment Variables

## The pattern

- `.env` — actual values. **Gitignored.** Lives on developer laptops and
  deploy targets only.
- `.env.example` — every env var the project reads, with placeholder values
  and "where to get this token" pointers. **Committed.** This is the
  authoritative inventory.
- Code never hardcodes a secret. All secrets via env vars.

## App-runtime vs. deploy-target secrets

| Type | Lives in | Examples |
|---|---|---|
| App-runtime (read at runtime by the application) | `.env` locally, the deploy target's env-var UI in prod | `ANTHROPIC_API_KEY`, `DATABASE_URL`, `POSTMARK_API_TOKEN`, `SECRET_KEY` |
| Deploy-target tokens (used by CI / deploy tooling, not by the app) | CI/CD secret store (GitHub Actions secrets) + individual cli configs | `RAILWAY_TOKEN`, `CLOUDFLARE_API_TOKEN`, `GITHUB_TOKEN` (PAT) |

Deploy-target tokens do **not** belong in `.env.example`. They live in the
CI/CD platform's secret manager and on individual contributors' machines.

## Per-environment isolation

| Variable | Must differ per env? | Why |
|---|---|---|
| `SECRET_KEY` (app-internal signing) | ✅ Yes | Compromise of dev should not affect prod |
| `TELEGRAM_ADMIN_CHAT_ID` | ✅ Yes | Dev noise must not pollute prod admin alerts |
| `DATABASE_URL`, `REDIS_URL` | ✅ Yes | Hard rule — prod data must not be reachable from dev |
| `ANTHROPIC_API_KEY`, `POSTMARK_API_TOKEN`, etc. | ⚠️ Often shared | Separate keys per env is safer; sharing is OK for low-risk APIs but document the choice |
| `SENTRY_DSN` | ⚠️ Usually different | One Sentry project per env keeps releases cleanly grouped |

## When code adds an env var reference

**Rule:** if you add `os.getenv("FOO")` (or equivalent) anywhere in code,
add a placeholder `FOO=` to `.env.example` in the same change.

Enforced by [`.claude/hooks/sync-env-example.sh`](../hooks/sync-env-example.sh)
— a PostToolUse hook that scans touched files for env var references and
exits non-zero with a list of any keys missing from `.env.example`.

Each placeholder line in `.env.example` should include a comment that
explains the variable:

```bash
# FOO — what it controls. Get it from <vendor>.com → <where in their UI>.
# Empty → <fallback behavior, e.g., log-only mode>
FOO=
```

The comment saves the "what is this token even for" hunt 6 months from now.

## Claude Code itself needs no project tokens

Claude Code uses your personal Anthropic auth from `~/.claude/`. The
`ANTHROPIC_API_KEY` in `.env` is for the **application** that consumes the
Claude API (if any), not for Claude Code.

## Secret hygiene

- `.env*` files in `.gitignore` (template ships with this).
- `*.key`, `*.pem`, `*.crt` files in `.gitignore` (template ships with this).
- Bcrypt for password hashing (cost 12 minimum).
- UUID v4 for opaque tokens (API keys, session IDs).
- Rotate any secret leaked to git history **immediately** — `git
  filter-branch` doesn't help; the secret is compromised the moment it
  lands on GitHub.

## Bypassing the env-check hook

| Var | Effect |
|---|---|
| `CLAUDE_SKIP_ENV_CHECK=1` | Disable the hook entirely this session |
| `CLAUDE_ENV_IGNORE=KEY1,KEY2,...` | Extend the platform-injected ignore list (RAILWAY_*, CI, NODE_ENV, etc. are already ignored by default) |
| `CLAUDE_ENV_EXAMPLE_PATH=path/to/.env.example` | Point at a non-root example file |

Use bypasses sparingly. The right move on a flagged var is usually to add
it to `.env.example` with a one-line comment.
