---
description: Refactor a piece of code without changing behavior, with tests as the safety net
argument-hint: <file-or-function>
---

# Refactor

You will refactor **$ARGUMENTS** without changing its observable behavior.

## Hard rules

1. **Tests first.** If there are no tests covering the target, write characterization tests *before* you change anything. Run them. They must pass against the current code.

2. **One refactor at a time.** Pick a single transformation: extract function, rename, inline, replace conditional with polymorphism, etc. Don't combine.

3. **Run tests after every change.** Not at the end — after every change. If tests break, revert immediately.

4. **No behavior changes.** Not even "obvious improvements." If you find a bug, stop and ask whether to fix it separately.

5. **No new features.** A refactor PR adds zero functionality.

## Process

1. Read the target code and any tests touching it.
2. Identify the smell you're addressing (long function, duplicated logic, unclear naming, tight coupling, etc.). State it explicitly.
3. Propose the refactor in one sentence. Get confirmation.
4. Make the smallest possible change toward the goal. Run tests.
5. Repeat until done.
6. Final diff review: does the new code make the *next* change easier? If not, you didn't actually refactor.

## What NOT to do

- Don't rewrite from scratch.
- Don't reformat unrelated code in the same commit.
- Don't change public APIs unless that's the explicit goal.
- Don't add abstractions you don't need *right now*.
