# Project Tracker Discipline

`project_tracker.md` lives at the repo root and is the single source of truth
for project progress. **Update it at the end of every session — never skip.**

If `project_tracker.md` does not exist yet, create it on the first session
that produces any change worth recording.

## Checkpoint format

Every session-end entry uses this template:

```markdown
## Checkpoint — YYYY-MM-DD HH:MM <TZ>

### Completed
- <specific file or feature, e.g. "src/services/payments.py — add idempotency key">
- ...

### Tested
- <what was tested + result, e.g. "pytest tests/test_payments.py — 12 passed">
- ...

### Blockers / Open Questions
- <anything unresolved, or "None">

### Next Session
- <first task to pick up next time>
```

`<TZ>` is the local timezone abbreviation (e.g. `AST`, `PST`, `UTC`). Use
`date +%Z` if uncertain. Configure default via `CLAUDE_TIMEZONE` env var.

## Decisions log

`project_tracker.md` also carries a **Decisions Log** section near the top:

```markdown
## Decisions Log

| Date | Decision | Rationale |
|---|---|---|
| YYYY-MM-DD | <what was decided> | <why> |
| YYYY-MM-DD | Reversed: <prior decision> | <why we reversed> |
```

Update the Decisions Log whenever you:
- Adopt a new architectural pattern
- Reverse a previous decision (the "why we reversed" matters as much as the
  original "why")
- Make a tradeoff the next reader would not infer from the code alone

Use the `/decision <text>` command to append entries quickly.

## Why this exists

Memory across sessions is unreliable. The tracker is the durable record so
the next session (yours or someone else's) can pick up cold. A 10-minute
session still gets a checkpoint — small entries are fine; missing entries
are not.

## Helpers

- `/checkpoint` slash command — drafts a checkpoint from the current diff
- `session-startup.sh` hook — tails the last checkpoint at session start
- `nag-tracker-update.sh` hook — reminds you before close if the tracker
  is stale
