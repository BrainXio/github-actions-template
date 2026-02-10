#!/usr/bin/env bash
set -euo pipefail

# Reads from stdin (the full dry-run output)
DRY_OUTPUT=$(cat)

# Write full output to file anyway (for artifact)
echo "$DRY_OUTPUT" > dry-run-parsed.log

# Default outputs
echo "status=failed" >> "$GITHUB_OUTPUT"
echo "result=**Dry-run parsing failed** — check logs" >> "$GITHUB_OUTPUT"

# Common success indicators in semantic-release dry-run output:
# Look for lines like:
# [semantic-release] › ℹ The next release version is X.Y.Z
# or
# > The next release version is ...
# or at the end: no new version / published release preview

NEXT_VERSION=$(echo "$DRY_OUTPUT" | grep -Ei '(next release version is|The next release version)' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9]+(\.[0-9]+)?)?' | head -1)

RELEASE_TYPE=$(echo "$DRY_OUTPUT" | grep -Ei 'release type|will be published as' | grep -oiE 'major|minor|patch' | head -1 || true)

HAS_NOTES=$(echo "$DRY_OUTPUT" | grep -qEi 'release notes|changelog' && echo "yes" || echo "no")

# Detect no-release case
if echo "$DRY_OUTPUT" | grep -qiE 'no relevant changes|no new version|won.t be published'; then
  echo "status=no-release" >> "$GITHUB_OUTPUT"
  printf "result=%b\n" "**No release planned**\n\nNo commits trigger a version bump.\n\n[Full dry-run log](artifact:dry-run.log)" >> "$GITHUB_OUTPUT"
  exit 0
fi

# Error detection (common failure patterns)
if echo "$DRY_OUTPUT" | grep -qiE 'error|failed|ERR|Exception'; then
  ERROR_PREVIEW=$(echo "$DRY_OUTPUT" | grep -Ei 'error|failed' -A 5 | tail -n 10)
  printf "result=%b\n" "**Dry-run failed**\n\n\`\`\`text\n${ERROR_PREVIEW:-No error details captured}\n\`\`\`" >> "$GITHUB_OUTPUT"
  exit 0
fi

# Success case
if [[ -n "$NEXT_VERSION" ]]; then
  echo "status=passed" >> "$GITHUB_OUTPUT"
  SUMMARY="**Next release: $NEXT_VERSION**"
  [[ -n "$RELEASE_TYPE" ]] && SUMMARY+=" ($RELEASE_TYPE bump)"
  SUMMARY+="\n\n"

  # Extract release notes preview (often after "Release notes:" or indented block)
  NOTES=$(echo "$DRY_OUTPUT" | sed -n '/release notes:/,/^\s*$/p' | tail -n +2 | sed 's/^    //')
  if [[ -n "$NOTES" ]]; then
    SUMMARY+="### Preview Release Notes\n\`\`\`markdown\n${NOTES}\n\`\`\`\n\n"
  fi

  SUMMARY+="Full dry-run output saved as artifact."
  printf "result=%b\n" "$SUMMARY" >> "$GITHUB_OUTPUT"
else
  # Fallback: probably success but parsing missed version
  echo "status=passed" >> "$GITHUB_OUTPUT"
  printf "result=%b\n" "**Dry-run succeeded** (version parsing incomplete)\n\nCheck dry-run.log artifact for details." >> "$GITHUB_OUTPUT"
fi
