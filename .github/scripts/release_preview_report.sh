#!/usr/bin/env bash
set -euo pipefail

CURRENT_VERSION="unknown"
if [[ -f package.json ]]; then
  CURRENT_VERSION=$(jq -r '.version // "unknown"' package.json)
fi

NEXT_VERSION="unknown"
BUMP_TYPE=""

if [[ -f dry-run.log ]]; then
  BUMP_TYPE=$(grep -Ei 'bump|release type|publish as' dry-run.log | grep -oiE 'major|minor|patch' | head -1 || echo "")
  if [[ -n "$BUMP_TYPE" ]]; then
    NEXT_VERSION="predicted ${BUMP_TYPE} bump from v${CURRENT_VERSION}"
  elif grep -qiE 'no relevant changes|no new version' dry-run.log; then
    NEXT_VERSION="none (no changes detected)"
  else
    NEXT_VERSION="preview not computed on PR branch"
  fi
fi

{
  echo "### Release Preview"
  echo ""
  echo "**Current version**: v${CURRENT_VERSION}"
  echo "**Predicted next version**: ${NEXT_VERSION}"
  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Dry-run validation**: ✅ Passed"
  else
    echo "**Dry-run validation**: ⚠️ Failed"
  fi
  echo ""
  echo "Note: Full version preview only accurate after merge to main."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
