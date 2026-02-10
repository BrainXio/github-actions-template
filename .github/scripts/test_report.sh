#!/usr/bin/env bash
set -euo pipefail

echo "### Test" >> "$GITHUB_STEP_SUMMARY"
echo "**Status**: ${{ env.JOB_STATUS == 'success' && '✅ Passed' || '❌ Failed' }}" >> "$GITHUB_STEP_SUMMARY"

if [[ "${{ env.ACTION_OUTCOME }}" != "success" ]]; then
  echo "" >> "$GITHUB_STEP_SUMMARY"
  echo "**Issue**: Action execution or output verification failed" >> "$GITHUB_STEP_SUMMARY"
fi
