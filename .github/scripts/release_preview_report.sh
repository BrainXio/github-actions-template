#!/usr/bin/env bash
set -euo pipefail

echo "### Release Preview" >> "$GITHUB_STEP_SUMMARY"
echo "**Status**: ${{ env.JOB_STATUS == 'success' && '✅ Dry-run OK' || '⚠️ Dry-run issue' }}" >> "$GITHUB_STEP_SUMMARY"

if [[ -f dry-run.log ]]; then
  if grep -qiE 'no relevant changes|no new version' dry-run.log; then
    echo "→ No release triggered" >> "$GITHUB_STEP_SUMMARY"
  elif grep -qiE 'error|failed' dry-run.log; then
    echo "→ Dry-run failed — check logs" >> "$GITHUB_STEP_SUMMARY"
  else
    VERSION=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' dry-run.log | head -1 || echo "?")
    echo "→ Next version preview: **v${VERSION}**" >> "$GITHUB_STEP_SUMMARY"
  fi
fi
