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
    elif grep -qiE 'error|failed|ERR' dry-run.log; then
      echo "→ Dry-run failed — check logs"
      echo '```text'
      tail -n 8 dry-run.log
      echo '```'
    else
      VERSION=$(grep -oE '([0-9]+\.)[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?' dry-run.log | head -1 || echo "unknown")
      echo "→ Next version preview: **v${VERSION}**"
    fi
  else
    echo "→ No dry-run.log found"
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"
