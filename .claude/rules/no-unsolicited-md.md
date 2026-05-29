# No Unsolicited Markdown Files

Do **not** create `.md` files unless the user explicitly asked for one by name.

This includes summaries, READMEs, changelogs, decision logs, architecture notes,
"helpful" docs, status reports, or any other markdown the user did not request.

If you think a markdown file would be useful, **say so in chat and wait for
approval** before creating it. Do not create it speculatively.

## Why

Speculative markdown clutters the repo, becomes stale, and trains the user to
ignore docs. The rule is bright-line on purpose: zero ambiguity beats good
intentions.

## Allowed without explicit request

These filenames are pre-approved because they are part of the normal repo
scaffold:

- `README.md` (root)
- `CLAUDE.md` (root)
- `project_tracker.md` (root)
- `LICENSE.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`
- Anything inside `.claude/` (rules, commands, agents, skills, README)

To override the allowlist for a project, set the `CLAUDE_MD_ALLOWLIST`
environment variable (comma-separated basenames). The
`block-unsolicited-md.sh` hook enforces this at write time.

## When in doubt

Ask. One line in chat: "Want me to write `<name>.md` for X?" beats creating
a file the user has to delete.
