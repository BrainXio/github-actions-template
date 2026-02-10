#!/usr/bin/env bash
set -euo pipefail

# Required env vars (passed from workflow)
: "${GITHUB_TOKEN:?Missing GITHUB_TOKEN}"
: "${PR_NUMBER:?Missing PR_NUMBER}"               # only set on pull_request
: "${EVENT_NAME:?Missing EVENT_NAME}"
: "${RUN_ID:?Missing RUN_ID}"
: "${REPO:?Missing REPO}"                         # owner/repo
: "${SERVER_URL:?Missing SERVER_URL}"             # usually https://github.com

API_BASE="${SERVER_URL}/api/v3"
REPO_FULL="${REPO}"                               # e.g. BrainXio/github-actions-template

# Build summary from needs.*.result (these are auto-available as env vars in if: always() jobs)
SUMMARY="### Workflow Report (${EVENT_NAME^})\n\n"

add_status() {
  local name="$1"
  local result_var="NEEDS_${name^^}_RESULT"   # e.g. NEEDS_VALIDATE_RESULT
  local result="${!result_var:-skipped}"       # fallback if not set

  local emoji
  case "$result" in
    success)  emoji="✅" ;;
    failure)  emoji="❌" ;;
    cancelled) emoji="🚫" ;;
    skipped)  emoji="⏭️" ;;
    *) emoji="❓" ;;
  esac

  SUMMARY+="- **${name}**: ${emoji} ${result}\n"
}

# Add each relevant job (match your needs: array)
add_status "validate"
add_status "test"
add_status "release-preview"
add_status "release-guard"
add_status "release"

# Optional: link to the run
RUN_URL="${SERVER_URL}/${REPO}/actions/runs/${RUN_ID}"
SUMMARY+="\n[View full workflow run](${RUN_URL})\n"

# If not a PR → maybe log only or skip comment
if [[ -z "${PR_NUMBER:-}" ]]; then
  echo "Not a pull_request event → skipping comment"
  echo -e "$SUMMARY"
  exit 0
fi

# Post or update comment via REST API
# Strategy: find existing comment by bot + title marker, update if found, else create

COMMENT_BODY=$(cat <<EOF
${SUMMARY}

<!-- workflow-reporter-marker -->
This comment is auto-updated by the Report Status job.
EOF
)

# Escape for JSON
COMMENT_BODY_JSON=$(jq -Rsa . <<< "$COMMENT_BODY")

# Try to find existing comment (search issues comments for marker)
COMMENTS=$(curl -sSL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments")

EXISTING_ID=$(echo "$COMMENTS" | jq -r '
  .[] | select(.body | contains("<!-- workflow-reporter-marker -->")) | .id
  ' | head -n1)

if [[ -n "${EXISTING_ID}" && "${EXISTING_ID}" != "null" ]]; then
  echo "Updating existing comment #${EXISTING_ID}"
  curl -sSL \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -d "{\"body\": ${COMMENT_BODY_JSON}}" \
    "${API_BASE}/repos/${REPO_FULL}/issues/comments/${EXISTING_ID}"
else
  echo "Creating new comment"
  curl -sSL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -d "{\"body\": ${COMMENT_BODY_JSON}}" \
    "${API_BASE}/repos/${REPO_FULL}/issues/${PR_NUMBER}/comments"
fi

echo "Reporter finished."
