#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release Preview"
  echo ""

  # Get current version from last git tag
  CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags yet")
  echo "**Current version** (git tag): **${CURRENT_VERSION}**"

  if [[ -f dry-run.log ]]; then
    echo ""
    if grep -qiE 'no relevant changes|no new version' dry-run.log; then
      echo "→ No release triggered"
      NEXT_VERSION="none"
    elif grep -qiE 'error|failed|ERR' dry-run.log; then
      echo "→ Dry-run failed — check logs"
      echo '```text'
      tail -n 8 dry-run.log
      echo '```'
      NEXT_VERSION="failed"
    else
      NEXT_VERSION=$(grep -Ei 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9]+(\.[0-9]+)?)?' | head -1 || echo "unknown")
      echo "→ Next version preview: **v${NEXT_VERSION}**"
    fi
  else
    echo "→ No dry-run.log found"
    NEXT_VERSION="missing"
  fi

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Dry-run validation**: ✅ Passed"
  else
    echo "**Dry-run validation**: ⚠️ Failed"
  fi

  echo ""
  echo "> Note: On PR branches, semantic-release skips full version prediction (use main push for accurate preview)."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
