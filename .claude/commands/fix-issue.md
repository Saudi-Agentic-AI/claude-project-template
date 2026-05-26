---
description: Fix a GitHub issue end-to-end — read the issue, plan, implement, test, open PR
argument-hint: <issue-number>
---

# Fix Issue

You will fix GitHub issue **#$ARGUMENTS** in this repository.

## Steps

1. **Fetch the issue.** Run `gh issue view $ARGUMENTS` to read the title, body, labels, and comments. If `gh` is not authenticated, stop and ask the user.

2. **Understand the codebase context.** Search for files relevant to the issue (use Grep on key terms from the issue body). Don't guess — read the actual code.

3. **Plan.** Before changing anything, write a short plan:
   - Root cause (if it's a bug) or design (if it's a feature)
   - Files you'll touch
   - Tests you'll add
   - Anything you're uncertain about
   
   Ask the user to confirm the plan before implementing.

4. **Branch.** Create a branch named `fix/issue-$ARGUMENTS-<short-slug>` or `feat/issue-$ARGUMENTS-<short-slug>` depending on the issue type.

5. **Implement.** Follow `.claude/rules/code-style.md`. Keep the change minimal — fix the issue, not adjacent concerns.

6. **Test.** Add or update tests per `.claude/rules/testing.md`. Run the test suite.

7. **Verify the original issue is resolved.** Re-read the issue. Does your change actually address what was reported? Trace through it mentally or with a manual run.

8. **Commit.** One commit unless the change is genuinely multi-step. Follow `.claude/rules/git-conventions.md`. Reference the issue: `Closes #$ARGUMENTS`.

9. **Open the PR.** `gh pr create` with a body that explains what changed, why, and how to verify. Link the issue.

## Stop and ask if

- The issue is ambiguous or has conflicting requirements
- The fix touches more than ~5 files or ~200 lines
- You need to make architectural decisions
- Tests reveal the bug is different from what the issue describes
