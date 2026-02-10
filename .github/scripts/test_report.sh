#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Test"
  echo ""

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Passed"
  else
    echo "**Status**: ❌ Failed"
    echo ""
    if [[ "${ACTION_OUTCOME:-failure}" != "success" ]]; then
      echo "**Issue**: Action execution or output verification failed"
    fi
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"
