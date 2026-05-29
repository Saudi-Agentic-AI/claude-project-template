#!/usr/bin/env bash
# block-unsolicited-md.sh — refuse to create new *.md files outside an allowlist.
# Wired up via .claude/settings.json under hooks.PreToolUse for the Write tool.
#
# Returns exit 2 (= block the tool call) when a new .md file outside the
# allowlist is being created. Returns exit 0 otherwise.
#
# Why: per .claude/rules/no-unsolicited-md.md — speculative markdown clutters
# the repo, becomes stale, and trains the user to ignore docs. Bright-line rule.
#
# Override the allowlist by setting CLAUDE_MD_ALLOWLIST (comma-separated
# basenames) in your shell or .claude/settings.json env block.
#
# Bypass entirely with CLAUDE_SKIP_MD_BLOCK=1.

set -uo pipefail

[[ "${CLAUDE_SKIP_MD_BLOCK:-}" == "1" ]] && exit 0

INPUT="$(cat)"

# Hook input is JSON: { "tool_name": "Write", "tool_input": { "file_path": "...", "content": "..." } }
# Extract file_path via grep (no jq dependency).
FILE_PATH="$(echo "$INPUT" \
  | grep -Eo '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"

# Not a Write of a path we can read — let it through.
[[ -z "$FILE_PATH" ]] && exit 0

# Only police .md files.
[[ "$FILE_PATH" == *.md ]] || exit 0

# If the file already exists, this is an edit not a create — allow.
[[ -f "$FILE_PATH" ]] && exit 0

# Anything inside .claude/ is part of the harness scaffold — allow.
case "$FILE_PATH" in
  *.claude/*|*/.claude/*) exit 0 ;;
esac

# Default allowlist (basenames). Override with CLAUDE_MD_ALLOWLIST.
DEFAULT_ALLOWLIST="README.md,CLAUDE.md,project_tracker.md,LICENSE.md,CHANGELOG.md,CONTRIBUTING.md,SECURITY.md,CODE_OF_CONDUCT.md"
ALLOWLIST="${CLAUDE_MD_ALLOWLIST:-$DEFAULT_ALLOWLIST}"

BASENAME="$(basename "$FILE_PATH")"

# Check membership.
IFS=',' read -ra ALLOWED <<< "$ALLOWLIST"
for allowed in "${ALLOWED[@]}"; do
  # Trim whitespace.
  allowed="$(echo "$allowed" | xargs)"
  if [[ "$BASENAME" == "$allowed" ]]; then
    exit 0
  fi
done

# Not in allowlist — refuse.
cat >&2 <<EOF
🚫 block-unsolicited-md.sh: refusing to create '$FILE_PATH'.

Per .claude/rules/no-unsolicited-md.md, do not create .md files unless the
user explicitly asked for one by name.

If the user did ask for this file by name, retry by:
  - Naming the file in chat and getting confirmation, then
  - Adding the basename to CLAUDE_MD_ALLOWLIST (env or settings.json), or
  - Setting CLAUDE_SKIP_MD_BLOCK=1 for this session.

Current allowlist: $ALLOWLIST
EOF
exit 2
