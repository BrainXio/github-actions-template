# 07 – Common Scenarios & Recipes

Real-world, copy-paste-ready examples of frequent tasks using this template — from first-day setup to advanced tweaks.

## Scenario 1: Fresh fork — first steps after creating repo

1. Customize basics in `action.yml`:
```yaml
name:        'My Custom Action'
description: 'Greets people in style'
author:      '@your-username'
branding:
  icon: 'smile'
  color: 'green'
```

2. Replace dummy logic in `src/entrypoint.sh` with your real code
3. Test immediately:
```bash
make setup      # if not auto-done
make test-push
```

4. Commit baseline:
```bash
git add .
git commit -m "feat: initialize custom action from template"
git push
```

Expected: CI runs, dry-run shows “No release” (normal until tagged)

## Scenario 2: Add new input + output + test it

Branch → `feat/add-emoji-input`

1. Update `action.yml`:
```yaml
inputs:
  emoji:
    description: 'Emoji to prepend'
    required: false
    default: '👋'

outputs:
  full-message:
    description: 'Complete message with emoji'
```

2. Update `src/entrypoint.sh`:
```bash
readonly EMOJI="${INPUT_EMOJI:-👋}"
readonly MESSAGE="${EMOJI} Hello, ${WHO_TO_GREET}!"

echo "$MESSAGE"
echo "full-message=$MESSAGE" >> "$GITHUB_OUTPUT"
```

3. Test locally:
```bash
make test-dispatch --input emoji=🚀 --input who-to-greet=Team
```

4. Commit & PR:
```bash
git commit -m "feat: add emoji input and full-message output"
```

After merge → minor version bump

## Scenario 3: Fix bug → trigger patch release

Branch → `fix/crash-on-null-input`

1. Fix code in `src/entrypoint.sh`
2. Commit:
```bash
git commit -m "fix: prevent crash when who-to-greet is empty or null"
```

3. Merge PR → automatic patch release (v1.2.3 → v1.2.4)

## Scenario 4: Test behavior on different GitHub events

```bash
make test-push       # normal commit/push
make test-dispatch   # manual trigger + custom inputs
make test-pr         # pull request open/sync
make test-issues     # issue created/edited
make test-release    # new release published
```

Use `act workflow_dispatch --input key=value` for custom input testing.

## Scenario 5: First release from scratch

1. Set baseline tag:
```bash
git tag -a v0.0.0 -m "Initial template baseline"
git push origin v0.0.0
```

2. Add releasable change:
```bash
git commit --allow-empty -m "feat: add first meaningful feature"
git push
```

3. Merge PR → automatic v0.1.0 release

## Scenario 6: Dry-run shows “No release” — quick fix

- No tags? → `git tag v0.0.0 && git push origin v0.0.0`
- No `feat:`/`fix:` since last tag? → add one
- Re-run dry-run via workflow_dispatch

## Scenario 7: CI / pre-commit fails locally

```bash
pre-commit run --all-files   # see exact errors
make lint                    # shellcheck issues
make check-secrets           # accidental secrets scan
```

Fix → re-commit.

Next → [08 – Troubleshooting](08-troubleshooting.md)
(or start using the template — you now have the full flow!)
