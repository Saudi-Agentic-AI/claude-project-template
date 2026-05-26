#!/usr/bin/env bash
# check-secrets.sh — block writes/edits that contain obvious secrets.
# Wired up via .claude/settings.json under hooks.PreToolUse.
#
# Returns exit 2 (= block the tool call) when a likely secret is detected.
# Returns exit 0 otherwise.
#
# This is a safety net, not a real secret scanner. Use gitleaks or similar in CI.

set -uo pipefail

# Stdin contains the tool call JSON. We pull the content to be written.
INPUT="$(cat)"

# Pull the candidate content. Hook input shape varies by tool; we grep broadly.
CONTENT="$(echo "$INPUT" | grep -Eo '"(content|new_string|file_text)"[[:space:]]*:[[:space:]]*"[^"]*"' | head -50)"

# Patterns that almost always indicate a real leak
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                       # AWS access key
  'sk-[A-Za-z0-9]{32,}'                    # OpenAI / generic API key
  'sk-ant-[A-Za-z0-9_-]{20,}'              # Anthropic API key
  'ghp_[A-Za-z0-9]{36,}'                   # GitHub PAT
  'github_pat_[A-Za-z0-9_]{60,}'           # GitHub fine-grained PAT
  'xox[baprs]-[A-Za-z0-9-]{10,}'           # Slack token
  '-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'  # Private keys
  'AIza[0-9A-Za-z_-]{35}'                  # Google API key
)

for pattern in "${PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qE "$pattern"; then
    echo "🚨 check-secrets.sh: refusing to write content that looks like a secret (matched: $pattern)." >&2
    echo "If this is a false positive, move the value to .env (gitignored) and reference it by name." >&2
    exit 2
  fi
done

exit 0
