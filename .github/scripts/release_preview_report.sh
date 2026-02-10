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

  NEXT_VERSION="unknown"

  if [[ -f dry-run.log ]]; then
    echo ""
    cat dry-run.log | tail -n 15 >> "$GITHUB_STEP_SUMMARY"   # debug tail for visibility

    if grep -qiE 'no relevant changes|no new version|no release' dry-run.log; then
      echo "→ No release triggered"
      NEXT_VERSION="none"
    elif grep -qiE 'error|failed|ERR|Exception' dry-run.log; then
      echo "→ Dry-run failed — check logs"
      echo '```text'
      tail -n 8 dry-run.log
      echo '```'
      NEXT_VERSION="failed"
    else
      # Try several common patterns from semantic-release logs
      NEXT_VERSION=$(
        grep -Ei '(next release version is|The next release version is|version to publish|will release version)' dry-run.log |
        grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?' |
        head -1 || echo "unknown"
      )
      echo "→ Next version preview: **v${NEXT_VERSION}**"
    fi
  else
    echo "→ No dry-run.log found"
    NEXT_VERSION="missing"
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"

# Always set output
echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
