#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release"
  echo ""
  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: 🚀 Published"
  else
    echo "**Status**: ❌ Failed"
  fi
  echo ""
} >> "$GITHUB_STEP_SUMMARY"
