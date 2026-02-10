#!/usr/bin/env bash
set -euo pipefail

# Get PR branch name (GITHUB_HEAD_REF is set in PRs)
CURRENT_BRANCH="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
  CURRENT_BRANCH="preview-${GITHUB_RUN_ID:-$(date +%s)}"
fi

# Fetch tags
git fetch --tags --force --prune || true

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

# In PRs, checkout is detached at merge commit — name it to mimic a real branch
git checkout -b "${CURRENT_BRANCH}" || true  # Creates local branch at HEAD

# Run dry-run with CI bypassed + branch forced + REF faked
unset GITHUB_ACTIONS
GITHUB_REF="refs/heads/${CURRENT_BRANCH}" \
  npx semantic-release --dry-run --no-ci --branches "${CURRENT_BRANCH}" > dry-run.log 2>&1 || true
DRY_RUN_EXIT=$?

# Parse next version
NEXT_VERSION=$(grep -Eai 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.+]+)?' | tail -1 || true)

if [[ -z "$NEXT_VERSION" ]]; then
  if [[ $DRY_RUN_EXIT -ne 0 ]]; then
    NEXT_VERSION="error (exit=$DRY_RUN_EXIT)"
  elif grep -qiE 'no .*changes|no new release|nothing to release|no relevant' dry-run.log; then
    NEXT_VERSION="${CURRENT_VERSION} (no bump)"
  else
    NEXT_VERSION="unknown / skipped"
  fi
fi

VALIDATION=$([[ $DRY_RUN_EXIT -eq 0 ]] && echo "✅ Passed" || echo "⚠️ Issue (code $DRY_RUN_EXIT)")

# Job summary
{
  echo "### Release Preview"
  echo ""
  echo "**Current version**: ${CURRENT_VERSION}"
  echo "**Next version preview**: v${NEXT_VERSION}"
  echo "**Dry-run validation**: ${VALIDATION}"
  echo ""
  if [[ -f dry-run.log ]]; then
    echo "Last 10 lines of dry-run.log:"
    echo '```text'
    tail -n 10 dry-run.log || echo "(no log content)"
    echo '```'
  else
    echo "→ No dry-run.log generated"
  fi
  echo ""
  echo "> Note: Preview uses local branch naming + overrides to mimic local dry-run success in PR context."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
