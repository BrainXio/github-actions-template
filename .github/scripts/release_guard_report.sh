#!/usr/bin/env bash
set -euo pipefail

echo "### Release Guard" >> "$GITHUB_STEP_SUMMARY"
echo "**Status**: ${{ env.JOB_STATUS == 'success' && '✅ Proceeding' || '⏭️ Skipped' }}" >> "$GITHUB_STEP_SUMMARY"
