# `.claude/` — Project Control Center

This directory configures Claude Code for this project.

## Files

| Path | Loaded When | Committed? |
| --- | --- | --- |
| `settings.json` | Every session | ✅ Yes |
| `settings.local.json` | Every session (overrides) | ❌ No — personal |
| `rules/*.md` | Referenced from `CLAUDE.md` or by path matching | ✅ Yes |
| `skills/<name>/SKILL.md` | Auto-invoked when task matches, or via `/<name>` | ✅ Yes |
| `commands/<name>.md` | Invoked manually via `/<name>` | ✅ Yes |
| `agents/<name>.md` | Spawned by main agent via the Agent tool | ✅ Yes |
| `hooks/*.sh` | Triggered by events wired in `settings.json` | ✅ Yes |

## Adding things

- **A new rule** (e.g., "always use snake_case for DB columns"): create `rules/<topic>.md`, then either reference it in `CLAUDE.md` or scope it by path with a `applies-to:` frontmatter (see existing rules).
- **A new skill** (e.g., "deploy to Railway"): create `skills/<name>/SKILL.md` with YAML frontmatter describing what it does. Claude loads the description on startup and invokes the skill body when relevant.
- **A new slash command** (e.g., `/db-migrate`): create `commands/db-migrate.md` — the file becomes the prompt.
- **A new subagent** (e.g., a dedicated security auditor): create `agents/security-auditor.md` with frontmatter and a system-prompt body.
- **A new hook** (e.g., run mypy after edits): drop a script in `hooks/`, then wire it up in `settings.json` under `hooks.PostToolUse`.

See the project README and each subdirectory's example files.
