#!/usr/bin/env bash
# sync-env-example.sh — warn when env var references in code are missing from .env.example
# Wired via .claude/settings.json under hooks.PostToolUse for Edit|Write|MultiEdit.
#
# Scans the files Claude just touched for env var references
# (os.getenv, os.environ, process.env, os.Getenv) and exits 2 with a list
# of any keys not declared in .env.example.
#
# PostToolUse exit 2 surfaces stderr to Claude as a system message — it
# does NOT undo the edit. The intent is "you just wrote code that depends
# on a new env var; go declare it in .env.example".
#
# Configuration:
#   CLAUDE_SKIP_ENV_CHECK=1       — disable entirely
#   CLAUDE_ENV_IGNORE=K1,K2,...   — extend the platform-injected ignore list
#   CLAUDE_ENV_EXAMPLE_PATH=PATH  — point at non-root example file (default: .env.example)

set -uo pipefail

[[ "${CLAUDE_SKIP_ENV_CHECK:-}" == "1" ]] && exit 0
[[ -z "${CLAUDE_FILE_PATHS:-}" ]] && exit 0

ENV_EXAMPLE="${CLAUDE_ENV_EXAMPLE_PATH:-.env.example}"
[[ -f "$ENV_EXAMPLE" ]] || exit 0

# Vars injected by platforms / runtimes — never go in .env.example.
DEFAULT_IGNORE="PATH,HOME,USER,PWD,SHELL,LANG,LC_ALL,LC_CTYPE,TZ,EDITOR,TERM,DISPLAY,XDG_RUNTIME_DIR,XDG_CONFIG_HOME,CI,GITHUB_ACTIONS,GITHUB_TOKEN,GITHUB_SHA,GITHUB_REF,RUNNER_OS,NODE_ENV,PYTHONPATH,PYTHONUNBUFFERED,VIRTUAL_ENV,RAILWAY_GIT_COMMIT_SHA,RAILWAY_ENVIRONMENT,RAILWAY_PROJECT_ID,RAILWAY_SERVICE_ID,RAILWAY_GIT_BRANCH,VERCEL,VERCEL_ENV,VERCEL_URL,VERCEL_GIT_COMMIT_SHA,FLY_APP_NAME,FLY_REGION,FLY_ALLOC_ID,K_SERVICE,K_REVISION,K_CONFIGURATION,DYNO,HEROKU_APP_NAME,AWS_REGION,AWS_EXECUTION_ENV,AWS_LAMBDA_FUNCTION_NAME,PORT,HOST,DEBUG,NODE_OPTIONS"
IGNORE_RE="$(echo "${DEFAULT_IGNORE},${CLAUDE_ENV_IGNORE:-}" | tr ',' '\n' | grep -v '^$' | sort -u | tr '\n' '|' | sed 's/|$//')"

declare -A MISSING_MAP=()

for file in $CLAUDE_FILE_PATHS; do
  [[ -f "$file" ]] || continue

  # Skip tests / fixtures / migrations — convention.
  case "$file" in
    */test_*|*/tests/*|*_test.*|*/__tests__/*|*/fixtures/*|*/migrations/*|*/alembic/*)
      continue ;;
  esac

  # Extract env-key references per file extension.
  KEYS=""
  case "$file" in
    *.py)
      KEYS="$(grep -hoE '(os\.getenv|os\.environ\.get|os\.environ\[)\s*\(?[^)]*' "$file" 2>/dev/null \
        | grep -oE '[A-Z][A-Z0-9_]{2,}' || true)"
      ;;
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
      KEYS="$(grep -hoE 'process\.env\.[A-Z][A-Z0-9_]{2,}|process\.env\[[^]]+\]|import\.meta\.env\.[A-Z][A-Z0-9_]{2,}' "$file" 2>/dev/null \
        | grep -oE '[A-Z][A-Z0-9_]{2,}' || true)"
      ;;
    *.go)
      KEYS="$(grep -hoE 'os\.Getenv\([^)]+\)|os\.LookupEnv\([^)]+\)' "$file" 2>/dev/null \
        | grep -oE '[A-Z][A-Z0-9_]{2,}' || true)"
      ;;
    *.rb)
      KEYS="$(grep -hoE 'ENV\[[^]]+\]|ENV\.fetch\([^)]+\)' "$file" 2>/dev/null \
        | grep -oE '[A-Z][A-Z0-9_]{2,}' || true)"
      ;;
    *)
      continue
      ;;
  esac

  [[ -z "$KEYS" ]] && continue

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue

    # Skip ignored platform vars.
    if [[ -n "$IGNORE_RE" ]] && echo "$key" | grep -qE "^(${IGNORE_RE})$"; then
      continue
    fi

    # Already declared in .env.example? Lines starting with KEY= or # KEY=.
    if grep -qE "^[[:space:]]*#?[[:space:]]*${key}=" "$ENV_EXAMPLE"; then
      continue
    fi

    MISSING_MAP["$key"]="$file"
  done <<< "$KEYS"
done

[[ ${#MISSING_MAP[@]} -eq 0 ]] && exit 0

{
  echo "⚠️ sync-env-example.sh: env vars referenced in code but missing from $ENV_EXAMPLE:"
  echo ""
  for key in "${!MISSING_MAP[@]}"; do
    echo "  - $key   (referenced in ${MISSING_MAP[$key]})"
  done | sort
  echo ""
  echo "Add each as a commented placeholder in $ENV_EXAMPLE, e.g.:"
  echo ""
  echo "  # KEY — what it controls. Where to get this token."
  echo "  KEY="
  echo ""
  echo "See .claude/rules/secrets-and-env.md for the pattern."
  echo "Bypass with CLAUDE_SKIP_ENV_CHECK=1 or extend CLAUDE_ENV_IGNORE."
} >&2

exit 2
