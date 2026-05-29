---
description: When and how to maintain PSD.md — the project's long-form architecture spec
---

# PSD Maintenance

`PSD.md` (Product Specification Document) is the **bible** for a project — the
long-form reference doc that captures what the system does, how it's built,
and why it's built that way. It complements (does not replace) `CLAUDE.md`.

## PSD vs. CLAUDE.md

| | CLAUDE.md | PSD.md |
|---|---|---|
| Length | Concise (< 100 lines) | Long (often 500+ lines) |
| Loaded | Auto, every session | On demand |
| Audience | Claude (primary), contributors (secondary) | Contributors (primary), Claude when relevant |
| Purpose | Per-session brief: stack, conventions, MVP boundaries, key contracts | Authoritative spec: full architecture, schema, decisions, roadmap |
| Update cadence | When defaults change | Same session as the architecture change — never later |

The two are complementary. CLAUDE.md says *"this project uses Railway +
Postgres"*. PSD.md says *"Railway because per-env isolation, managed plugins,
$20/mo; Postgres on the Railway plugin because of the JSONB columns we use in
the `events` table; previously evaluated SQLite (single-writer constraint
killed it) and Supabase (cost at >100k MAU)"*.

## When to fill in PSD.md

**Fill in for:**
- Any project with multiple contributors (now or planned)
- Any project with a lifespan > 3 months
- Any project where Claude will rejoin sessions weeks/months apart and need
  full context

**Skip for:**
- Throwaway scripts
- One-off prototypes
- Projects that will be rewritten before they're remembered

When in doubt, fill in just sections 1–4 (Overview, Reference Stack,
Architecture, Hosting Map) and add more as scope grows. Don't gate the first
PR on filling all 19 sections.

## Starting the file

```bash
cp PSD.md.example PSD.md
```

Fill TODOs incrementally as the project takes shape.

## Section tagging

Tag each section with its role:

- 🟢 **LIVE** — implemented and deployed today. Treat as ground truth.
- 🟡 **PLANNED** — committed direction; not yet implemented. Tracks future work.
- 🔵 **STANDARD PATTERN** — reusable across projects. Future projects copy from here.

When PLANNED becomes LIVE, change the tag in the same session as the
implementation.

## The hard rule: update same session, not later

When you change architecture — add a service, swap a vendor, restructure
auth, change the database schema in a non-trivial way — **update PSD.md in
the same session as the change**. Not "in the next PR". Not "when there's
time". Same session.

Why: the cognitive cost of writing the doc is lowest when you just made the
decision. Three days later it's twice the work because you have to
reconstruct the reasoning. Three months later it's effectively impossible.

This is the single most important PSD rule. Without it, PSD goes stale and
becomes lies — which is worse than no PSD.

## Decisions Log

Section 19 of PSD.md is the Decisions Log. It mirrors the one in
`project_tracker.md` but at different granularity:

- `project_tracker.md` Decisions Log: one row per decision, brief, focus on
  reversals
- `PSD.md` Decisions Log: full context — date, decision, rationale,
  alternatives considered, reversal cost

For small projects the tracker is enough. Once a project has its bible,
decisions live in PSD's Decisions Log and the tracker just references them.
