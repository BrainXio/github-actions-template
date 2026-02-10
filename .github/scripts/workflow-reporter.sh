#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
#   workflow-reporter.sh
#   Posts/updates a PR comment with job status summary
# ──────────────────────────────────────────────────────────────────────────────

# Exit early if not a pull request
if [[ "${EVENT_NAME:-}" != "pull_request" || -z "${PR_NUMBER:-}" ]]; then
  echo "Not a pull request → skipping comment"
  exit 0
fi

# Default to 'skipped' if any variable is unset
: "${NEEDS_VALIDATE_RESULT:=skipped}"
: "${NEEDS_TEST_RESULT:=skipped}"
: "${NEEDS_RELEASE_PREVIEW_RESULT:=skipped}"
: "${NEEDS_RELEASE_GUARD_RESULT:=skipped}"
: "${NEEDS_RELEASE_RESULT:=skipped}"

# Emoji mapping
get_emoji() {
  case "$1" in
    success)   echo "✅" ;;
    failure)   echo "❌" ;;
    cancelled) echo "🚫" ;;
    skipped)   echo "⏭️" ;;
    *)         echo "❓" ;;
  esac
}

# Build comment body
body=$(cat << 'EOF'
### Workflow Status Summary

| Job               | Status   |
|-------------------|----------|
| Validate          | $(get_emoji "${NEEDS_VALIDATE_RESULT}") ${NEEDS_VALIDATE_RESULT} |
| Test              | $(get_emoji "${NEEDS_TEST_RESULT}") ${NEEDS_TEST_RESULT} |
| Release Preview   | $(get_emoji "${NEEDS_RELEASE_PREVIEW_RESULT}") ${NEEDS_RELEASE_PREVIEW_RESULT} |
| Release Guard     | $(get_emoji "${NEEDS_RELEASE_GUARD_RESULT}") ${NEEDS_RELEASE_GUARD_RESULT} |
| Release           | $(get_emoji "${NEEDS_RELEASE_RESULT}") ${NEEDS_RELEASE_RESULT} |

[View full workflow run →](${SERVER_URL}/${REPO}/actions/runs/${RUN_ID})

Last updated: $(date -u +"%Y-%m-%d %H:%M UTC")
EOF
)

# ──────────────────────────────────────────────────────────────────────────────
#   Post or update comment using GitHub API
# ──────────────────────────────────────────────────────────────────────────────

# Optional: Look for existing comment by distinctive marker
# (uncomment and adjust if you want to update instead of create new)
# marker="<!-- workflow-reporter-summary -->"
# existing=$(curl -sSL \
#   -H "Accept: application/vnd.github+json" \
#   -H "Authorization: Bearer ${GITHUB_TOKEN}" \
#   "${SERVER_URL}/api/v3/repos/${REPO}/issues/${PR_NUMBER}/comments" \
#   | jq -r --arg marker "$marker" '.[] | select(.body | contains($marker)) | .id' | head -n1)

# if [[ -n "$existing" ]]; then
#   echo "Updating existing comment #$existing"
#   curl -sSL \
#     -X PATCH \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: Bearer ${GITHUB_TOKEN}" \
#     -d "{\"body\":${body@Q}}" \
#     "${SERVER_URL}/api/v3/repos/${REPO}/issues/comments/${existing}"
# else
  echo "Creating new comment"
  curl -sSL \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -d "{\"body\":${body@Q}}" \
    "${SERVER_URL}/api/v3/repos/${REPO}/issues/${PR_NUMBER}/comments"
# fi

echo "Comment operation completed."
