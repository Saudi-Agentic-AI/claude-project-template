#!/usr/bin/env bash
# nag-tracker-update.sh — remind to update project_tracker.md before close.
# Wired up via .claude/settings.json under hooks.Stop.
#
# Triggers when:
#   - project_tracker.md exists in the repo root, AND
#   - there are uncommitted changes to OTHER files, AND
#   - project_tracker.md is NOT among the modified files.
#
# Output goes to stdout (becomes a system message Claude sees on next turn).
# Does not block — this is a reminder, not an enforcement.
#
# Skip with CLAUDE_SKIP_TRACKER_NAG=1.

set -uo pipefail

[[ "${CLAUDE_SKIP_TRACKER_NAG:-}" == "1" ]] && exit 0

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[[ -f project_tracker.md ]] || exit 0

# What's modified?
MODIFIED="$(git status --porcelain 2>/dev/null)"
[[ -z "$MODIFIED" ]] && exit 0

# Is project_tracker.md itself touched (staged or unstaged)?
if echo "$MODIFIED" | grep -qE '(^|/)project_tracker\.md$'; then
  exit 0
fi

# Are there changes to anything else? (we already know MODIFIED is non-empty,
# and we know tracker isn't in it, so by definition yes.)
cat <<EOF
📝 reminder: project_tracker.md was not updated this session.

Per .claude/rules/project-tracker-discipline.md, every session ends with a
checkpoint entry. Run \`/checkpoint\` to draft one from the current diff,
or update project_tracker.md manually before closing.

Files modified this session:
$(echo "$MODIFIED" | head -10 | sed 's/^/  /')
EOF
exit 0
