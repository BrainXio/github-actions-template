#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release Preview"
  echo ""

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Dry-run OK"
  else
    echo "**Status**: ⚠️ Dry-run issue"
  fi

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
      # Extract version more reliably (common patterns in semantic-release output)
      NEXT_VERSION=$(grep -oE '([0-9]+\.){2}[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?' dry-run.log | head -1 || echo "unknown")
      echo "→ Next version preview: **v${NEXT_VERSION}**"
    fi
  else
    echo "→ No dry-run.log found"
    NEXT_VERSION="missing"
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"

# Write just the version for the final reporter
echo "NEXT_VERSION=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
