# Troubleshooting

Common issues and how to fix them.

---

## Setup and authentication

### `gh repo create` fails with 403 or SSO error

Your GitHub token isn't authorized for the org's SAML SSO. Fix:

```bash
gh auth refresh -h github.com -s admin:org
```

Follow the browser prompt to authorize the token for the org specifically. Then retry.

### `gh auth status` shows two accounts but creates repos under the wrong one

The "Active account" is what `gh` uses. Switch:

```bash
gh auth switch --user <correct-account>
gh auth status      # confirm "Active account: true" on the right one
```

If you frequently switch, set the active account per-shell with `GH_HOST` or use account-specific aliases.

### Want to confirm which account has access to which org

```bash
gh api user/orgs --jq '.[].login'        # for the active account

gh auth switch --user <other-account>
gh api user/orgs --jq '.[].login'        # for the other
```

---

## Claude Code not picking up config

### Claude doesn't seem to know about `CLAUDE.md`

Check:

1. Are you running `claude` from the project root (where `CLAUDE.md` lives)? Claude Code reads from the working directory.
2. Is the file actually named `CLAUDE.md`? Case-sensitive. Not `claude.md` or `Claude.md`.
3. Run `/memory` inside Claude to see what's in context.

If `CLAUDE.md` is in a subdirectory, Claude Code reads the one closest to the working directory upward. Move it to the repo root.

### Rules in `.claude/rules/` aren't being followed

Possible causes:

- **Not referenced**: rules with no `applies-to` frontmatter need to be referenced from `CLAUDE.md` to load. Add a link or a brief reference.
- **`applies-to` doesn't match**: check the glob pattern against the actual file paths Claude is touching. `**/migrations/**` matches `src/db/migrations/file.py` but not `migrations/file.py` without the leading `**`.
- **Rule is too vague**: "write good code" won't change behavior. Specific enforceable rules work; aspirational ones don't.

### Skills aren't auto-invoking

The `description` is what Claude uses to decide. If the description doesn't contain the trigger phrases the user is saying, Claude won't invoke it.

Good description:
```
description: "Deploy to Railway. Use when user says: deploy, ship, release, push to prod."
```

Bad description:
```
description: "Deployment helper"
```

Test by asking Claude directly: "What skills do you have available for deployment?"

### Slash commands don't appear

- File must be in `.claude/commands/` (not nested deeper)
- Must have `.md` extension
- Filename becomes the command: `db-migrate.md` → `/db-migrate`
- Restart the Claude session — commands are scanned on startup

---

## Hooks

### Hook doesn't run

Check, in order:

1. **Is the script executable?** `ls -la .claude/hooks/` — should show `-rwxr-xr-x`. If not: `chmod +x .claude/hooks/*.sh`.
2. **Is it wired in `settings.json`?** The script existing isn't enough — it has to be referenced under `hooks.PreToolUse` or `hooks.PostToolUse`.
3. **Does the matcher actually match?** `"matcher": "Edit"` only matches the `Edit` tool. Use `"Edit|Write|MultiEdit"` to cover file modifications. Use `"*"` to match everything.
4. **Is the command path correct?** Hooks run from the project root. Use `.claude/hooks/foo.sh`, not `./foo.sh`.

Debug by adding logging to the hook:

```bash
#!/usr/bin/env bash
echo "$(date): hook fired, CLAUDE_FILE_PATHS=$CLAUDE_FILE_PATHS" >> /tmp/claude-hook.log
# ... rest of script
```

Then watch `/tmp/claude-hook.log` while you trigger the hook.

### Hook blocks legitimate operations

If `check-secrets.sh` (or another `PreToolUse` hook) returns exit 2 incorrectly, it blocks Claude. Two options:

1. **Tune the hook**: adjust the patterns/heuristics. Most "false positives" are real signals worth investigating.
2. **Temporarily disable**: comment out the matcher in `settings.json` and re-enable after fixing.

For real-but-intentional secrets in code (very rare), the right answer is *don't*. Move secrets to env vars or a vault.

### Hook is slow and lags every edit

Hooks run synchronously on every matching tool call. A 3-second hook on `PostToolUse:Edit|Write` means every file edit waits 3 seconds.

Mitigate:

- Background long work: `mypy src/ &` instead of waiting
- Cache results: only run linter if the file's mtime changed
- Move slow checks to CI instead of hooks

---

## Permissions

### Claude keeps asking for permission for a command you've allowed

The allow rule isn't matching. Patterns:

- `Bash(npm test)` — matches exactly `npm test`, nothing else
- `Bash(npm test:*)` — matches `npm test --watch`, `npm test foo`, etc.
- `Bash(npm:*)` — matches any npm command
- `Bash(*)` — matches any bash command (too broad; avoid)

Use the most specific pattern that covers what you need.

### A `deny` rule is too aggressive

Deny rules always win over allow rules. Check the deny list in both `settings.json` and `settings.local.json`. If your team's `settings.json` denies something you need for your machine specifically, add an allow rule in `settings.local.json` *and* make sure no deny rule overrides it (you can't override a deny).

If a team-level deny is blocking legitimate work, that's a team discussion. Propose updating `settings.json` via PR.

### Want to see what Claude is allowed to do right now

Run inside Claude: `/permissions` (or check `settings.json` directly).

---

## Two-account git operations

When you have both `jafaralbinmousa` and `jafarbindersa` set up in `gh`, `git` itself doesn't know about that — `gh` does. For pushes from a repo:

- If the remote URL uses HTTPS, `gh`'s credential helper handles auth.
- If it uses SSH, the SSH key on your machine determines which account is used.

To force a specific account for a specific repo:

```bash
# Set the user for a single repo
cd <repo>
git config user.email "your-email-for-this-account@example.com"
git config user.name "Jafar Albinmousa"

# Or, use SSH config aliases (if you have separate SSH keys)
# In ~/.ssh/config:
#   Host github-personal
#     HostName github.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519_personal
#   Host github-binder
#     HostName github.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519_binder
# Then: git remote set-url origin git@github-personal:user/repo.git
```

---

## When something is genuinely broken

1. **Check the Claude Code changelog**: https://code.claude.com/docs/en/changelog — recent versions may have changed behavior.
2. **Update Claude Code**: `npm i -g @anthropic-ai/claude-code` or whichever method you used.
3. **Check the docs**: https://code.claude.com/docs/en/claude-directory is authoritative for file structure and loading rules.
4. **Run with `--debug`**: `claude --debug` writes detailed logs to `~/.claude/debug/`.
5. **Search GitHub issues**: https://github.com/anthropics/claude-code/issues — someone may have hit your problem.

---

## Resetting

### Clear all state for one project

```bash
claude project purge ~/path/to/project
```

Shows the deletion plan, asks for confirmation. Use `--dry-run` to preview.

### Clear all state for all projects

```bash
claude project purge --all
```

This nukes session transcripts, file snapshots, and prompt history. It does not touch your config (`CLAUDE.md`, `settings.json`, etc.) — that's safe.

### Start completely fresh

```bash
rm -rf ~/.claude/projects/<project-hash>
```

If you don't know the hash, `claude project purge` is safer.
