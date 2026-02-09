# 03 – Conventional Commits

Lightweight, powerful convention for commit messages that enables **automatic versioning**, **changelogs**, and **readable history**.

## Why Conventional Commits?

- Drives semantic-release → patch/minor/major bumps without manual tags
- Generates clean, grouped changelogs automatically
- Makes `git log` actually useful
- Enforced by CI → prevents bad messages from merging
- Becomes natural after 5–10 commits

## Basic format

```
<type>[optional scope]: <short description>

[optional body – explain why, not what]

[optional footer(s)]
```

- **type** (required) – lowercase, from allowed list
- **scope** (optional) – e.g. `action`, `entrypoint`, `ci`, `readme`
- **short description** – imperative mood, lowercase, **no period at end**
- **body** – wrapped at ~72 chars, explains motivation/context
- **footer** – e.g. `BREAKING CHANGE:`, `Closes #42`, `Fixes #17`

## Allowed types

Type       | Meaning                              | Version bump | Changelog?
-----------|--------------------------------------|--------------|-----------
`feat`     | New feature or capability            | minor        | Yes
`fix`      | Bug fix                              | patch        | Yes
`docs`     | Documentation only                   | none         | No
`style`    | Formatting/whitespace (no logic)     | none         | No
`refactor` | Code restructure (no behavior change)| none         | No
`perf`     | Performance improvement              | patch        | Yes
`test`     | Adding/correcting tests              | none         | No
`chore`    | Maintenance, tooling, deps           | none         | No
`ci`       | CI/CD config changes                 | none         | No
`build`    | Build system / external deps         | none         | No
`revert`   | Revert previous commit               | none         | No

**Breaking change**: Add `!` after type (`feat!:`) **or** footer `BREAKING CHANGE:` → major bump

## Good commit message examples

**New feature**
```
feat: add timezone input to greeting

Allows custom timezone for output timestamp.
Uses UTC by default if unset.

Closes #12
```

**Bug fix with scope**
```
fix(entrypoint): handle empty who-to-greet gracefully

Prevents crash when input is empty string or whitespace.
```

**Docs only**
```
docs: improve quick-start section in README
```

**CI change**
```
ci: add matrix testing for ubuntu-latest and windows-2022
```

**Breaking change**
```
feat!: change default greeting to uppercase

BREAKING CHANGE: Greeting is now uppercase by default.
Update consumers accordingly.
```

**Revert**
```
revert: feat: add timezone input

This reverts commit 7f3b2a1 due to timezone edge cases.
```

## Bad commit messages (will fail CI validation)

```
added timezone
bugfix empty input
update readme
refactored some code
fix stuff
```

## Quick cheat sheet

Change type          | Commit prefix   | Version bump | Appears in changelog?
---------------------|-----------------|--------------|----------------------
New feature          | `feat:`         | minor        | Yes
Bug fix              | `fix:`          | patch        | Yes
Breaking change      | `feat!:` or footer | major     | Yes
Docs / formatting    | `docs:`, `style:` | none      | No
Refactor / tests     | `refactor:`, `test:` | none   | No
Maintenance / CI     | `chore:`, `ci:` | none         | No

## Tips for writing great messages

1. Always start with type (`feat:`, `fix:`, etc.)
2. Keep subject line ≤ 50–60 chars
3. Use lowercase for description, imperative mood (“add”, “fix”, not “added”, “fixed”)
4. No period at end of subject
5. Explain **why** in body (code already shows **what**)
6. Reference issues: `Closes #123`, `Fixes #456`

Try it now:

```bash
git commit --allow-empty -m "feat: test conventional commit format"
```

Push → open PR → watch CI validate it instantly.

Next → [04 – Testing Locally](04-testing.md)
