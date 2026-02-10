#!/usr/bin/env bash
set -euo pipefail

# Required env vars (passed from YAML)
: "${EVENT_NAME:?Missing EVENT_NAME}"
: "${RUN_ID:?Missing RUN_ID}"
: "${REPO:?Missing REPO}"
: "${SERVER_URL:?Missing SERVER_URL}"

# Optional / fallback
PR_NUMBER="${PR_NUMBER:-}"

# Build the summary (double quotes = variables expand)
SUMMARY="# Workflow Summary – ${EVENT_NAME^}

**Repository**: ${REPO}
**Run**: [#${RUN_ID}](${SERVER_URL}/${REPO}/actions/runs/${RUN_ID})
**Last updated**: $(date -u +"%Y-%m-%d %H:%M UTC")

## Job Results

| Job              | Status     | Result                  |
|------------------|------------|-------------------------|
| Validate         | ${VALIDATE_STATUS:-❓} | ${VALIDATE_RESULT:-skipped} |
| Test             | ${TEST_STATUS:-❓}     | ${TEST_RESULT:-skipped}     |
| Release Preview  | ${PREVIEW_STATUS:-❓}  | ${PREVIEW_RESULT:-skipped}  |
| Release Guard    | ${GUARD_STATUS:-❓}    | ${GUARD_RESULT:-skipped}    |
| Release          | ${RELEASE_STATUS:-❓}  | ${RELEASE_RESULT:-skipped}  |

See individual job summaries and logs in the Actions UI for more details.

<!-- workflow-reporter-marker -->
This comment is automatically updated by the **Report Status** job.
"

# Always show in console / logs
echo -e "$SUMMARY"

# Only set output if it's a pull_request (prevents error on main/schedule/etc.)
if [[ "$EVENT_NAME" == "pull_request" && -n "$PR_NUMBER" ]]; then
  echo "PR detected → setting comment body output"
  echo "comment-body=$SUMMARY" >> "$GITHUB_OUTPUT"
else
  echo "Not a pull_request event or no PR number → no comment output set"
fi

echo "workflow_reporter.sh finished."
