#!/usr/bin/env bash
set -euo pipefail

# Required env vars
: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN}"
: "${EVENT_NAME:?Missing EVENT_NAME}"
: "${RUN_ID:?Missing RUN_ID}"
: "${REPO:?Missing REPO}"
: "${SERVER_URL:?Missing SERVER_URL}"

PR_NUMBER="${PR_NUMBER:-}"

API_BASE="${SERVER_URL}/api/v3"
REPO_FULL="${REPO}"

# Build summary using pre-computed env vars
SUMMARY="# Workflow Summary – ${EVENT_NAME^}

**Repository**: ${REPO_FULL}
**Run**: [#${RUN_ID}](${SERVER_URL}/${REPO}/actions/runs/${RUN_ID})
**Date**: $(date -u +"%Y-%m-%d %H:%M UTC")

## Job Results

| Job              | Status     | Result                  |
|------------------|------------|-------------------------|
| Validate         | ${VALIDATE_STATUS} | ${VALIDATE_RESULT} |
| Test             | ${TEST_STATUS}     | ${TEST_RESULT}     |
| Release Preview  | ${PREVIEW_STATUS}  | ${PREVIEW_RESULT}  |
| Release Guard    | ${GUARD_STATUS}    | ${GUARD_RESULT}    |
| Release          | ${RELEASE_STATUS}  | ${RELEASE_RESULT}  |

See the individual job logs in the Actions UI for more details (dry-run output, pre-commit failures, etc.).

<!-- workflow-reporter-marker -->
This comment is automatically updated by the **Report Status** job.
"

# Print to console (always)
echo -e "$SUMMARY"

# Only post/update comment on pull_request
if [[ "$EVENT_NAME" == "pull_request" && -n "$PR_NUMBER" ]]; then
  echo "PR event → posting/updating comment"

  COMMENT_BODY_JSON=$(jq -Rsa . <<< "$SUMMARY")

  # Find existing comment
  COMMENTS=$(curl -sSL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments")

  EXISTING_ID=$(echo "$COMMENTS" | jq -r '
    .[] | select(.body | contains("<!-- workflow-reporter-marker -->")) | .id
    ' | head -n1)

  if [[ -n "${EXISTING_ID}" && "${EXISTING_ID}" != "null" ]]; then
    echo "Updating comment #${EXISTING_ID}"
    curl -sSL -X PATCH \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -d "{\"body\": ${COMMENT_BODY_JSON}}" \
      "${API_BASE}/repos/${REPO_FULL}/issues/comments/${EXISTING_ID}"
  else
    echo "Creating new comment"
    curl -sSL -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -d "{\"body\": ${COMMENT_BODY_JSON}}" \
      "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments"
  fi
else
  echo "Non-PR event → summary logged only"
fi

echo "Reporter finished."
