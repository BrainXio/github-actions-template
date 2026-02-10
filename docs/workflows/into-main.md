# CI + Release Workflow (into-main.yml)

## Introduction and Purpose

The `into-main.yml` workflow is the core automation pipeline for this GitHub Actions template repository. It serves multiple purposes:
- **Continuous Integration (CI)**: Ensures code quality through linting, testing, and validation on every relevant event.
- **Release Management**: Automates semantic versioning, changelog generation, and GitHub releases using conventional commits.
- **Dry-Run Preview**: Provides visibility into potential releases without actually publishing them.

This workflow is designed to be lightweight, secure, and extensible, aligning with 2026 best practices for GitHub Actions templates. It uses minimal permissions, caching for speed, and conditional logic to avoid unnecessary runs. The level of automation is high: it handles everything from basic linting to full release creation, but it's opt-in for users—easy to customize or disable by editing the file.

The workflow integrates **semantic-release** for automated releases based on conventional commits (e.g., `feat:`, `fix:`, `chore:`). This means no manual tagging or versioning is needed once set up; commits drive the process.

## Triggers

The workflow runs on a broad set of events to ensure the repo stays healthy:
- **push**: On pushes to `main` (e.g., merges, direct commits).
- **pull_request**: On PRs targeting `main` (e.g., open, synchronize).
- **issues**: On opened or edited issues (lightweight checks only).
- **release**: On published releases (triggers actual release job if needed).
- **workflow_dispatch**: Manual run from GitHub UI (great for testing).
- **schedule**: Daily at midnight UTC (for health checks and dry-runs).

This coverage means nearly every interaction with the repo gets at least a basic validation pass, but heavy jobs (like testing) are skipped on non-code events like issues.

## Jobs and Workings

The workflow is split into jobs with dependencies (`needs`), ensuring they run in sequence and only if previous ones succeed.

### 1. Validate Job
- **Purpose**: Early quality gate — catches syntax errors, commit format issues, and code smells before heavier testing.
- **When it runs**: On all events (but PR-only for commit message validation).
- **Steps and workings**:
  - Checkout the repo with full history (for accurate commit analysis).
  - Lint bash scripts using shellcheck (focuses on `src/` and `.devcontainer/` files).
  - Set up Python and install pre-commit.
  - Cache pre-commit environments for faster repeat runs.
  - Run all pre-commit hooks (shellcheck, detect-secrets, yaml validation, etc.) with `--show-diff-on-failure` for clear output.
  - (PR-only) Validate commit messages using `amannn/action-semantic-pull-request` — enforces conventional commits in PR titles.
- **Outcomes**:
  - Success: Green check, proceeds to next jobs.
  - Failure: Red X with detailed logs (e.g., "SC2010: Don't use ls | grep", "Invalid commit title").
  - High automation: Fully automatic linting and format checks — no manual reviews needed for basics.

### 2. Test-Action Job
- **Purpose**: Verifies the core action (e.g., hello-world) works as expected.
- **When it runs**: After validate succeeds, on all events except issues (to keep runs fast).
- **Steps and workings**:
  - Checkout the repo.
  - Run the local action (`uses: ./`) with a dynamic input based on the event name.
  - Verify outputs by echoing them (proves the action sets variables correctly).
- **Outcomes**:
  - Success: Confirms the action executes and outputs expected values (e.g., "Greeting time: 2026-02-08T14:00:00Z").
  - Failure: If the action crashes or outputs are missing, the job fails with logs.
  - Automation level: Fully tests the template's main deliverable (the action) on every code change.

### 3. Release-Dry-Run Job
- **Purpose**: Simulates a release to preview what would happen without publishing.
- **When it runs**: After test-action, on push, PR, dispatch, and schedule (skips on issues/release events).
- **Steps and workings**:
  - Checkout with full history.
  - Set up Node.js and install semantic-release + plugins.
  - Run `npx semantic-release --dry-run` and capture output (version, changelog preview) or errors.
  - Post a formatted comment to the PR (if on pull_request) showing pass/fail + details.
- **Outcomes**:
  - Pass: PR comment with "Next version: v0.1.0" + changelog preview.
  - Fail: PR comment with error details (e.g., "Invalid commit format").
  - Automation level: High — gives confidence before merging, no manual dry-runs needed.

### 4. Release Job
- **Purpose**: Performs the actual release (tag, changelog, GitHub release).
- **When it runs**: After dry-run, only on tag pushes (`refs/tags/v*`) or published releases.
- **Steps and workings**:
  - Checkout with full history.
  - Set up Node.js and install semantic-release + plugins.
  - Run `npx semantic-release` — analyzes commits since last tag, bumps version, generates changelog, creates tag/release.
- **Outcomes**:
  - Success: New GitHub release created (e.g., v0.1.0 with changelog).
  - Skip: If no releasable commits (e.g., only docs/chore), nothing happens.
  - Automation level: Fully automated versioning based on conventional commits.

## Level of Automation

- **Overall**: High — 80–90% automated. Linting, testing, and release previews happen without manual intervention. Releases are auto-triggered on qualifying merges/tags.
- **What requires human input**: Merging PRs, writing conventional commits, initial tag setup (see below), reviewing dry-run comments.
- **Extensibility**: Easy to add matrix OS testing, code coverage, or more plugins.

## When No Tags Exist Yet

If the repo has no tags (common in fresh templates), semantic-release won't detect releases until you create a baseline tag:
1. **Create initial tag** (e.g., v0.0.0):
   ```bash
   git tag v0.0.0
   git push origin v0.0.0
   ```
2. **Push a releasable commit** (e.g., `feat:` or `fix:`) to `main`.
3. **Trigger dry-run**: Manual workflow_dispatch or wait for schedule/push — it should now detect "next version".
4. **First release**: semantic-release will create v0.1.0 (or similar) on the next qualifying push.

Without tags, dry-run/release jobs may output "No release detected" — that's expected. Once tagged, everything flows automatically.

For troubleshooting:
- Check Actions logs for semantic-release output.
- Ensure conventional commits are used (e.g., `feat: add feature` triggers minor bump).
- If stuck, run locally: `npx semantic-release --dry-run`.
