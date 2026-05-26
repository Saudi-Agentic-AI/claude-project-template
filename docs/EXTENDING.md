# Extending the Template

How to add new rules, skills, slash commands, subagents, and hooks.

---

## The mental model

Each `.claude/` subdirectory has a different *invocation pattern*. You pick where to put your content based on **when** you want Claude to use it.

| Type | Where | When it activates | Use for |
| --- | --- | --- | --- |
| **Rule** | `.claude/rules/*.md` | Loaded into context when relevant (path-scoped or via `CLAUDE.md` reference) | Conventions, style guides, "always do X / never do Y" |
| **Skill** | `.claude/skills/<name>/SKILL.md` | Auto-invoked when task matches description; descriptions load on startup, bodies on demand | Repeatable multi-step workflows |
| **Command** | `.claude/commands/<name>.md` | Triggered manually via `/<name>` | Manual workflows, often with arguments |
| **Agent** | `.claude/agents/<name>.md` | Spawned by the main agent via the Agent tool, runs in isolated context | Specialized personas, adversarial reviews, focused tasks |
| **Hook** | `.claude/hooks/*.sh` (wired in `settings.json`) | Triggered by tool events (PreToolUse, PostToolUse, Stop, etc.) | Deterministic automation: formatting, linting, blocking |

If you're not sure which to use:

- Need Claude to *know* something → **rule**
- Need Claude to *do* something automatically when relevant → **skill**
- Need Claude to *do* something when you ask → **command**
- Need a fresh, focused context for a specialized task → **agent**
- Need *guaranteed* deterministic behavior, not Claude's discretion → **hook**

---

## Adding a rule

**Use rules for:** style guides, conventions, "always do X / never do Y" content that Claude needs in context whenever it touches certain files.

### Example: database conventions

```bash
cat > .claude/rules/database.md <<'EOF'
---
description: PostgreSQL schema and query conventions
applies-to: ["**/migrations/**", "**/models/**", "**/db/**"]
---

# Database Conventions

- snake_case table and column names
- Singular table names (`user`, not `users`)
- Every table has `id`, `created_at`, `updated_at`
- Migrations must be reversible. If they can't be, comment why.
- Never DROP COLUMN in a migration touching production — deprecate first, drop in a follow-up release.
EOF

git add .claude/rules/database.md
git commit -m "docs(claude): add database conventions rule"
```

### Frontmatter

```yaml
---
description: One-line summary (required)
applies-to: ["glob1", "glob2"]    # optional — restricts when rule loads
---
```

The `applies-to` field scopes the rule so it doesn't pollute context on unrelated files. For globally relevant rules, omit `applies-to` and reference the rule from `CLAUDE.md`.

### Tips

- One topic per rule file. Don't write a 500-line `rules/everything.md`.
- Lead with the *what* and *why*. Don't bury the rule in prose.
- Use bullet points for enforceable rules, prose for nuance.

---

## Adding a skill

**Use skills for:** repeatable multi-step workflows that Claude should auto-invoke when the task matches.

### Example: deploy to Railway

```bash
mkdir -p .claude/skills/deploy-railway
cat > .claude/skills/deploy-railway/SKILL.md <<'EOF'
---
name: deploy-railway
description: "Deploy the current service to Railway. Use when the user says deploy, ship, push to production, or release."
---

# Deploy to Railway

1. Confirm we're on `main` and the working tree is clean.
2. Run the full test suite. Abort on any failure.
3. Bump the version in `pyproject.toml` per semver.
4. Tag the commit: `git tag -a v<x.y.z> -m "release: v<x.y.z>"`
5. Push: `git push origin main --tags`
6. Trigger Railway deploy: `railway up --service api`
7. Watch logs for 60 seconds. Report status.

## Stop and ask if

- The test suite has any new failures
- The version bump is ambiguous (breaking change? new feature? patch?)
- The git tag already exists
EOF

git add .claude/skills/deploy-railway/
git commit -m "feat(claude): add deploy-railway skill"
```

### Frontmatter

```yaml
---
name: deploy-railway               # required, matches the folder name
description: "..."                  # required — Claude uses this to decide when to invoke
---
```

The `description` is **critical**. Claude sees it on every session and uses it to decide when to invoke the skill. Be specific: include trigger phrases the user is likely to say.

### Skills can bundle files

A skill is a *folder*, so you can include supporting files:

```
.claude/skills/deploy-railway/
├── SKILL.md
├── checklist.md           # referenced from SKILL.md
└── rollback.sh            # script the skill can invoke
```

Reference them from `SKILL.md` with relative paths.

### Tips

- Make the description specific. "Deploy stuff" won't auto-invoke; "Deploy the current service to Railway when user says ship/deploy/release" will.
- Include a "Stop and ask if" section. Skills should be conservative about ambiguous situations.
- Bias toward action verbs in the body. Numbered steps make Claude follow them in order.

---

## Adding a slash command

**Use commands for:** manual workflows triggered by `/<name>`, often with arguments.

### Example: database migration

```bash
cat > .claude/commands/db-migrate.md <<'EOF'
---
description: Create a new Alembic migration
argument-hint: <migration-name>
---

Create a new database migration named "$ARGUMENTS":

1. Run `alembic revision --autogenerate -m "$ARGUMENTS"`
2. Open the generated file in alembic/versions/
3. Review the autogenerated upgrade()/downgrade() — autogenerate misses things
4. Verify downgrade() actually reverses upgrade()
5. Apply locally: `alembic upgrade head`
6. Test rollback: `alembic downgrade -1` then `alembic upgrade head`
7. Commit per .claude/rules/git-conventions.md
EOF

git add .claude/commands/db-migrate.md
git commit -m "feat(claude): add /db-migrate command"
```

Invoke with `/db-migrate add_user_email_index`. The text after the command becomes `$ARGUMENTS` in the prompt.

### Frontmatter

```yaml
---
description: One-line summary shown in slash command picker
argument-hint: <hint-shown-after-command-name>
---
```

### When to use a command vs a skill

- **Command**: you want explicit control. Type `/refactor` to trigger.
- **Skill**: you want Claude to invoke automatically when the task matches the description.

The underlying mechanism is the same — a command is effectively a skill that only triggers manually. If a workflow is unambiguously triggered by certain phrases, use a skill; if you want to gate it behind explicit invocation, use a command.

---

## Adding a subagent

**Use agents for:** specialized personas with isolated context that the main agent can delegate to. Good when:

- The task pollutes the main context (e.g., security audit produces a lot of output you don't need afterwards)
- A different mental model is useful (e.g., adversarial reviewer vs implementer)
- The work is large enough to warrant its own context window

### Example: security auditor

```bash
cat > .claude/agents/security-auditor.md <<'EOF'
---
name: security-auditor
description: "Adversarial security review of code changes. Spawn before merging anything that touches auth, payments, user data, or external inputs."
tools: Read, Grep, Glob, Bash
---

You are an adversarial security auditor. Assume the author missed something.

Look for:
- OWASP Top 10 (injection, broken auth, sensitive data exposure, XXE, broken access control, misconfiguration, XSS, insecure deserialization, vulnerable components, insufficient logging)
- Saudi-specific: PDPL compliance, ZATCA data residency where relevant
- Secrets, keys, PII in code or logs
- Race conditions in concurrent paths
- Trust boundary violations
- Missing rate limits, missing input validation

Report findings ranked: Critical / High / Medium / Low.

You do not modify code. You report.
EOF

git add .claude/agents/security-auditor.md
git commit -m "feat(claude): add security-auditor subagent"
```

### Frontmatter

```yaml
---
name: security-auditor             # required
description: "..."                  # required — main agent uses this to decide when to delegate
tools: Read, Grep, Glob, Bash      # optional — restrict which tools the subagent can use
model: claude-opus-4-7             # optional — pin a model
---
```

### Tips

- Limit `tools` to what the agent actually needs. A code reviewer shouldn't have `Write`. A test-writer shouldn't have access to deployment tools.
- Write the body as a system prompt — first person ("You are..."), task-focused.
- Be clear about what the agent does *not* do. "You do not modify code. You report."

---

## Adding a hook

**Use hooks for:** deterministic automation on tool events. Hooks always run; Claude can't decide to skip them.

Two steps: write the script, then wire it up in `settings.json`.

### Example: run tests when Python files change

```bash
# 1. Write the script
cat > .claude/hooks/run-affected-tests.sh <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
[[ -z "${CLAUDE_FILE_PATHS:-}" ]] && exit 0

for file in $CLAUDE_FILE_PATHS; do
  [[ "$file" == *.py ]] || continue
  # Map src/foo/bar.py → tests/foo/test_bar.py
  test_file="tests/${file#src/}"
  test_file="${test_file%.py}"
  test_file="$(dirname "$test_file")/test_$(basename "$test_file").py"
  [[ -f "$test_file" ]] && pytest "$test_file" --no-header -q
done
exit 0
EOF
chmod +x .claude/hooks/run-affected-tests.sh

# 2. Wire it up in .claude/settings.json under hooks.PostToolUse
```

Edit `.claude/settings.json` to add the hook entry:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/format-python.sh" },
          { "type": "command", "command": ".claude/hooks/run-affected-tests.sh" }
        ]
      }
    ]
  }
}
```

### Hook events

| Event | Fires | Use for |
| --- | --- | --- |
| `PreToolUse` | Before a tool call runs | Validation, blocking unsafe operations |
| `PostToolUse` | After a tool call completes | Formatting, linting, notifying |
| `Stop` | When Claude finishes its turn | Final cleanup, summary notifications |
| `Notification` | When Claude needs user input | Custom alerts (desktop notifications, etc.) |

### Exit codes matter

- `0` — success, continue normally
- `2` — block the tool call (only meaningful for `PreToolUse`)
- Other non-zero — error, but Claude continues

### Tips

- Hooks should be **fast**. They run on every matching tool call. A 5-second linter on every edit will make Claude feel sluggish.
- Hooks should be **silent on success**. Only print on errors or blocks.
- Hook scripts must be **executable**: `chmod +x .claude/hooks/*.sh`.
- `CLAUDE_FILE_PATHS` is space-separated; quote it carefully or iterate.

---

## When you've added something, commit it

Everything in `.claude/` (except `settings.local.json` and any other `.local.*` files) is committed and shared with the team. Use proper commit messages:

```bash
git add .claude/skills/deploy-railway/
git commit -m "feat(claude): add deploy-railway skill"
```

For the template repo itself, after adding a new general-purpose component, tag a release if it's significant:

```bash
git tag -a v1.1.0 -m "Add deploy-railway skill, refactor code-review prompt"
git push origin v1.1.0
```

See [MAINTENANCE.md](MAINTENANCE.md) for the full versioning workflow.

---

## A note on context budget

Every rule, skill description, agent definition, and command takes context space at session start. The body of a skill or command only loads when invoked, but descriptions are always in context.

- 5–15 rules, skills, and commands combined: fine.
- 50+: you're spending real context budget on metadata. Trim.
- If a rule isn't being followed, the problem is usually visibility (where it's referenced) or specificity (vague phrasing), not "Claude needs to be told harder."
