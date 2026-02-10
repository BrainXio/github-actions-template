# 04 – Testing Locally

Fast, reliable local testing with **act** — simulate GitHub Actions on your machine without pushing every change.

## Why test locally?

- Instant feedback (seconds instead of minutes)
- Catch bugs before CI runs
- Debug with full logs and breakpoints
- Test multiple GitHub events (push, dispatch, pr, issues, release, schedule)
- Save CI minutes and avoid commit → push → wait → fix loops

## Prerequisites

- DevContainer is running (`Reopen in Container` already done)
- `make setup` has been executed at least once (installs act + dependencies)

If act is missing or errors out:

```bash
make setup
```

## Core testing commands (Makefile shortcuts)

```bash
make test-push       # Most common: simulate push event
make test-dispatch   # Manual workflow_dispatch (good for custom inputs)
make test-pr         # Pull request open/sync
make test-issues     # Issue created/edited
make test-release    # Release published event
make test-schedule   # Scheduled (cron) event

make tests           # Quick suite: push + dispatch + pr + issues
```

All commands use `--quiet --verbose` by default for clean yet informative output.

## Manual act commands (when you need more control)

```bash
# Basic push event
act push -W .github/workflows/into-main.yml

# Manual dispatch with custom input
act workflow_dispatch --input who-to-greet=Developer

# Pull request simulation
act pull_request --eventpath .github/events/pull-request-local.json -W .github/workflows/into-main.yml

# Verbose debugging
act push -W .github/workflows/into-main.yml --verbose

# Run only the test-action job
act push -j test-action -W .github/workflows/into-main.yml
```

## What to look for after a test run

- Action completes successfully (no red errors)
- Expected output appears (e.g. "Hello, World!", timestamp)
- Outputs are correctly set (check lines like `::set-output name=message::Hello, ...`)
- Logs respect log-level if you added one
- No shellcheck / lint warnings in CI steps

**Quick debug trick** — add temporary echoes:

```bash
echo "DEBUG: INPUT_WHO_TO_GREET = ${INPUT_WHO_TO_GREET:-unset}"
echo "DEBUG: Current event = $GITHUB_EVENT_NAME"
```

Then re-run `make test-push` and watch terminal.

## Common testing scenarios

**New input / output**
1. Add to `action.yml`
2. Use in `src/entrypoint.sh`
3. `make test-dispatch` → pass custom value
4. Verify output in terminal or `GITHUB_OUTPUT`

**Event-specific behavior**
```bash
make test-pr        # Does action behave correctly on PR?
make test-release   # Handles release event payload?
```

**Fixing a failure**
1. Run with `--verbose`
2. Read error messages carefully
3. Add debug echoes → re-test
4. Fix → `make test-push` should go green

**First run slow?**
act downloads Docker images (~5–15 GB once). Next runs are fast.

## Best practices

- Test **before** every commit/push
- Use `make test-*` shortcuts for consistency
- Test multiple events if your action cares about event type
- Always verify outputs — they’re usually the most important part
- Keep tests <10 seconds for smooth flow

Next → [05 – Adding New Features or Actions](05-adding-features.md)
