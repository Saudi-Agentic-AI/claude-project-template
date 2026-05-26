# Reference

Quick lookup for files, frontmatter formats, and common patterns.

---

## File reference

### Project-scope files

Live in this repo. Committed (mostly) and shared with the team.

| File | Loaded when | Committed | Purpose |
| --- | --- | --- | --- |
| `CLAUDE.md` | Every session | ✅ | Project context, conventions overview, build/test commands |
| `CLAUDE.local.md` | Every session | ❌ | Your personal notes for this project |
| `.mcp.json` | Every session | ✅ | Team-shared MCP server connections |
| `.claude/settings.json` | Every session | ✅ | Permissions, hooks, env vars |
| `.claude/settings.local.json` | Every session | ❌ | Your personal permission tweaks |
| `.claude/rules/*.md` | When matching path or referenced from `CLAUDE.md` | ✅ | Topic-scoped instructions |
| `.claude/skills/<name>/SKILL.md` | Description on startup, body on demand | ✅ | Reusable workflows |
| `.claude/commands/<name>.md` | When invoked via `/<name>` | ✅ | Manual slash commands |
| `.claude/agents/<name>.md` | When main agent delegates | ✅ | Subagent personas |
| `.claude/hooks/*.sh` | Triggered by tool events (wired in `settings.json`) | ✅ | Deterministic automation |

### Global-scope files

Live in `~/.claude/` (or `%USERPROFILE%\.claude` on Windows). Apply to every project. Never committed.

| File | Purpose |
| --- | --- |
| `~/.claude/CLAUDE.md` | Your universal context (preferences, machine quirks, tooling habits) |
| `~/.claude/settings.json` | Your default permissions across all projects |
| `~/.claude/skills/<name>/SKILL.md` | Skills available in every project |
| `~/.claude/agents/<name>.md` | Agents available in every project |
| `~/.claude/commands/<name>.md` | Personal slash commands |

---

## Frontmatter formats

### Rule (`.claude/rules/*.md`)

```yaml
---
description: One-line summary (required)
applies-to: ["glob1", "glob2"]    # optional — restricts when rule loads
---
```

### Skill (`.claude/skills/<name>/SKILL.md`)

```yaml
---
name: skill-name                   # required, matches folder name
description: "When to use this skill. Be specific — Claude uses this to auto-invoke."
---
```

### Command (`.claude/commands/<name>.md`)

```yaml
---
description: One-line summary shown in slash command picker
argument-hint: <hint-after-command-name>
---
```

The text after `/<name>` becomes `$ARGUMENTS` in the prompt body.

### Agent (`.claude/agents/<name>.md`)

```yaml
---
name: agent-name                   # required
description: "When to delegate to this agent"
tools: Read, Grep, Glob, Bash      # optional — restricts available tools
model: claude-opus-4-7             # optional — pin a specific model
---
```

---

## `settings.json` schema

### Top-level keys

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": { "allow": [...], "deny": [...] },
  "hooks": { "PreToolUse": [...], "PostToolUse": [...], "Stop": [...] },
  "env": { "KEY": "value" }
}
```

### Permission rules

Match against tool calls. Format: `Tool(pattern)` where pattern uses glob-like syntax.

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",          // exact match
      "Bash(pytest:*)",            // pytest with any args
      "Read(**)",                  // read any file
      "Write(src/**)",             // write only under src/
      "Edit(*.md)"                 // edit any .md file
    ],
    "deny": [
      "Read(.env)",
      "Read(**/*.key)",
      "Bash(rm -rf /:*)",
      "Bash(git push --force:*)"
    ]
  }
}
```

`deny` always wins over `allow`. Patterns are checked top-to-bottom.

### Hook configuration

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/format-python.sh" }
        ]
      }
    ]
  }
}
```

Hook events:

| Event | Fires |
| --- | --- |
| `PreToolUse` | Before a tool call. Exit code 2 blocks the call. |
| `PostToolUse` | After a tool call completes |
| `Stop` | When Claude finishes its turn |
| `Notification` | When Claude needs user input |

Matchers are regex against tool names (`Edit`, `Write`, `Bash`, etc.) or use `*` for all.

### Hook environment variables

Hooks receive these via env:

| Variable | Contains |
| --- | --- |
| `CLAUDE_FILE_PATHS` | Space-separated paths of files affected by the tool call |
| `CLAUDE_TOOL_NAME` | Name of the tool being called |
| Hook stdin | JSON of the full tool call |

---

## Slash command reference

Built-in commands (always available):

| Command | Purpose |
| --- | --- |
| `/init` | Scaffold a new `CLAUDE.md` for the current project |
| `/clear` | Clear conversation context |
| `/memory` | Show what's in Claude's working memory |
| `/agents` | List and manage subagents |
| `/help` | Show all available commands |
| `/cost` | Show token usage and cost for this session |

Project-defined commands appear automatically once you add `.md` files under `.claude/commands/`.

---

## Loading order and precedence

When a session starts, Claude Code loads files in this order:

1. **Managed settings** (org-enforced, can't override) — `managed-settings.json`
2. **Global config** — `~/.claude/settings.json`, `~/.claude/CLAUDE.md`
3. **Project config** — `.claude/settings.json`, `CLAUDE.md`
4. **Local overrides** — `.claude/settings.local.json`, `CLAUDE.local.md`
5. **CLI flags** — `--permission-mode`, `--settings`, etc.

Later layers override earlier ones (except for `deny` rules, which are always additive).

---

## Useful CLI commands

```bash
# Start a session
claude

# Start with a specific permission mode
claude --permission-mode acceptEdits      # auto-accept Edit/Write
claude --permission-mode plan             # planning only, no edits

# Pass an initial prompt
claude "Add a /health endpoint to the API"

# Run non-interactively (for scripts/CI)
claude -p "Summarize the recent commits" --no-session-persistence

# Continue the last session
claude --continue

# Resume a specific session
claude --resume <session-id>

# Use a specific settings file
claude --settings /path/to/custom-settings.json
```

---

## Where things live on disk

```
~/.claude/                              # global config
~/.claude.json                          # global app state (auth, etc. — don't edit by hand)
~/.claude/projects/<project-hash>/      # per-project session transcripts, plans, snapshots
~/.claude/history.jsonl                 # all your prompts (for up-arrow recall)
~/.claude/plugins/                      # installed plugins
```

To clear state for one project: `claude project purge <path>`.
To clear state for all projects: `claude project purge --all`.

Don't delete `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — those hold your auth and preferences.

---

## Official documentation

For the canonical, always-up-to-date reference:

- [Claude Code overview](https://code.claude.com/docs/en/overview)
- [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)
- [Settings reference](https://code.claude.com/docs/en/settings)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Skills reference](https://code.claude.com/docs/en/skills)
- [Subagents reference](https://code.claude.com/docs/en/sub-agents)
- [Memory and CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Permissions reference](https://code.claude.com/docs/en/permissions)
