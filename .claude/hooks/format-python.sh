#!/usr/bin/env bash
# format-python.sh — auto-format Python files after Claude edits them.
# Wired up via .claude/settings.json under hooks.PostToolUse.
#
# Claude Code passes file paths via CLAUDE_FILE_PATHS (space-separated).
# This script silently no-ops if ruff isn't installed or the file isn't Python.

set -uo pipefail

# Bail early if no files were touched
[[ -z "${CLAUDE_FILE_PATHS:-}" ]] && exit 0

# Bail if ruff isn't on PATH
command -v ruff >/dev/null 2>&1 || exit 0

# Only touch .py files
for file in $CLAUDE_FILE_PATHS; do
  [[ "$file" == *.py ]] || continue
  [[ -f "$file" ]] || continue
  ruff format "$file" >/dev/null 2>&1 || true
  ruff check --fix "$file" >/dev/null 2>&1 || true
done

exit 0
