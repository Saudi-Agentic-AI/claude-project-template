---
description: Append a session-end checkpoint to project_tracker.md
argument-hint: (optional note to include in the entry)
---

# Checkpoint

Append a session-end checkpoint entry to `project_tracker.md` at the repo
root, following the format defined in
`.claude/rules/project-tracker-discipline.md`.

## Steps

1. **Confirm context.** Run, in parallel:
   - `git status --short` — what's modified
   - `git diff --stat` — scope of changes
   - `git log --oneline -10` — recent commits
   - `date '+%Y-%m-%d %H:%M %Z'` — current timestamp

2. **Read the tail of `project_tracker.md`** (last ~80 lines) to:
   - Confirm the file's existing format (some projects vary slightly)
   - See the last checkpoint's "Next Session" line — that's what this
     session was supposed to do; compare against what actually happened
   - If the file does not exist, create it with this header:

     ```markdown
     # Project Tracker

     The single source of truth for project progress. Updated at the end
     of every Claude Code session per
     `.claude/rules/project-tracker-discipline.md`.

     ## Decisions Log

     | Date | Decision | Rationale |
     |---|---|---|
     ```

3. **Draft the entry** in the format below. Use the actual timestamp from
   step 1. Be specific — file paths, test names, commit hashes — not
   vague summaries.

   ```markdown
   ## Checkpoint — YYYY-MM-DD HH:MM <TZ>

   ### Completed
   - <file or feature, with one-line context>
   - ...

   ### Tested
   - <what was tested + result, or "Not tested — <reason>">

   ### Blockers / Open Questions
   - <unresolved item, or "None">

   ### Next Session
   - <first task to pick up>
   ```

4. **Append** the entry to `project_tracker.md` (do not overwrite
   anything; append after the last existing line).

5. **Report** to the user: one line confirming the entry was added,
   and the "Next Session" item you wrote (so they can correct it if
   needed before the session closes).

## If `$ARGUMENTS` is non-empty

Treat it as a note to include verbatim under "Completed" as the first
bullet, then continue with the auto-detected changes.

## Do not

- Do not commit `project_tracker.md` automatically — leave that to the
  user (they may want to bundle it with the work commit).
- Do not invent test results. If you can't confirm a test ran, write
  "Not tested — <reason>" honestly.
- Do not skip the entry because the session was short. 10-minute
  sessions still get a checkpoint per the rule.
