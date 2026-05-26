# Maintenance

How to evolve this template over time, fork it for domain-specific use, and keep downstream projects in sync.

---

## Three principles

1. **Changes flow template → projects**, not the other way around. Improvements found while working on a project get ported back to the template *deliberately*, not by automatic sync.
2. **Keep the template lean.** It's the baseline 80% of projects need. Domain-specific content belongs in forks.
3. **Version it.** Tag releases. When you change the settings schema or rule structure in breaking ways, bump the major version.

---

## Versioning the template

Use semantic versioning:

- **MAJOR** — breaking changes to `settings.json` schema, removed rules/skills, restructured directories
- **MINOR** — new rules, skills, agents, commands; backward-compatible improvements
- **PATCH** — typos, wording improvements, hook bug fixes

After making changes:

```bash
git add .
git commit -m "feat: add deploy-railway skill"
git tag -a v1.1.0 -m "v1.1.0: deploy-railway skill, refactor code-review prompt"
git push origin main --tags
```

Projects spawned from a tag stay stable; projects spawned from `main` get the bleeding edge.

To create a project from a specific template version:

```bash
gh repo create Saudi-Agentic-AI/new-service \
   --template Saudi-Agentic-AI/claude-project-template \
   --private --clone

cd new-service
# Check out the tag in the template repo, then copy specific files if needed
```

(GitHub's `--template` flag uses the default branch — to pin to a tag you'd typically clone the tag and rebase.)

---

## Porting improvements from a project back to the template

You improve a skill while working on Project A. The improvement is general-purpose. Port it back:

```bash
# Option 1: copy-paste the file from Project A into the template repo
cd ~/claude_projects/claude-project-template
cp ~/projects/project-a/.claude/skills/code-review/SKILL.md \
   .claude/skills/code-review/SKILL.md
git diff .claude/skills/code-review/SKILL.md
git add . && git commit -m "improve: code-review skill clarifies blocker severity"

# Option 2: cherry-pick the commit from Project A
git remote add project-a /path/to/project-a       # local path or URL
git fetch project-a
git cherry-pick <commit-sha>
```

**Don't** port project-specific stuff. If the improvement references Project A's domain (e.g., "Saudi market data") or business logic, it doesn't belong in the baseline template.

---

## Pulling template updates into an existing project

The template has improved. You want to bring a specific skill/rule/setting into a project that was spawned weeks ago.

GitHub templates don't auto-sync — that's by design. Pull updates manually:

```bash
# In your project repo, add the template as a remote (one-time setup)
git remote add template git@github.com:Saudi-Agentic-AI/claude-project-template.git
git fetch template

# Pull a specific file from the template's latest main
git checkout template/main -- .claude/skills/code-review/SKILL.md
git diff --staged
git commit -m "chore(claude): sync code-review skill from template v1.2.0"

# Or pull from a specific tag
git checkout template/v1.2.0 -- .claude/skills/code-review/SKILL.md
```

For bigger sync operations, do them one file at a time and review each diff. Don't try to merge the whole template into the project — your project has diverged for good reasons.

---

## Forking for domain-specific templates

The baseline template is generic. For domains with distinct conventions, fork it.

### When to fork

- The same set of rules/skills/agents would apply to 3+ projects in the same domain
- The domain has conventions distinct enough that the baseline rules are misleading
- You find yourself repeatedly deleting or rewriting the same files after creating a new project

### How to fork

```bash
gh repo create Saudi-Agentic-AI/claude-fastapi-template \
   --template Saudi-Agentic-AI/claude-project-template \
   --private --clone

cd claude-fastapi-template
# Tighten the baseline for FastAPI:
# - Update CLAUDE.md to assume FastAPI/Pydantic
# - Add rules/fastapi-conventions.md
# - Add skills/deploy-railway/
# - Add commands/db-migrate.md
# - Keep the baseline rules that still apply

git add .
git commit -m "chore: fork claude-project-template for FastAPI projects"
gh repo edit --template       # mark as template
```

### Suggested domain forks for your work

| Fork name | For | Adds |
| --- | --- | --- |
| `claude-fastapi-template` | Binder services, Tasi Lab | FastAPI patterns, PostgreSQL rules, Railway deploy skill, ZATCA notes |
| `claude-ml-research-template` | Fatigue/fracture ML research | GroupKFold rules, LaTeX skill, ABAQUS conventions, paper-structure agent |
| `claude-pinescript-template` | Trading strategy development | Pine Script style rules, TradingView MCP, backtest workflow skill |
| `claude-nextjs-template` | Frontend projects | React conventions, Tailwind rules, Vercel deploy skill |

Each domain fork inherits the baseline. When the baseline improves, you can pull updates into the fork using the same remote-and-checkout pattern.

---

## Keeping forks in sync with the baseline

```bash
# In the fork repo (one-time setup)
git remote add baseline git@github.com:Saudi-Agentic-AI/claude-project-template.git

# Periodically:
git fetch baseline
git log --oneline baseline/main ^main        # see what's new in baseline
git checkout baseline/main -- .claude/<file-you-want>
git commit -m "sync: pull <file> from baseline v1.3.0"
```

Don't merge `baseline/main` into the fork wholesale. The fork has diverged intentionally — merge cleanly file-by-file.

---

## Deprecating things

To remove a rule, skill, or command from the template without breaking existing projects:

1. Add a `DEPRECATED` note at the top of the file with a removal date.
2. In the next minor release, mark it deprecated; release notes flag it.
3. In the next major release, remove the file.

Projects spawned from the template before deprecation keep the old version. They can choose to remove it on their own schedule.

---

## A maintenance checklist

Run this quarterly or when something feels off:

- [ ] Review `.claude/settings.json` permissions — any tools the team uses that aren't allowed? Any that should be denied?
- [ ] Read each rule file end-to-end — still accurate? Still followed?
- [ ] Read each skill — would Claude actually invoke it on the trigger phrases you wrote?
- [ ] Check hook scripts — still relevant? Still fast?
- [ ] Try creating a new project from the template — does the README workflow still work?
- [ ] Tag a release if anything substantive changed.

---

## When to retire the template

If you go 6+ months without updating it and projects keep diverging in the same ways, the template isn't the baseline anymore — your projects are. Either:

- Update the template to match where projects have converged, or
- Fork it into domain-specific templates and let the baseline shrink to just the truly universal stuff.

A stale template is worse than no template: it teaches new projects bad defaults.
