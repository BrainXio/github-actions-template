#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────
# Required environment variables (passed from workflow)
# ────────────────────────────────────────────────
: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN}"
: "${EVENT_NAME:?Missing EVENT_NAME}"
: "${RUN_ID:?Missing RUN_ID}"
: "${REPO:?Missing REPO}"
: "${SERVER_URL:?Missing SERVER_URL}"

# PR_NUMBER may be empty on non-PR events
PR_NUMBER="${PR_NUMBER:-}"

API_BASE="${SERVER_URL}/api/v3"
REPO_FULL="${REPO}"

# ────────────────────────────────────────────────
# Build the summary body
# ────────────────────────────────────────────────
SUMMARY="# Workflow Summary – ${EVENT_NAME^}

**Repository**: ${REPO_FULL}
**Run**: [#${RUN_ID}](${SERVER_URL}/${REPO}/actions/runs/${RUN_ID})
**Date**: $(date -u +"%Y-%m-%d %H:%M UTC")

## Job Results

| Job              | Status          | Result                  |
|------------------|-----------------|-------------------------|
| Validate         | ${{ needs.validate.result == 'success' && '✅' || '❌' }} | ${{ NEEDS_VALIDATE_RESULT:-skipped }} |
| Test             | ${{ needs.test.result == 'success' && '✅' || '❌' }}     | ${{ NEEDS_TEST_RESULT:-skipped }}     |
| Release Preview  | ${{ needs['release-preview'].result == 'success' && '✅' || '⚠️' }} | ${{ NEEDS_RELEASE_PREVIEW_RESULT:-skipped }} |
| Release Guard    | ${{ needs['release-guard'].result == 'success' && '✅' || '⏭️' }} | ${{ NEEDS_RELEASE_GUARD_RESULT:-skipped }} |
| Release          | ${{ needs.release.result == 'success' && '🚀' || '❌' }}   | ${{ NEEDS_RELEASE_RESULT:-skipped }}   |

See the individual job logs in the Actions UI for more details (e.g. dry-run output, pre-commit failures, etc.).

<!-- workflow-reporter-marker -->
This comment is automatically updated by the **Report Status** job.
"

# ────────────────────────────────────────────────
# Log to console (always visible in workflow run)
# ────────────────────────────────────────────────
echo -e "$SUMMARY"

# ────────────────────────────────────────────────
# Only attempt to post/update comment on pull_request events
# ────────────────────────────────────────────────
if [[ "$EVENT_NAME" == "pull_request" && -n "$PR_NUMBER" ]]; then
  echo "PR detected (#${PR_NUMBER}) → attempting to post/update comment"

  # Escape for JSON
  COMMENT_BODY_JSON=$(jq -Rsa . <<< "$SUMMARY")

  # Find existing comment by marker
  COMMENTS_RESPONSE=$(curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments")

  EXISTING_COMMENT_ID=$(echo "$COMMENTS_RESPONSE" | jq -r '
    .[]
    | select(.body | contains("<!-- workflow-reporter-marker -->"))
    | .id
    ' | head -n 1)

  if [[ -n "$EXISTING_COMMENT_ID" && "$EXISTING_COMMENT_ID" != "null" ]]; then
    echo "Updating existing comment #${EXISTING_COMMENT_ID}"
    curl -sSL -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -d "{\"body\": ${COMMENT_BODY_JSON}}" \
      "${API_BASE}/repos/${REPO_FULL}/issues/comments/${EXISTING_COMMENT_ID}" \
      > /dev/null
  else
    echo "Creating new comment"
    curl -sSL -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -d "{\"body\": ${COMMENT_BODY_JSON}}" \
      "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments" \
      > /dev/null
  fi

  echo "Comment operation completed."
else
  echo "Not a pull_request event or no PR number → summary logged only (no comment posted)"
fi

echo "workflow-reporter.sh finished."
