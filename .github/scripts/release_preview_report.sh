#!/usr/bin/env bash
set -euo pipefail

CURRENT_BRANCH="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "preview-${GITHUB_RUN_ID:-local}")}"

git fetch --tags --force --prune || true

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

# Force local branch name at detached HEAD (PR merge commit)
git checkout -b "${CURRENT_BRANCH}" 2>/dev/null || true

# Bypass CI/PR detection, force branch, provide GH_TOKEN explicitly
unset GITHUB_ACTIONS
GH_TOKEN="${GITHUB_TOKEN}" \
  GITHUB_REF="refs/heads/${CURRENT_BRANCH}" \
  npx semantic-release --dry-run --no-ci --branches "${CURRENT_BRANCH}" > dry-run.log 2>&1 || true

# Better parsing: handle colors, different wording, take last match
NEXT_VERSION=$(grep -i 'next release version is' dry-run.log | sed 's/.*version is \([^ ]*\).*/\1/' | tail -1 | tr -d '[:space:]' || true)

if [[ -z "${NEXT_VERSION}" ]]; then
  if grep -qiE 'no .*changes|no new release|nothing to release|no relevant' dry-run.log; then
    NEXT_VERSION="${CURRENT_VERSION} (no bump)"
  else
    NEXT_VERSION="unknown / skipped - see log"
  fi
fi

{
  echo "### Release Preview"
  echo ""
  echo "**Current version**: ${CURRENT_VERSION}"
  echo "**Next version preview**: v${NEXT_VERSION}"
  echo ""
  if [[ -f dry-run.log ]]; then
    echo "Last 10 lines of dry-run.log:"
    echo '```text'
    tail -n 10 dry-run.log
    echo '```'
  fi
  echo "> Simple dry-run with CI bypass + explicit GH_TOKEN."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
