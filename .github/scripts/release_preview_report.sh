#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# 1. Determine branch name safely (PR or push)
# ────────────────────────────────────────────────
CURRENT_BRANCH="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" = "HEAD" ]]; then
  CURRENT_BRANCH="preview-$(date +%s)"
fi

# ────────────────────────────────────────────────
# 2. Fetch tags (needed for last version detection)
# ────────────────────────────────────────────────
git fetch --tags --force --prune || true

# ────────────────────────────────────────────────
# 3. Create temporary local-only config that allows current branch
#    → overrides .releaserc.json branches only for this dry-run
# ────────────────────────────────────────────────
cat > .releaserc.preview.json <<EOF
{
  "extends": "./.releaserc.json",
  "branches": ["${CURRENT_BRANCH}", "main"],
  "ci": false,
  "dryRun": true
}
EOF

# ────────────────────────────────────────────────
# 4. Run dry-run with local config override
# ────────────────────────────────────────────────
unset GITHUB_ACTIONS   # just in case — helps bypass some CI skips
npx semantic-release --config .releaserc.preview.json --no-ci > dry-run.log 2>&1
DRY_RUN_EXIT=$?

# ────────────────────────────────────────────────
# 5. Cleanup temp file
# ────────────────────────────────────────────────
rm -f .releaserc.preview.json

# ────────────────────────────────────────────────
# 6. Parse outputs
# ────────────────────────────────────────────────
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

NEXT_VERSION=$(grep -Eai 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.+]+)?' | tail -1 || true)

if [[ -z "$NEXT_VERSION" ]]; then
  if [[ $DRY_RUN_EXIT -ne 0 ]]; then
    NEXT_VERSION="error (exit=$DRY_RUN_EXIT)"
  elif grep -qiE 'no .*changes|no new release|no relevant|nothing to release' dry-run.log 2>/dev/null; then
    NEXT_VERSION="${CURRENT_VERSION} (no bump)"
  else
    NEXT_VERSION="unknown / skipped"
  fi
fi

# ────────────────────────────────────────────────
# 7. Validation status
# ────────────────────────────────────────────────
if [[ $DRY_RUN_EXIT -eq 0 ]]; then
  VALIDATION="✅ Dry-run passed"
else
  VALIDATION="⚠️ Dry-run issue (code $DRY_RUN_EXIT)"
fi

# ────────────────────────────────────────────────
# 8. Write to step summary (visible in job log & PR checks)
# ────────────────────────────────────────────────
{
  echo "### Release Preview"
  echo ""
  echo "**Current version** (git tag): **${CURRENT_VERSION}**"
  echo "**Next version preview**: **v${NEXT_VERSION}**"
  echo "**Validation**: ${VALIDATION}"
  echo ""
  if [[ -f dry-run.log ]]; then
    echo "Last 10 lines of dry-run.log:"
    echo '```text'
    tail -n 10 dry-run.log || echo "(empty)"
    echo '```'
  else
    echo "→ No dry-run.log generated"
  fi
  echo ""
  echo "> Note: Preview calculated from current branch/PR commits only (using temporary config override)."
} >> "$GITHUB_STEP_SUMMARY"

# ────────────────────────────────────────────────
# 9. Output for use in reporter comment
# ────────────────────────────────────────────────
echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
