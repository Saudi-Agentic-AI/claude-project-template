# Timestamp Discipline

Every dated artifact gets a real, machine-readable date. No "recently",
"yesterday", or "the other day" in code or docs that future-you will read
in six months.

## Where dates are required

### Commit messages

```
[YYYY-MM-DD] type(scope): subject
```

Examples:
- `[2026-05-29] feat(payments): add idempotency key to charge endpoint`
- `[2026-05-29] fix(auth): correct password reset token TTL`
- `[2026-05-29] docs(readme): clarify dev setup steps`

Enforced by `.claude/hooks/enforce-commit-format.sh` (PreToolUse on `git
commit`). Bypass with `CLAUDE_SKIP_COMMIT_FORMAT=1` if a project genuinely
wants plain Conventional Commits.

### Migration filenames + messages

If your stack uses a migration tool (Alembic, Knex, Prisma, Flyway, etc.),
include the date in the message:

```bash
alembic revision -m "2026-05-29 add positions table"
```

Rename auto-generated migration files to include the date:
`<seq>_YYYY_MM_DD_<short_descriptor>.py`.

### Project tracker checkpoints

Format: `## Checkpoint — YYYY-MM-DD HH:MM <TZ>` (see
`project-tracker-discipline.md`).

### Structured log entries

Every log line includes a `timestamp` field (ISO 8601, UTC preferred).
Modern structured loggers (`structlog`, `pino`, `zap`, `zerolog`) do this
automatically — confirm it is enabled.

Never log via `print` / `console.log` / `fmt.Println` / `System.out.println`.
Use the structured logger. See `coding-discipline.md`.

### Documentation that ages

When updating architecture docs, decision logs, or any "as of" claim, write
the date inline:

> As of 2026-05-29, the API runs on Python 3.11.

Not:

> As of recently, the API runs on Python 3.11.

## Timezone

Default to the local timezone of the person operating the project. Set
`CLAUDE_TIMEZONE` env var to override (e.g. `AST`, `UTC`, `America/New_York`).
Use `date +%Z` in scripts to get the local abbreviation.

For logs and machine-read timestamps, prefer UTC. For human-read entries
(tracker, commits), local timezone is fine.

## Why this exists

Dates make memory work. "We migrated to X in Q2" is useless six months
later. "We migrated to X on 2026-04-09 because of incident Y" is still
useful in 2030. Cost of a date prefix: 12 characters. Value: durable
context.
