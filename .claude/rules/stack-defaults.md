---
description: Default vendor and library choices for new projects. Consult before adding a dependency or picking a vendor.
---

# Stack Defaults

When picking a dependency or vendor for a new concern, **default to the options below**. Deviate only with a documented reason in `project_tracker.md`'s Decisions Log.

Skills referenced here live in `.claude/skills/<name>/` and load on demand when actively working with that vendor.

## Quick reference

| Concern | Default | Skill | Deviate when |
|---|---|---|---|
| **Backend language + framework** | Python 3.11+ with FastAPI (async) | — | CPU-bound service (Go), edge runtime (TS on Cloudflare Workers), heavy data pipelines (PySpark/Dask) |
| **ORM + migrations** | SQLAlchemy async + Alembic | — | One-off script (raw SQL or a query builder); edge runtime (use platform-native) |
| **Backend hosting** | Railway | `railway-new` | Need multi-region or per-request <1¢ → Fly / Cloudflare Workers |
| **Database** | PostgreSQL (Railway plugin) | `supabase` for managed BaaS | OLAP scale (>1 TB analytical) → BigQuery / ClickHouse |
| **Cache / counters / rate limits** | Redis (Railway plugin) | — | In-process only (Python `cachetools`); globally-distributed → Cloudflare KV / Workers Cache |
| **Static site + CDN** | Cloudflare Pages | `cloudflare` | Already in another CDN ecosystem (Vercel, AWS CloudFront) |
| **DNS** | Cloudflare | `cloudflare` | Locked to a competing registrar |
| **Transactional email** | Postmark | `postmark-automation` | Bulk marketing volume → Mailgun / SendGrid (segregate transactional from marketing) |
| **AI primary** | Anthropic API (Haiku 4.5 default; Sonnet 4.6 for reasoning; Opus for hardest cases) | — | — |
| **AI cost-sensitive / fallback** | OpenRouter (`deepseek-chat:nitro` ~80% cheaper) | `openrouter-automation` | Need a model OpenRouter doesn't carry |
| **Operator + dev-user notifications** | Telegram bot (custom integration) | `telegram-bot` | Audience prefers another channel (Slack, Discord) |
| **Consumer notifications, GCC / global-South** | WhatsApp via [Kapso.ai](https://kapso.ai) wrapper or Rube MCP (Composio) | `whatsapp-automation` | Audience is not WhatsApp-native |
| **Auth (browser sessions)** | In-house JWT (~30 min) + DB-stored refresh token (~30 day, single-use, rotated) | — | Multi-tenant SSO + SCIM requirement → Clerk / Auth0 / WorkOS |
| **Auth (programmatic / SDK)** | UUID v4 API key in `X-API-Key` header | — | Need OAuth audience → standard OAuth2 server |
| **Password hashing** | bcrypt (cost 12) | — | Regulator requires Argon2 |
| **Error tracking** | Sentry (no-op when DSN empty; 10% trace sample) | — | Self-hosted requirement → GlitchTip |
| **Logging** | `structlog` JSON output + `request_id` middleware | — | Non-Python: language-native structured logger (`pino`, `zap`, `slog`) |
| **HTTP client** | `httpx` async (Python) | — | Sync-only context → `requests`; high-throughput → `aiohttp` |
| **Payments** | Moyasar (SAR / GCC) or Stripe (global) | — | Crypto-only audience → CoinPayments |
| **CI/CD** | GitHub Actions (required-check on protected branches) | — | Repo on GitLab / Bitbucket → native CI |
| **Branch model** | `dev` → `main`, never direct to `main` | — | Solo experimental repo with zero users → trunk-based OK |
| **Background tasks (single-process)** | `asyncio.create_task` in app lifespan | — | Cross-process coordination, retries, or schedule complexity → Celery / RQ / Temporal |
| **Frontend (small SPA / dashboard)** | Single-file HTML + vanilla JS + CSS variables, no build step | — | Genuine SPA complexity (10+ views, complex state) → SvelteKit / Next.js |
| **i18n** | Per-locale HTML mirrors + `hreflang` + `og:locale` | — | Framework with first-class i18n → use it |
| **Observability dashboards** | Grafana | `grafana-dashboard` | Sentry covers needs alone |
| **Secrets** | Env vars + `.env` (gitignored) + `.env.example` checked in | — | Team > 5 → dedicated secrets manager (1Password / Doppler / Vault) |

## Why these defaults (notes per category)

### Python + FastAPI

- OpenAPI auto-generation; Pydantic v2 validation; async-native; fast enough for everything we ship.
- Type hints + `mypy --strict` give a safety floor without language-level enforcement overhead.
- ML / data ecosystem is non-negotiable for any project that might touch analytics or models.

Reach for Go on dedicated CPU-bound services (matching engines, custom proxies). Reach for TypeScript when the runtime requires it (Cloudflare Workers, browser).

### Railway + Cloudflare Pages — stateful vs. static split

Stateful services (API, DB, Redis) on Railway: managed plugins, per-environment isolation, auto-deploy from branch. Static files on Cloudflare Pages: free, edge-cached, preview-per-branch, faster than Railway's static service.

This split is a hard-won pattern. Do **not** bundle the static site under Railway just for tidiness — Pages-per-branch + Railway-per-env is the right shape.

Per-environment isolation: every project gets a `prod` and `dev` environment from day one. Two Pages projects (one per branch, sharing the repo) > one project with branch-routing inside.

### Postgres + Redis (Railway plugins)

- Postgres: transactional integrity, JSONB for flexible schema needs without giving up transactions, mature tooling.
- Redis: atomic INCR/DECR for counters + rate limiting; sub-ms latency; TTL-based expiry.
- Plugins (vs. self-hosted): per-environment isolation comes free; backups automatic; no IAM/security-group rabbit holes.

### Postmark for transactional email

- High deliverability, especially for region-specific senders.
- Webhook for bounce + spam-complaint events with HMAC verification → auto-suppress undeliverable addresses on day one.
- Per-message logging in their dashboard makes debugging instant.
- Free tier covers low-volume transactional traffic.

**Pattern**: implement bounce auto-suppression from the first email. A rare-but-persistent bounce path can destroy domain reputation in a single bad-luck week.

### In-house JWT — not a hosted IdP

Identity is a forever dependency. Owning the issuer keeps the surface small. A hosted IdP (Clerk, Auth0, Firebase) introduces a multi-week migration tail every time you outgrow it.

**Hybrid pattern**: JWT (~30 min, localStorage or httpOnly cookie) for browser sessions; UUID API key for SDK / unattended scripts. Both interchangeable on every authed endpoint. Library: `python-jose` or `pyjwt`.

Reach for a hosted IdP **only** when the requirement is multi-tenant SSO + SCIM provisioning, and the migration cost is justified.

### Telegram for notifications

- Free, instant, no friction. Bot setup in 5 minutes.
- Works for both operator alerts (admin chat ID) and user notifications (linked via deep-link OTP).
- Pattern: `notify_admin(...)` is a no-op when `TELEGRAM_ADMIN_CHAT_ID` is empty, so the integration ships in place but per-env config keeps dev noise out of prod alerts.

### WhatsApp via Kapso.ai (when needed)

For GCC / global-South / consumer audiences where WhatsApp is the primary messenger.

- **Don't** integrate WhatsApp Business API directly — Facebook Business Manager, template approval, and ongoing compliance are too much overhead for a small project.
- **Do** wrap it via Kapso.ai (or similar) and mirror the Telegram link/unlink/notify pattern.
- Templates need pre-approval — keep a small set (5–10) and version them in the repo.

### structlog + Sentry — not a vendor APM

- structlog: JSON output, correlated via `request_id` middleware, ingestible by any aggregator.
- Sentry: stack traces, release tagging via commit SHA, 10% trace sampling for cost control, no-op when `SENTRY_DSN` is empty.
- Together: 90% of observability needs at $0 (Sentry free tier) or low fixed cost.

Datadog / New Relic are overkill for sub-$100/mo infra projects.

### GitHub Actions

- Free for public + small private repos.
- Native to GitHub branch protection — the `tests` check goes straight into required-checks.
- Matrix support for parallel test runs.
- No separate CI vendor relationship to manage.

## Anti-defaults — usually wrong, almost always no

These appear in every "what should we use?" conversation. The answer is almost always **no** for a small / solo / pre-PMF project:

- **AWS / GCP / Azure** — overkill at small scale, slow to set up, attracts incidental complexity. Railway covers compute + DB + Redis for <$50/mo with no IAM rabbit holes.
- **Kubernetes** — operational tax dwarfs the benefit until you actually need its primitives.
- **GraphQL as the first API** — REST + OpenAPI is enough. GraphQL pays off with 5+ frontend teams hitting one backend.
- **MongoDB / DynamoDB for transactional data** — Postgres + JSONB handles "flexible schema" without sacrificing transactions.
- **Microservices for an MVP** — one well-organized service ships faster and is easier to reason about. Split when a boundary actually hurts.
- **Custom CSS framework / design system** — Tailwind or plain CSS variables. No bespoke system until 10+ pages.
- **WebSocket for everything live** — REST polling at 1–5 s covers most "real-time" UIs. WebSocket only when polling is genuinely the bottleneck.
- **Celery / RQ / RabbitMQ for the first task queue** — `asyncio.create_task` in the app lifespan covers most cases. Reach for a real queue only when you need cross-process coordination or retry semantics asyncio doesn't give.
- **A new auth provider mid-project** — see "In-house JWT" above. Identity migrations are weeks of work; defer until the requirement forces it.

## How to use this rule

- **Starting a new project**: read top-to-bottom once. Copy the rows you'll actually use into the project's `CLAUDE.md` `Tech Stack` section so the picks are pinned and visible per session.
- **Adding a new dependency mid-project**: check this rule first. If you're deviating, write a Decisions Log entry explaining why.
- **Reviewing a PR that introduces a vendor**: if the vendor isn't in this table or in the project's pinned stack, ask the author for the Decisions Log entry.

## Keeping this rule current

When you adopt a new default across multiple projects, update this file. When you abandon one, mark it deprecated **in-line** — don't delete the row, because "why we moved off X" is the most valuable part for future-you. Example:

> **2026-04 → 2026-05: tried hosted IdP (Clerk).** Reverted to in-house JWT after migration complexity wasn't justified at low user count. Re-evaluation criteria: multi-tenant SSO + SCIM requirement.
