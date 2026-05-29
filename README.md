# Claude Code Project Template

A production-ready `.claude/` scaffolding for new projects.
Everything Claude Code needs to be productive in a new repo on day one.

---

## Quick Start

**Option A — GitHub UI**: click the **"Use this template"** button at the top of the repo page, then **"Create a new repository"**.

**Option B — CLI** (recommended for daily use):

```bash
gh repo create Saudi-Agentic-AI/<new-project-name> \
   --template Saudi-Agentic-AI/claude-project-template \
   --private --clone

cd <new-project-name>
$EDITOR CLAUDE.md          # fill in project specifics (overview, tech stack, commands)
claude                     # start a Claude Code session
```

That's it. Claude Code will pick up `CLAUDE.md` and the `.claude/` config automatically.

---

## First-Session Setup Checklist

Work through this **before** asking Claude to build the first feature. The harness reads these files every session — wrong inputs lead to wrong outputs.

### 1. Pin the project identity — `CLAUDE.md`

Edit every `TODO` in [`CLAUDE.md`](CLAUDE.md):

- [ ] **Overview** — one paragraph: what, who, current focus
- [ ] **Tech Stack** — replace each `TODO`. Keep the `(default: X)` hint as a comment if you accept the default; otherwise replace with your choice plus a one-line rationale. The template's assumed defaults live in [`.claude/rules/stack-defaults.md`](.claude/rules/stack-defaults.md).
- [ ] **Architecture** — high-level shape (layered, hexagonal, monorepo, etc.)
- [ ] **Build, Test, Run** — the exact commands a fresh contributor would type
- [ ] **Important Notes** — non-obvious quirks Claude should not relitigate
- [ ] **Quick Pointers** — entry point file, config file, secret-handling reminder

### 2. Define what NOT to build — `.claude/rules/mvp-boundaries.md`

- [ ] Replace the example table in [`.claude/rules/mvp-boundaries.md`](.claude/rules/mvp-boundaries.md) with the real "out of scope" list for this project. Each row needs a *why* and a *revisit-when*. Without this, Claude will say yes to incremental scope creep.

### 3. Configure secrets — `.env`

- [ ] `cp .env.example .env`
- [ ] Open [`.env.example`](.env.example) (it's the inventory) and your `.env` (the values). Fill in the values for the services your project actually uses; **delete** sections for services you don't.
- [ ] Set deploy-target env vars in the host's UI (Railway dashboard, Cloudflare Pages env, etc.) — not in `.env`. See [`.claude/rules/secrets-and-env.md`](.claude/rules/secrets-and-env.md) for the app-runtime vs deploy-target distinction.
- [ ] Confirm `.env` is gitignored (template ships with this).

### 4. Choose your language tooling

If the project is **not** Python, edit or remove:

- [ ] [`.claude/rules/code-style.md`](.claude/rules/code-style.md) — currently Python-default; swap for your language's formatter / linter / type-checker
- [ ] [`.claude/hooks/format-python.sh`](.claude/hooks/format-python.sh) — replace with `format-<lang>.sh`, or remove the hook entry in [`.claude/settings.json`](.claude/settings.json)
- [ ] [`.claude/agents/test-writer.md`](.claude/agents/test-writer.md) — references `pytest` / `pytest --cov`; swap for your test runner
- [ ] [`.claude/settings.json`](.claude/settings.json) `permissions.allow` — currently whitelists `pytest`, `ruff`, `mypy`, `uv`; add `npm`, `go test`, `cargo`, etc. as relevant

### 5. Configure project-level env — `.claude/settings.json`

- [ ] Populate the `env` block with per-project overrides:
  - `CLAUDE_TIMEZONE` (default: local) — set if you want a specific TZ in tracker entries (`AST`, `UTC`, etc.)
  - `CLAUDE_MD_ALLOWLIST` (default: standard list) — extend if the project has additional `.md` files that should be allowed
  - `CLAUDE_SKIP_COMMIT_FORMAT=1` — only if this project uses plain Conventional Commits without the date prefix
  - `CLAUDE_ENV_IGNORE` — additional env vars the sync-env-example hook should not flag (platform-injected vars like `RAILWAY_*`, `CI`, `NODE_ENV` are already in the default ignore list)

### 6. Initialize the tracker

- [ ] On the first session that produces real work, run `/checkpoint`. That creates `project_tracker.md` with the standard header and the first checkpoint entry.

### 7. (Optional) Initialize the PSD

For any project with multiple contributors or a lifespan > 3 months:

- [ ] `cp PSD.md.example PSD.md`
- [ ] Fill in sections 1–4 (Overview, Reference Stack, Architecture, Hosting Map). Add the rest as scope grows.
- [ ] See [`.claude/rules/psd-maintenance.md`](.claude/rules/psd-maintenance.md) for the "update same session as architecture change" rule.

Skip for throwaway scripts or one-off prototypes.

### 8. Smoke test

- [ ] Start a session and confirm:
  - The SessionStart hook prints recent commits + working-tree state
  - `git commit -m "test"` (no date prefix) is blocked with a clear message
  - Attempting to `Write` an arbitrary `notes.md` is blocked
  - Editing a code file that references an undeclared env var triggers the sync-env-example warning
  - `/checkpoint` produces a sensible tracker entry from your current diff

---

## Deviating from a Stack Default

When you pick a vendor that differs from the template — e.g. **Fly.io instead of Railway**, **MongoDB instead of Postgres**, **SendGrid instead of Postmark** — the change touches these files in this order:

| File | What to edit | Why |
|---|---|---|
| [`CLAUDE.md`](CLAUDE.md) Tech Stack | Replace the `default: <X>` line with your actual choice + one-line rationale | This is the per-session-visible source of truth for what *this* project uses |
| `project_tracker.md` Decisions Log | Append a row: `\| YYYY-MM-DD \| Chose <Y> over <X> \| <why> \|` | Future-you needs the "why we deviated" context six months from now |
| [`.claude/rules/stack-defaults.md`](.claude/rules/stack-defaults.md) | **Do not edit** for a per-project deviation | This file is the *template-wide* default; other projects forked from the template should still see the original default |
| `.claude/skills/<old-vendor>/` (e.g. `railway-new/`) | Optional: delete if you'll truly never use it on this project | Skills auto-fire by description match; unused skills cost nothing at rest but removing slims the repo |
| `.claude/skills/<new-vendor>/` | Optional: add a SKILL.md for the chosen vendor if one doesn't already exist | The skill becomes this project's how-to for that vendor |
| Build / deploy scripts, CI workflow, README env-var docs | Update any vendor-named commands or env vars | Day-two ergonomics: contributors run the right commands |

**Rule of thumb**: per-project deviations live in `CLAUDE.md` + `project_tracker.md`. The defaults in `stack-defaults.md` only change when you decide that *future* projects should default differently.

For other onboarding details (cloning, MCP setup, two-level config) see [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md).

---

## Documentation

| Guide | Read this when |
| --- | --- |
| 📘 [Getting Started](docs/GETTING-STARTED.md) | Setting up your first project from this template |
| 🧩 [Extending the Template](docs/EXTENDING.md) | Adding new rules, skills, agents, commands, or hooks |
| 📚 [Reference](docs/REFERENCE.md) | Looking up what a file does or what frontmatter format to use |
| 🔧 [Maintenance](docs/MAINTENANCE.md) | Versioning the template, forking for domains, syncing improvements |
| 🩹 [Troubleshooting](docs/TROUBLESHOOTING.md) | Something isn't working as expected |

---

## What's Inside

```
.
├── CLAUDE.md                              # Loaded every session (committed)
├── CLAUDE.local.md.example                # Personal overrides template (gitignored)
├── PSD.md.example                         # Long-form spec skeleton — cp to PSD.md when ready
├── .env.example                           # Authoritative env-var inventory — cp to .env
├── .mcp.json                              # Team-shared MCP server config
├── .gitignore                             # Includes .env*, *.key, Claude personal files
├── docs/                                  # All guides — start with GETTING-STARTED.md
└── .claude/
    ├── README.md                          # Folder overview for teammates
    ├── settings.json                      # Permissions + hooks + env (committed)
    ├── settings.local.json.example        # Personal permission overrides template
    ├── rules/                             # Modular instruction files by topic
    │   ├── no-unsolicited-md.md           # Don't create .md files without an ask
    │   ├── project-tracker-discipline.md  # Session-end checkpoint ritual
    │   ├── timestamp-discipline.md        # [YYYY-MM-DD] on commits, migrations, logs
    │   ├── coding-discipline.md           # No fake data, no stdout logs, Decimal for money
    │   ├── secrets-and-env.md             # .env / .env.example pattern + per-env isolation
    │   ├── mvp-boundaries.md              # The "What NOT to Build" list (fill per project)
    │   ├── stack-defaults.md              # Default vendor / library choices
    │   ├── psd-maintenance.md             # When and how to maintain PSD.md
    │   ├── code-style.md                  # Language-specific formatting (Python by default)
    │   ├── testing.md                     # Coverage + structure expectations
    │   └── git-conventions.md             # Branch + commit + PR conventions
    ├── skills/                            # Auto-invoked vendor / domain knowledge
    │   ├── railway-new/                   # Backend hosting (default)
    │   ├── cloudflare/                    # Static + CDN (default)
    │   ├── postmark-automation/           # Email (default)
    │   ├── openrouter-automation/         # AI fallback (default)
    │   ├── supabase/                      # Managed Postgres alternative
    │   ├── clerk-auth/                    # Hosted auth (deviation option)
    │   └── ... (more — see skills/ directory)
    ├── commands/                          # Slash commands (user-typed)
    │   ├── checkpoint.md                  # /checkpoint — append tracker entry
    │   ├── fix-issue.md
    │   └── refactor.md
    ├── agents/                            # Specialized subagent personas
    │   ├── code-reviewer.md
    │   └── test-writer.md
    └── hooks/                             # Shell scripts wired via settings.json
        ├── session-startup.sh             # SessionStart — dump git state + last checkpoint
        ├── nag-tracker-update.sh          # Stop — remind to update project_tracker.md
        ├── block-unsolicited-md.sh        # PreToolUse — refuse stray .md files
        ├── enforce-commit-format.sh       # PreToolUse — require [YYYY-MM-DD] prefix
        ├── check-secrets.sh               # PreToolUse — block obvious secret leaks
        ├── format-python.sh               # PostToolUse — auto-run ruff
        └── sync-env-example.sh            # PostToolUse — flag env vars missing from .env.example
```

See [docs/REFERENCE.md](docs/REFERENCE.md) for what each file does and when it loads.

---

## Two-Level System

Claude Code reads configuration from **two places**:

| Location | Scope | Committed? | Purpose |
| --- | --- | --- | --- |
| `<this-repo>/.claude/` | Per-project | ✅ Yes | Team-shared conventions, project-specific rules and skills |
| `~/.claude/` | Global (your home dir) | ❌ Personal | Your universal preferences, applied to every project you work on |

This template configures the **project** level. For things universal to *you* (your preferred coding style, tooling habits, machine quirks), edit `~/.claude/CLAUDE.md` instead. See [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md) for the full mental model.

---

## License

MIT — fork and adapt freely.
