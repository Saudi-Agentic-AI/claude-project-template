#!/usr/bin/env bash
# session-startup.sh — print key project signals at session start.
# Wired up via .claude/settings.json under hooks.SessionStart.
#
# Output goes into Claude's session context. Keep it lean — every line
# you print is context Claude reads on every turn.
#
# Skip with CLAUDE_SKIP_SESSION_STARTUP=1.

set -uo pipefail

[[ "${CLAUDE_SKIP_SESSION_STARTUP:-}" == "1" ]] && exit 0

# Bail quietly if we're not in a git repo (e.g., fresh template directory).
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

echo "=== session startup ==="

# 1. Last project_tracker.md checkpoint (if any).
if [[ -f project_tracker.md ]]; then
  echo ""
  echo "--- last checkpoint (project_tracker.md) ---"
  # Print from the last "## Checkpoint" header to EOF.
  awk '
    /^## Checkpoint/ { buf = ""; in_block = 1 }
    in_block { buf = buf $0 "\n" }
    END { printf "%s", buf }
  ' project_tracker.md | head -40
else
  echo ""
  echo "--- no project_tracker.md yet — create one when you have something to record ---"
fi

# 2. Recent commits.
echo ""
echo "--- recent commits ---"
git log --oneline -10 2>/dev/null || echo "(no commits yet)"

# 3. Working tree status.
echo ""
echo "--- working tree ---"
STATUS="$(git status --short 2>/dev/null)"
if [[ -z "$STATUS" ]]; then
  echo "(clean)"
else
  echo "$STATUS" | head -20
  EXTRA="$(echo "$STATUS" | wc -l)"
  if [[ "$EXTRA" -gt 20 ]]; then
    echo "... ($((EXTRA - 20)) more)"
  fi
fi

# 4. Current branch.
echo ""
echo "--- branch ---"
git branch --show-current 2>/dev/null || echo "(detached)"

echo ""
echo "=== end startup ==="
exit 0
