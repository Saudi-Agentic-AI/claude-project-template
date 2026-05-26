# Getting Started

This guide walks you through creating a new project from this template and configuring it for first use.

---

## 1. Create a new project from the template

### Via GitHub UI

1. Open the template repo on GitHub.
2. Click **"Use this template"** at the top right → **"Create a new repository"**.
3. Choose owner (org or your personal account), repo name, and visibility.
4. Clone the new repo locally.

### Via CLI

```bash
gh repo create Saudi-Agentic-AI/my-new-service \
   --template Saudi-Agentic-AI/claude-project-template \
   --private --clone

cd my-new-service
```

`--private` keeps the repo internal to the org. Use `--public` for open-source.

---

## 2. Fill in `CLAUDE.md`

This file loads at the start of every Claude Code session. It's the single most important file for getting useful work out of Claude in this project.

Open `CLAUDE.md` and replace the `TODO` placeholders:

- **Overview** — one paragraph: what does this project do, who uses it, what's the current focus.
- **Tech Stack** — language, framework, database, deployment target.
- **Architecture** — high-level shape. Monolith? Microservices? Hexagonal layers? Where do things live?
- **Build, Test, Run** — the actual commands you use. Claude will use these.
- **Important Notes** — anything project-specific Claude needs to know upfront. Quirks, decisions not to relitigate, non-obvious dependencies.

**Keep it concise.** Claude reads this on every session. Anything specific to one part of the codebase belongs in `.claude/rules/` instead, scoped by path.

---

## 3. Adjust permissions in `.claude/settings.json`

The template ships with sensible defaults for Python projects: git, pytest, ruff, npm, docker compose, etc. are pre-allowed; `.env` reads, SSH key reads, force pushes, and `curl | sh` patterns are denied.

Review the `permissions.allow` list and add anything your stack needs:

- For Go: add `Bash(go test:*)`, `Bash(go build:*)`, `Bash(go mod:*)`.
- For Rust: add `Bash(cargo:*)`.
- For TypeScript only: drop the Python entries you don't need.
- For your project's deploy CLI: add it explicitly (`Bash(railway:*)`, `Bash(fly deploy:*)`, etc.).

For permissions you only want for yourself (e.g., a path to your local credentials helper), use `.claude/settings.local.json` — it's gitignored.

---

## 4. Set up personal override files (optional but recommended)

Rename the `.example` files and start using them:

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
cp .claude/settings.local.json.example .claude/settings.local.json
```

Both are gitignored by default.

- `CLAUDE.local.md` — personal notes for Claude that won't go into team context. "I'm experimenting with X — don't suggest reverting it." "Use my local DB at port 5433."
- `.claude/settings.local.json` — personal permission tweaks. Allow tools your teammates don't use, deny things you specifically want blocked.

---

## 5. Start a Claude Code session

```bash
claude
```

Claude Code automatically loads:

1. `~/.claude/CLAUDE.md` (your personal global context)
2. `CLAUDE.md` (this project's context)
3. `CLAUDE.local.md` (your personal notes for this project, if present)
4. `.claude/settings.json` (project permissions and hooks)
5. `.claude/settings.local.json` (your personal overrides, if present)
6. `.claude/skills/*/SKILL.md` (descriptions — bodies load on demand)
7. `.claude/agents/*.md` (available subagents)
8. `.claude/commands/*.md` (slash commands)

You don't need to do anything to "activate" them.

---

## 6. The mental model: project vs global

Claude Code reads from two places:

```
~/.claude/                    ← GLOBAL — applies to every project you work on
  CLAUDE.md                   ← your universal preferences
  settings.json               ← your default permissions
  skills/, agents/, rules/    ← reusable across all projects
  commands/                   ← personal slash commands

<this-project>/.claude/       ← PROJECT — applies only here, shared with team
  CLAUDE.md (at repo root)    ← project-specific context
  settings.json               ← project permissions
  rules/, skills/, agents/    ← project-specific
```

**Rule of thumb:**

- Universal to *you* → `~/.claude/`
- Specific to *this project* → `<project>/.claude/`
- Specific to *just this one branch you're experimenting on* → `CLAUDE.local.md` or `settings.local.json`

If you find yourself copying the same skill into every project, move it up to `~/.claude/skills/`. If a global skill needs project-specific tweaks, leave the global version alone and add a project-specific override.

---

## 7. Verify the setup

```bash
# Check that Claude Code sees your files
ls -la .claude/

# Confirm hooks are executable
ls -la .claude/hooks/
# Should show -rwxr-xr-x for the .sh files. If not:
chmod +x .claude/hooks/*.sh

# Run Claude and ask it to summarize what it knows about the project
claude
> What do you know about this project?
```

If Claude responds with your CLAUDE.md content (paraphrased), you're set.

---

## Next steps

- [Extending the Template](EXTENDING.md) — start adding your own rules, skills, agents, and commands.
- [Reference](REFERENCE.md) — file-by-file quick lookup.
