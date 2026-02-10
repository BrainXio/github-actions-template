#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release Preview"
  echo ""

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Dry-run OK (validation passed)"
  else
    echo "**Status**: ⚠️ Dry-run issue"
  fi

  echo ""

  # Get current version from package.json
  if [[ -f package.json ]]; then
    CURRENT_VERSION=$(jq -r '.version // "unknown"' package.json)
    echo "Current version (package.json): **v${CURRENT_VERSION}**"
  else
    CURRENT_VERSION="unknown"
    echo "No package.json found → current version unknown"
  fi

  # Try to extract bump type from dry-run log (e.g. 'minor', 'patch')
  BUMP_TYPE=$(grep -Ei 'release type|will be published as' dry-run.log | grep -oiE 'major|minor|patch' | head -1 || echo "")

  if [[ -n "$BUMP_TYPE" ]]; then
    echo "Detected bump type: **${BUMP_TYPE}**"
    # Simple semver increment (requires semver tool or manual logic)
    # For basic case, just note it – full increment needs external tool or node script
    echo "→ Predicted next version: v${CURRENT_VERSION} (${BUMP_TYPE} bump)"
    NEXT_VERSION="${CURRENT_VERSION} (${BUMP_TYPE})"
  elif grep -qiE 'no relevant changes' dry-run.log; then
    echo "→ No release triggered (no relevant changes)"
    NEXT_VERSION="none"
  else
    echo "→ Could not determine bump type"
    NEXT_VERSION="unknown"
  fi

  if grep -qiE 'error|failed' dry-run.log; then
    echo ""
    echo "Dry-run warnings/errors:"
    echo '```text'
    grep -Ei 'error|warn|failed' dry-run.log | tail -n 10
    echo '```'
  fi

  echo ""
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
