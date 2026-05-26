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
├── .mcp.json                              # Team-shared MCP server config
├── .gitignore                             # Includes Claude personal files
├── docs/                                  # All guides — start with GETTING-STARTED.md
└── .claude/
    ├── README.md                          # Folder overview for teammates
    ├── settings.json                      # Permissions + hooks + env (committed)
    ├── settings.local.json.example        # Personal permission overrides template
    ├── rules/                             # Modular instruction files by topic
    │   ├── code-style.md
    │   ├── testing.md
    │   └── git-conventions.md
    ├── skills/                            # Auto-invoked reusable workflows
    │   └── code-review/SKILL.md
    ├── commands/                          # Custom slash commands
    │   ├── fix-issue.md
    │   └── refactor.md
    ├── agents/                            # Specialized subagent personas
    │   ├── code-reviewer.md
    │   └── test-writer.md
    └── hooks/                             # Shell scripts wired via settings.json
        ├── format-python.sh
        └── check-secrets.sh
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
