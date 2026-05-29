# Coding Discipline

Cross-cutting rules that apply regardless of language or framework. For
language-specific conventions, see `.claude/rules/code-style.md`.

## No fake or placeholder data in production code paths

Never invent, mock, or hardcode fake data anywhere a real user could touch
it. No fake prices, fake user records, fake API responses, stub balances,
or "TODO replace with real data later" values.

- Test fixtures are the **only** acceptable place for fake data. Mark them
  clearly (place in `tests/fixtures/`, `conftest.py`, or filenames
  prefixed `fake_` / `stub_`).
- If real data is unavailable at runtime (vendor API down, missing config),
  **surface the error explicitly** — raise, log, return a clear error
  envelope. Never silently substitute invented values.
- If you are unsure whether a value is real or assumed: **stop and ask**.

## No stdout logging

Never use `print`, `console.log`, `fmt.Println`, `System.out.println`,
`puts`, or any other write-to-stdout for application logging.

Use the project's structured logger:
- Python: `structlog` or `logging` with a JSON formatter
- Node: `pino`, `winston`
- Go: `zap`, `zerolog`, `slog`
- Java/Kotlin: `slf4j` + `logback`
- Ruby: `Rails.logger`

Every log line should be JSON, carry a `timestamp`, and (where applicable)
a `request_id` for correlation.

`print`-style calls are fine in:
- One-off scripts (`scripts/`, `bin/`)
- Test files
- REPL / notebook usage

## Money is never a float

Use the language's decimal/big-decimal type for **all** monetary values —
prices, balances, fees, commissions, P&L, anything that compounds or sums.

- Python: `from decimal import Decimal`
- JavaScript: `BigInt` for whole units, `decimal.js` for fractions
- Go: `shopspring/decimal` or fixed-point integers
- Java/Kotlin: `BigDecimal`
- Ruby: `BigDecimal`

Float arithmetic on money causes off-by-cent bugs that compound silently
over millions of transactions. The cost of `Decimal` is a slightly more
verbose type signature. Take the trade.

## Type the boundaries

Every function that crosses a module boundary gets a type signature.
Internal helpers can skip annotations if the inference is obvious, but
public APIs, route handlers, service methods, and data classes are typed.

This applies to gradually-typed languages (Python, TypeScript, Ruby with
RBS, etc.). For inherently-typed languages, this is just "use the
compiler".

## Async is contagious

If the project uses async I/O (FastAPI, Node, Tokio, etc.), then:
- DB calls, HTTP calls, file I/O, queue operations are **all** `await`-ed
- No sync I/O in route handlers or service methods
- No mixing sync and async DB sessions in the same request
- Background tasks use the project's task primitive
  (`asyncio.create_task`, `tokio::spawn`, etc.), not a separate process model

If a single sync call appears in async code, it blocks the event loop.
Find and fix it.

## Errors at boundaries, trust inside

Validate input at the **edges** — HTTP request handlers, queue consumers,
file parsers, anywhere external data enters the system. Once inside, trust
the types. Do not write defensive checks for impossible states in internal
helpers.

Example: a `process_order(order: Order)` function should not re-validate
that `order.quantity > 0` if the constructor already enforced it. Use the
type system to make invalid states unrepresentable.

## Hooks that enforce these

- `block-stdout-logging.sh` — flags `print(` / `console.log` in app code
  (opt-in: enable in `settings.json` when you want it)
- `block-float-money.sh` — flags float types near money keywords (opt-in)

Add them when the project would benefit. For solo prototypes, the rules
alone are usually enough.
