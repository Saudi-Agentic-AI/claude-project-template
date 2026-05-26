---
description: What to test, how to test, coverage expectations
---

# Testing

## Stack

- `pytest` + `pytest-asyncio` for async tests
- `pytest-cov` for coverage
- `httpx.AsyncClient` for FastAPI endpoint tests (no live server)
- `freezegun` for time-dependent tests

## What to test

- **Business logic**: every branch, every error path
- **API endpoints**: happy path + at least one validation error + one auth error
- **Data integrity**: anything writing to the DB
- **Edge cases that bit you before**: regression test on every bug fix

## What NOT to test

- Third-party library internals (trust the library)
- Trivial getters/setters
- Mocked-into-meaninglessness "tests" that just assert mocks were called

## Structure

- Tests mirror source tree: `src/foo/bar.py` → `tests/foo/test_bar.py`
- One assertion concept per test. Name tests `test_<what>_when_<condition>_then_<expected>`.
- Fixtures in `conftest.py` at the closest common ancestor. Don't import fixtures.
- Async tests: mark with `@pytest.mark.asyncio` (or set `asyncio_mode = "auto"` in pyproject).

## Coverage

- Target: 85% on `src/`. Not negotiable on new code in critical paths (auth, payments, data writes).
- Coverage is a smoke alarm, not a quality metric. 100% coverage of bad tests still misses bugs.

## Running

```bash
pytest                          # full suite
pytest tests/foo/test_bar.py    # single file
pytest -k "test_login"          # by name pattern
pytest --cov=src --cov-report=term-missing
```
