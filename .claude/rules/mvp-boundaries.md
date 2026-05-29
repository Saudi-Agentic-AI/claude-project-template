# MVP Boundaries — What NOT to Build

Every project has features that look reasonable but are explicitly out of
scope. Listing them here makes "no" the default — you (or future Claude)
don't re-litigate the decision in every session.

## Fill this in per project

Replace the example list below with the real one for this project. Keep it
short and concrete. Each entry should explain *why* it's out of scope so the
reasoning survives.

### Out of scope for current milestone

| Feature | Why not now | When to revisit |
|---|---|---|
| Example: WebSocket endpoints | REST polling is enough for current users | If 10+ users request it |
| Example: Mobile app | Web covers the audience | After product-market fit |
| Example: Multi-tenancy | Single-tenant is faster to ship | When the first enterprise lead asks |

## How to use this list

When the user (or you) proposes a feature, check it against the table
**before** writing any code or design docs.

- If it matches: stop, surface the conflict, ask whether the user wants to
  revisit the boundary or skip the feature.
- If it doesn't match but is adjacent: ask. Better to clarify scope once
  than to ship the wrong thing.

The `/mvp-check <feature>` command does this lookup against the table
above.

## Why this exists

The single most common failure mode of a focused project is incremental
scope creep — each feature individually looks small, the cumulative drag
is enormous. A written boundary makes the "no" cheap. Without it, every
"can you also..." re-opens the conversation.

## When to add entries

Add a row to this table whenever:
- You catch yourself or the user starting to build something the project
  shouldn't build right now
- An incoming request is reasonable but out of milestone
- You make an explicit "not this milestone" trade-off

Add the rationale at the same time. "Not now" without a reason will be
re-debated in three months.
