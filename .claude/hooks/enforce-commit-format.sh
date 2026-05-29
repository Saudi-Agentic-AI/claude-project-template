#!/usr/bin/env bash
# enforce-commit-format.sh — require [YYYY-MM-DD] date prefix on git commits.
# Wired up via .claude/settings.json under hooks.PreToolUse for the Bash tool.
#
# Format required:
#   [YYYY-MM-DD] type(scope): subject
# Examples:
#   [2026-05-29] feat(payments): add idempotency key
#   [2026-05-29] fix(auth): correct token TTL
#
# Returns exit 2 (= block) on git commit -m without the date prefix.
# Returns exit 0 in all other cases (non-git commands, --amend without -m,
# interactive commits, etc.) — only the inline -m flag is policed.
#
# Bypass with CLAUDE_SKIP_COMMIT_FORMAT=1.

set -uo pipefail

[[ "${CLAUDE_SKIP_COMMIT_FORMAT:-}" == "1" ]] && exit 0

INPUT="$(cat)"

# Hook input is JSON: { "tool_name": "Bash", "tool_input": { "command": "..." } }
COMMAND="$(echo "$INPUT" \
  | grep -Eo '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' \
  | head -1 \
  | sed -E 's/^"command"[[:space:]]*:[[:space:]]*"//;s/"$//')"

[[ -z "$COMMAND" ]] && exit 0

# Only police 'git commit' commands.
echo "$COMMAND" | grep -qE '(^|[[:space:]&;|])git[[:space:]]+commit([[:space:]]|$)' || exit 0

# If there's no inline -m, the user is doing an interactive commit — let them
# handle the message themselves (their editor / hooks downstream catch it).
echo "$COMMAND" | grep -qE '(-m|--message)([[:space:]]|=)' || exit 0

# Now require the date prefix somewhere in the command.
# Pattern matches [2024-..2099-XX-XX].
if echo "$COMMAND" | grep -qE '\[20[0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\]'; then
  exit 0
fi

cat >&2 <<EOF
🚫 enforce-commit-format.sh: commit message missing [YYYY-MM-DD] date prefix.

Required format:
  [YYYY-MM-DD] type(scope): subject

Examples:
  [$(date +%Y-%m-%d)] feat(payments): add idempotency key
  [$(date +%Y-%m-%d)] fix(auth): correct token TTL

See .claude/rules/timestamp-discipline.md for the why.
Bypass with CLAUDE_SKIP_COMMIT_FORMAT=1 if this project uses plain
Conventional Commits.
EOF
exit 2
