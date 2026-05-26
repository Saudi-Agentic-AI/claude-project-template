---
description: Formatting, naming, and structural conventions for this project
---

# Code Style

## Python (default for this template — adjust for your stack)

- **Formatter**: `ruff format` (auto-runs via PostToolUse hook). Line length: 100.
- **Linter**: `ruff check --fix`. All rules in `pyproject.toml`.
- **Type checking**: `mypy --strict` on `src/`. Type every public function.
- **Imports**: absolute imports inside `src/`. No `from .module import *`.
- **Strings**: double quotes. f-strings preferred over `.format()` or `%`.

## Naming

- `snake_case` for functions, variables, modules, DB columns
- `PascalCase` for classes, Pydantic models, SQLAlchemy models
- `SCREAMING_SNAKE_CASE` for module-level constants
- Private prefix: `_single_underscore`. Avoid `__double_underscore` unless you need name mangling.

## Structure

- One class per file when the class is the file's main export.
- Keep functions under ~50 lines. If longer, ask whether it should be split.
- Prefer pure functions; isolate side effects (I/O, DB, network) at boundaries.

## Comments

- Comments explain *why*, not *what*. The code already shows *what*.
- Update or remove stale comments. Don't leave `# TODO: figure out` without context.
- Use docstrings for all public functions and classes (Google style).

## What NOT to do

- Don't add abstraction layers "just in case." YAGNI.
- Don't write defensive code for impossible inputs in internal helpers.
- Don't catch exceptions you can't handle. Let them propagate.
