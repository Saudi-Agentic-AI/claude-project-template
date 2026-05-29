# Project Context for Claude

> This file is loaded automatically at the start of every Claude Code session.
> Keep it concise — link out to `.claude/rules/*.md` for detailed conventions.

## Overview

<!-- One paragraph: what does this project do, who is it for, what's the current focus -->

PROJECT_NAME is a TODO.

## Tech Stack

Pin actual choices here. See `.claude/rules/stack-defaults.md` for the
defaults this template assumes and when to deviate.

- **Language**: TODO (default: Python 3.11+)
- **Framework**: TODO (default: FastAPI async)
- **Database**: TODO (default: PostgreSQL via Railway plugin)
- **Cache**: TODO (default: Redis via Railway plugin)
- **Backend hosting**: TODO (default: Railway)
- **Static hosting + CDN**: TODO (default: Cloudflare Pages)
- **Transactional email**: TODO (default: Postmark)
- **AI**: TODO (default: Anthropic Haiku 4.5 + OpenRouter fallback)
- **Notifications**: TODO (default: Telegram bot)
- **Error tracking**: TODO (default: Sentry)
- **Logging**: TODO (default: structlog JSON + request_id middleware)
- **CI/CD**: TODO (default: GitHub Actions)
- **Testing**: TODO (default: pytest + pytest-asyncio + fakeredis)

## Architecture

<!-- High-level: layered? hexagonal? monorepo? service boundaries? -->

TODO.

## Build, Test, Run

```bash
# Install dependencies
TODO

# Run the dev server
TODO

# Run tests
TODO

# Lint and format
TODO
```

## Conventions

Detailed conventions live in modular rule files. Read these when relevant.

**Critical (read every session):**

- `.claude/rules/no-unsolicited-md.md` — never create `.md` files without an explicit ask
- `.claude/rules/project-tracker-discipline.md` — update `project_tracker.md` at session end
- `.claude/rules/timestamp-discipline.md` — `[YYYY-MM-DD]` commit prefix, dated migrations, ISO logs
- `.claude/rules/coding-discipline.md` — no fake data, no stdout logging, money is Decimal, async is contagious
- `.claude/rules/secrets-and-env.md` — `.env` / `.env.example` pattern, app-runtime vs deploy-target secrets
- `.claude/rules/mvp-boundaries.md` — the "What NOT to Build" list — fill in per project

**Reference (read when relevant):**

- `.claude/rules/stack-defaults.md` — default vendor / library choices + when to deviate
- `.claude/rules/psd-maintenance.md` — when and how to maintain `PSD.md` (the long-form spec)
- `.claude/rules/code-style.md` — formatting, naming, structure (language-specific)
- `.claude/rules/testing.md` — what to test, how to test, coverage expectations
- `.claude/rules/git-conventions.md` — branch naming, commit messages, PR flow

## Important Notes

<!-- Any project-specific quirks Claude should know upfront:
     - Non-obvious dependencies
     - Things that look broken but aren't
     - Decisions Claude should NOT relitigate
-->

TODO.

## Quick Pointers

- Entry point: `TODO`
- Configuration: `TODO`
- Secrets: never commit; use `.env` (gitignored)
