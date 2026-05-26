# Claude Code Project Template

A production-ready starting point for new projects with a fully configured `.claude/` directory.

## How to use this template

1. On GitHub, click **"Use this template" → "Create a new repository"**.
2. Clone the new repo locally:
   ```bash
   git clone git@github.com:<you>/<new-repo>.git
   cd <new-repo>
   ```
3. Open `CLAUDE.md` and fill in the project-specific sections (overview, tech stack, build commands).
4. Adjust `.claude/settings.json` permissions for your stack.
5. Run `claude` in the project directory — it will auto-load `CLAUDE.md` and the `.claude/` config on first session.

## What's inside

| Path | Purpose |
| --- | --- |
| `CLAUDE.md` | Project context loaded every session (committed) |
| `CLAUDE.local.md.example` | Template for personal notes (rename and gitignore) |
| `.mcp.json` | Team-shared MCP server config |
| `.claude/settings.json` | Permissions, hooks, env vars (committed) |
| `.claude/settings.local.json.example` | Template for personal permissions |
| `.claude/rules/` | Modular instruction files by topic |
| `.claude/skills/` | Reusable auto-invokable workflows |
| `.claude/commands/` | Custom slash commands |
| `.claude/agents/` | Specialized subagent personas |
| `.claude/hooks/` | Shell scripts wired up via `settings.json` |

## License

MIT — fork and adapt freely.
