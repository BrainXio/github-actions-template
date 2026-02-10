#!/usr/bin/env bash
set -euo pipefail

# Prefer GITHUB_HEAD_REF in PR context; fallback to current branch
CURRENT_BRANCH="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
  CURRENT_BRANCH="preview-${GITHUB_RUN_ID:-local}"
fi

# Fetch tags so we can find last release
git fetch --tags --force --prune || true

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

# Run dry-run, disable CI detection + force branch match
unset GITHUB_ACTIONS
npx semantic-release --dry-run --no-ci --branches "${CURRENT_BRANCH}" > dry-run.log 2>&1
DRY_RUN_EXIT=$?

# Extract next version line (more robust parsing)
NEXT_VERSION=$(grep -Eai 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.+]+)?' | tail -1 || true)

if [[ -z "$NEXT_VERSION" ]]; then
  if [[ $DRY_RUN_EXIT -ne 0 ]]; then
    NEXT_VERSION="error (exit $DRY_RUN_EXIT)"
  elif grep -qiE 'no .*changes|no new release|nothing to release|no relevant' dry-run.log; then
    NEXT_VERSION="${CURRENT_VERSION} (no bump)"
  else
    NEXT_VERSION="unknown / skipped"
  fi
fi

# Validation status
if [[ $DRY_RUN_EXIT -eq 0 ]]; then
  VALIDATION="✅ Dry-run passed"
else
  VALIDATION="⚠️ Dry-run issue (code $DRY_RUN_EXIT)"
fi

# Write to job summary
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
  echo "> Note: Preview forced via --branches override + CI detection disabled (mimics local dry-run behavior)."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
