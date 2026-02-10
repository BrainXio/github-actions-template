#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Validate"
  echo ""

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Passed"
  else
    echo "**Status**: ❌ Failed"
    echo ""
    echo "**Possible reasons**:"
    echo "- pre-commit hooks failed"
    echo "- Shellcheck issues (warnings ignored but logged)"
    echo "- Semantic PR title invalid (on pull requests)"
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"
