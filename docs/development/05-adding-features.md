# 05 – Adding New Features or Actions

Step-by-step guide to safely extend your action with new inputs, outputs, logic, helpers, or completely new behavior — while keeping everything testable and release-ready.

## Quick checklist before you start

- Create a branch: `git checkout -b feat/your-feature-name`
- Update `action.yml` **first** (inputs, outputs, branding)
- Implement in `src/entrypoint.sh` (or new files in `src/lib/`)
- Test locally: `make test-push` or `make test-dispatch`
- Commit with conventional message: `feat: …` or `fix: …`
- Push → open PR → watch CI + dry-run preview

## Step-by-step process

### 1. Create branch
```bash
git checkout -b feat/add-log-level-and-message-output
```

### 2. Update action.yml (always first)

**Add input example**
```yaml
inputs:
  log-level:
    description: 'Log level (debug, info, warn, error)'
    required: false
    default: 'info'
```

**Add output example**
```yaml
outputs:
  message:
    description: 'The full greeting message produced'
```

**Optional: branding update**
```yaml
branding:
  icon: 'zap'
  color: 'yellow'
```

### 3. Implement logic in src/entrypoint.sh

Example: add log-level control + message output

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly WHO_TO_GREET="${INPUT_WHO_TO_GREET:-World}"
readonly LOG_LEVEL="${INPUT_LOG_LEVEL:-info}"

log() {
  local level="$1" msg="$2"
  case "$level" in
    debug) [[ "$LOG_LEVEL" == "debug" ]] && echo "DEBUG: $msg" >&2 ;;
    info)  echo "INFO: $msg" >&2 ;;
    warn)  echo "WARN: $msg" >&2 ;;
    error) echo "ERROR: $msg" >&2 ;;
  esac
}

log info "Starting greeting for $WHO_TO_GREET"

MESSAGE="Hello, ${WHO_TO_GREET}!"
echo "$MESSAGE"

# Set outputs
echo "time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> "$GITHUB_OUTPUT"
echo "message=$MESSAGE"                         >> "$GITHUB_OUTPUT"
```

**Best practices in scripts**
- Use `set -euo pipefail` everywhere
- Read inputs as `INPUT_XXX` (uppercase)
- Write outputs to `$GITHUB_OUTPUT`
- Keep functions small — move helpers to `src/lib/utils.sh` when >80–100 lines
- Source helpers: `source "${GITHUB_ACTION_PATH}/src/lib/utils.sh"`

### 4. Test locally

```bash
make test-push           # default inputs
make test-dispatch       # try custom log-level
act workflow_dispatch --input log-level=debug --input who-to-greet=TestUser
```

Check:
- Logs appear at correct level
- Output `message=Hello, TestUser!` is set
- No errors in terminal

### 5. Commit & push

```bash
git commit -m "feat: add log-level input and message output

- Controlled logging with debug/info/warn/error
- New output: message (full greeting text)
- Updated tests to verify log behavior

Closes #15"
git push -u origin feat/add-log-level-and-message-output
```

### 6. PR & merge

- Title follows commit style: `feat: add log-level input and message output`
- Body: explain change, why, how to test, before/after
- Wait for CI: lint, test-action, dry-run comment (should show minor bump)
- Review → **squash merge** → delete branch

### 7. Release happens automatically

- `feat:` → minor version bump (v1.2.0 → v1.3.0)
- Tag + GitHub release + changelog created on `main`

## Common extension patterns

**New output only**
→ Add to `action.yml` outputs
→ `echo "key=value" >> "$GITHUB_OUTPUT"`
→ Test: `make test-push` → check CI step output

**Reusable helper function**
→ Create `src/lib/logging.sh`
→ `source` it in entrypoint
→ Commit: `feat: add reusable logging helpers`

**Conditional logic**
→ Use new input to branch behavior
→ Test all paths: `make test-dispatch` with different inputs

**Change branding**
→ Update `branding` in `action.yml`
→ Commit: `style: update action icon and color`

Next → [06 – Releasing a New Version](06-releasing.md)
