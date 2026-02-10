#!/usr/bin/env bash
set -euo pipefail

# Run dry-run with branch override
git fetch --tags --force --prune || true
npx semantic-release --dry-run --branches "${GITHUB_HEAD_REF:-main}" > dry-run.log 2>&1 || true

# Extract next version
NEXT_VERSION=$(grep -Ei 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' | tail -1 || echo "unknown")

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

{
  echo "### Release Preview"
  echo ""
  echo "**Current version** (git tag): **${CURRENT_VERSION}**"
  echo "**Next version preview**: **v${NEXT_VERSION}**"

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Dry-run validation**: ✅ Passed"
  else
    echo "**Dry-run validation**: ⚠️ Issue"
  fi

  if [[ -f dry-run.log ]]; then
    echo ""
    echo "Last 10 lines of dry-run.log:"
    echo '```text'
    tail -n 10 dry-run.log || echo "(no log content)"
    echo '```'
  else
    echo "→ No dry-run.log generated"
  fi

  echo ""
  echo "> Note: Preview uses --branches override for PR context."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
