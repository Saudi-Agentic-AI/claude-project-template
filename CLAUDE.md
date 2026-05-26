# Project Context for Claude

> This file is loaded automatically at the start of every Claude Code session.
> Keep it concise — link out to `.claude/rules/*.md` for detailed conventions.

## Overview

<!-- One paragraph: what does this project do, who is it for, what's the current focus -->

PROJECT_NAME is a TODO.

## Tech Stack

- **Language**: TODO (e.g., Python 3.12)
- **Framework**: TODO (e.g., FastAPI)
- **Database**: TODO (e.g., PostgreSQL 16)
- **Deployment**: TODO (e.g., Railway, Docker)
- **Testing**: TODO (e.g., pytest, pytest-asyncio)

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

Detailed conventions live in modular rule files. Read these when relevant:

- `.claude/rules/code-style.md` — formatting, naming, structure
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
