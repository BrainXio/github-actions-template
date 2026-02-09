# 09 – Cheat Sheet

One-page quick reference for the entire GitHub Actions Template workflow.

## 1. First-Time Setup

```bash
# Open repo → Reopen in Container (VS Code / Codespaces)
# Wait for auto-setup (2–6 min first time)
make setup          # manual re-run if needed
make help           # see all commands
```

## 2. Daily Commands

```bash
make lint             # shellcheck
make check-secrets    # secret scan
make test-push        # quick local test (most used)
make tests            # push + dispatch + pr + issues
make validate         # dry-run full CI
```

## 3. Branch Naming

```
<type>/<kebab-case-description>

feat/ fix/ docs/ style/ refactor/ perf/ test/ chore/ ci/ build/ revert/
```

Good: `feat/add-json-output`, `fix/crash-on-null`, `ci/add-windows-runner`
Bad: `feature/xyz`, `bugfix`, `my-change`

## 4. Conventional Commits

```
<type>[scope]: short description (≤60 chars, lowercase, no period)

[optional body – why]

[optional footer: BREAKING CHANGE:, Closes #42]
```

Bump rules
`feat:`     → minor
`fix:`      → patch
`feat!:` or `BREAKING CHANGE:` → major
`docs: chore: ci: test: style: refactor:` → no bump

Examples
`feat: add emoji input`
`fix(entrypoint): handle empty input`
`docs: clarify input defaults`
`ci: add macos-14 runner`

## 5. Typical Change Flow

```bash
git checkout main && git pull
git checkout -b feat/add-cool-input

# edit action.yml + src/entrypoint.sh
make lint
make test-push
make test-dispatch --input key=value   # custom test

git commit -m "feat: add cool input with validation"
git push -u origin HEAD
```

→ Open PR → squash merge → auto-release

## 6. Local Testing Quick Reference

```bash
make test-push
make test-dispatch
make test-pr
make test-issues
make test-release

act workflow_dispatch --input who-to-greet=Test --verbose
```

Check: outputs in terminal, `$GITHUB_OUTPUT` lines, no red errors

## 7. First Release (one-time)

```bash
git tag -a v0.0.0 -m "Baseline"
git push origin v0.0.0

# then add a feat:/fix: commit → merge → v0.1.0 auto-created
```

Want v1.0.0 start? → `git tag -a v1.0.0 ...`

## 8. Release Rules at a Glance

Commit type       | Version bump | Changelog?
------------------|--------------|-----------
`feat:`           | minor        | Yes
`fix:`            | patch        | Yes
`feat!:` / `BREAKING CHANGE:` | major | Yes
`docs: style: chore: ci: test: refactor:` | none | No

## 9. Common Fixes – 30 seconds

- No release? → `git tag v0.0.0 && git push origin v0.0.0` + feat/fix commit
- act slow first time? → wait (downloads images)
- pre-commit fails? → `pre-commit run --all-files`
- Output missing? → check `>> "$GITHUB_OUTPUT"`
- Wrong bump? → verify commit prefix

Happy shipping!
