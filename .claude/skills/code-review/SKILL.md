---
name: code-review
description: "Perform a thorough code review of staged changes or a specified PR/branch. Use when the user asks to review code, check a PR, or audit recent changes."
---

# Code Review

## When to use

Trigger this when the user says any of:
- "review my changes"
- "review this PR"
- "audit the diff"
- "check before I commit"
- "code review"

## Process

1. **Determine scope.** If unspecified, default to `git diff --staged`. Otherwise compare against the branch the user names (e.g. `git diff main...HEAD`).
2. **Read the diff in full** before commenting. Don't review file-by-file in isolation.
3. **Check against these dimensions, in this order:**

   **Correctness** (highest priority)
   - Does the code do what it claims to do?
   - Are edge cases handled? (empty inputs, nulls, max/min values, concurrent access)
   - Are error paths actually exercised, or just `except: pass`?

   **Security**
   - Any secrets, tokens, or PII in committed code?
   - SQL injection, command injection, path traversal risks?
   - Authentication/authorization on new endpoints?
   - Input validation at trust boundaries?

   **Performance**
   - Obvious N+1 queries?
   - Sync I/O in async paths?
   - Loading large datasets into memory unnecessarily?

   **Maintainability**
   - Does it follow conventions in `.claude/rules/code-style.md`?
   - Names tell you what the code does?
   - Functions doing one thing?
   - Tests included? (see `.claude/rules/testing.md`)

   **Style** (lowest priority)
   - Formatting, naming nits. Only mention if the formatter didn't catch them.

4. **Group findings by severity:**
   - 🔴 **Blocker** — must fix before merge
   - 🟡 **Should fix** — fix before merge unless there's a good reason
   - 🔵 **Suggestion** — consider, but author's call
   - 💭 **Question** — author clarify

5. **Be specific.** Quote the offending line, explain *why* it's a problem, suggest a fix.

6. **End with a summary verdict**: ✅ approve / 🔄 request changes / ❌ reject, and a one-line rationale.

## What NOT to do

- Don't restate what the diff does. The author wrote it.
- Don't bikeshed on style the formatter already handles.
- Don't comment on every line. Pick what matters.
- Don't approve code you didn't actually read.
