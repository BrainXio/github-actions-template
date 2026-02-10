#!/usr/bin/env bash
set -euo pipefail

# Force fetch tags
git fetch --tags --force --prune || true

# Run dry-run with branch override
npx semantic-release --dry-run --branches "${GITHUB_HEAD_REF:-main}" > dry-run.log 2>&1 || true

# Now the log is guaranteed in current dir
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

NEXT_VERSION="unknown"
if [[ -f dry-run.log ]]; then
  tail -n 10 dry-run.log >> "$GITHUB_STEP_SUMMARY"  # debug

  if grep -qiE 'no relevant changes|no new version' dry-run.log; then
    NEXT_VERSION="none"
  elif grep -qiE 'error|failed|ERR' dry-run.log; then
    NEXT_VERSION="failed"
  else
    NEXT_VERSION=$(grep -Ei 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9]+(\.[0-9]+)?)?' | tail -1 || echo "unknown")
  fi
else
  NEXT_VERSION="missing (log not created)"
fi

{
  echo "### Release Preview"
  echo ""
  echo "**Current version** (git tag): **${CURRENT_VERSION}**"
  echo "**Next version preview**: **v${NEXT_VERSION}**"
  echo "**Dry-run validation**: ${{ JOB_STATUS == 'success' && '✅ Passed' || '⚠️ Issue' }}"
  echo ""
  echo "> Note: Preview uses --branches override."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
