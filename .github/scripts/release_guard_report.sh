#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release Guard"
  echo ""
  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Proceeding"
  else
    echo "**Status**: ⏭️ Skipped / Failed"
  fi
  echo ""
} >> "$GITHUB_STEP_SUMMARY"
