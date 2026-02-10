#!/usr/bin/env bash
set -euo pipefail

echo "### Validate" >> "$GITHUB_STEP_SUMMARY"
echo "**Status**: ${{ env.JOB_STATUS == 'success' && '✅ Passed' || '❌ Failed' }}" >> "$GITHUB_STEP_SUMMARY"

if [[ "${{ env.JOB_STATUS }}" != "success" ]]; then
  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "**Possible reasons**:" >> "$GITHUB_STEP_SUMMARY"
  echo "- pre-commit hooks failed" >> "$GITHUB_STEP_SUMMARY"
  echo "- Shellcheck warnings (ignored but logged)" >> "$GITHUB_STEP_SUMMARY"
  echo "- Semantic PR title invalid" >> "$GITHUB_STEP_SUMMARY"
fi
