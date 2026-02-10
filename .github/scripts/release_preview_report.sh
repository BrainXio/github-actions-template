#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# Determine branch name (PR head ref preferred)
# ────────────────────────────────────────────────
PR_BRANCH="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
if [[ -z "$PR_BRANCH" || "$PR_BRANCH" == "HEAD" ]]; then
  PR_BRANCH="pr-preview-$(date +%s)-${GITHUB_RUN_ID:-local}"
fi

# Temp branch name we will push (must match what we allow in config)
TEMP_BRANCH="preview-dryrun-${GITHUB_RUN_ID:-local}-${GITHUB_SHA:0:8}"

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "no tags")

# ────────────────────────────────────────────────
# Fetch tags
# ────────────────────────────────────────────────
git fetch --tags --force --prune || true

# ────────────────────────────────────────────────
# Create & force-push a temporary branch pointing at current HEAD
# (uses GITHUB_TOKEN which has contents:write permission in this job)
# ────────────────────────────────────────────────
git checkout -b "${TEMP_BRANCH}"
git push --force origin "${TEMP_BRANCH}"

# ────────────────────────────────────────────────
# Temporary config that explicitly allows our temp branch
# ────────────────────────────────────────────────
cat > .releaserc.preview.json <<EOF
{
  "extends": "./.releaserc.json",
  "branches": ["main", "${TEMP_BRANCH}"],
  "ci": false,
  "dryRun": true
}
EOF

# ────────────────────────────────────────────────
# Trick semantic-release into using the pushed branch name
# by overriding GITHUB_REF temporarily
# ────────────────────────────────────────────────
unset GITHUB_ACTIONS
DRY_RUN_BRANCH="${TEMP_BRANCH}" GITHUB_REF="refs/heads/${TEMP_BRANCH}" \
  npx semantic-release --config .releaserc.preview.json --no-ci > dry-run.log 2>&1
DRY_RUN_EXIT=$?

# ────────────────────────────────────────────────
# Cleanup: delete temp branch remotely & locally, remove temp config
# ────────────────────────────────────────────────
git push origin --delete "${TEMP_BRANCH}" || true
git checkout -q "${PR_BRANCH}" || git checkout -q main || true
rm -f .releaserc.preview.json

# ────────────────────────────────────────────────
# Parse next version
# ────────────────────────────────────────────────
NEXT_VERSION=$(grep -Eai 'next release version is' dry-run.log | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.+]+)?' | tail -1 || true)

if [[ -z "$NEXT_VERSION" ]]; then
  if [[ $DRY_RUN_EXIT -ne 0 ]]; then
    NEXT_VERSION="error (exit=$DRY_RUN_EXIT)"
  elif grep -qiE 'no .*changes|no new release|nothing to release' dry-run.log 2>/dev/null; then
    NEXT_VERSION="${CURRENT_VERSION} (no bump)"
  else
    NEXT_VERSION="unknown / skipped"
  fi
fi

# Validation status
if [[ $DRY_RUN_EXIT -eq 0 ]]; then
  VALIDATION="✅ Dry-run passed"
else
  VALIDATION="⚠️ Dry-run issue (code $DRY_RUN_EXIT)"
fi

# ────────────────────────────────────────────────
# Write summary
# ────────────────────────────────────────────────
{
  echo "### Release Preview"
  echo ""
  echo "**Current version** (git tag): **${CURRENT_VERSION}**"
  echo "**Next version preview**: **v${NEXT_VERSION}**"
  echo "**Validation**: ${VALIDATION}"
  echo ""
  if [[ -f dry-run.log ]]; then
    echo "Last 10 lines of dry-run.log:"
    echo '```text'
    tail -n 10 dry-run.log || echo "(empty)"
    echo '```'
  else
    echo "→ No dry-run.log generated"
  fi
  echo ""
  echo "> Note: Preview uses temporary pushed branch + config override to force calculation from PR commits only."
} >> "$GITHUB_STEP_SUMMARY"

echo "next_version=${NEXT_VERSION}" >> "$GITHUB_OUTPUT"
