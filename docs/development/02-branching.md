# 02 – Branching Strategy

Simple, modern, scalable **GitHub Flow** — one long-lived branch, short-lived feature branches, everything through pull requests.

## Only long-lived branch: `main`

- Always reflects the latest **stable, released** version of your action
- **Protected**: requires PR review + passing CI checks before merge
- **Never** commit or push directly to `main` — all changes go through PRs
- Every merge triggers CI validation + automatic release (via semantic-release)

## Short-lived branches for every change

**Naming convention**
`<type>/<short-kebab-case-description>`

**Allowed types** (lowercase, no spaces):

- `feat/`   – new features or capabilities
- `fix/`    – bug fixes
- `docs/`   – documentation-only changes
- `style/`  – formatting, whitespace, no behavior change
- `refactor/` – code cleanup, no behavior change
- `perf/`   – performance improvements
- `test/`   – adding/improving tests
- `chore/`  – maintenance, tooling, dependencies
- `ci/`     – CI/CD pipeline changes
- `build/`  – build system or external deps
- `revert/` – reverting a previous commit

**Good examples**
- `feat/add-log-level-input`
- `fix/handle-empty-who-to-greet`
- `docs/update-quick-start-section`
- `ci/add-matrix-testing-ubuntu-macos`
- `test/verify-output-on-empty-input`

**Bad examples (avoid)**
- `feature/add-input`
- `bugfix/empty-input`
- `my-cool-change`
- `fix-this-now-please`

## Typical workflow (copy-paste friendly)

```bash
# Start fresh from main
git checkout main
git pull origin main

# Create your branch
git checkout -b feat/add-timezone-support

# Work, test, commit
# … make changes …
make lint
make test-push
git commit -m "feat: add timezone input to greeting"

# Push & create PR
git push -u origin feat/add-timezone-support
```

Then on GitHub:
- Open PR
- Use conventional commit title (e.g. `feat: add timezone input`)
- Explain what, why, how to test in PR body
- Wait for CI (lint, tests, dry-run preview)
- Get review → **squash merge** (keeps history clean)
- Delete branch after merge

**Pro tip**: Enable “Automatically delete head branches” in repo settings.

Next → [03 – Conventional Commits](03-commits.md)
