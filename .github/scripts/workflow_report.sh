#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# workflow-report.sh
# Generates reporter-comment.md for peter-evans/create-or-update-comment
# ──────────────────────────────────────────────────────────────────────────────

# Exit early if not a pull request
if [[ "${EVENT_NAME:-}" != "pull_request" || -z "${PR_NUMBER:-}" ]]; then
  echo "Not a pull request → skipping report generation"
  exit 0
fi

# Default to skipped if unset
: "${NEEDS_VALIDATE_RESULT:=skipped}"
: "${NEEDS_TEST_RESULT:=skipped}"
: "${NEEDS_RELEASE_PREVIEW_RESULT:=skipped}"
: "${NEEDS_RELEASE_GUARD_RESULT:=skipped}"
: "${NEEDS_RELEASE_RESULT:=skipped}"

emoji() {
  case "$1" in
    success)   echo "✅" ;;
    failure)   echo "❌" ;;
    cancelled) echo "🚫" ;;
    skipped)   echo "⏭️" ;;
    *)         echo "❓" ;;
  esac
}

# Generate markdown body
cat > reporter-comment.md << 'EOF'
### Workflow Status Summary

| Job               | Status                          |
|-------------------|---------------------------------|
| Validate          | $(emoji "${NEEDS_VALIDATE_RESULT}") ${NEEDS_VALIDATE_RESULT} |
| Test              | $(emoji "${NEEDS_TEST_RESULT}") ${NEEDS_TEST_RESULT} |
| Release Preview   | $(emoji "${NEEDS_RELEASE_PREVIEW_RESULT}") ${NEEDS_RELEASE_PREVIEW_RESULT} |
| Release Guard     | $(emoji "${NEEDS_RELEASE_GUARD_RESULT}") ${NEEDS_RELEASE_GUARD_RESULT} |
| Release           | $(emoji "${NEEDS_RELEASE_RESULT}") ${NEEDS_RELEASE_RESULT} |

[View full workflow run →](${SERVER_URL}/${REPO}/actions/runs/${RUN_ID})

Last updated: $(date -u +"%Y-%m-%d %H:%M UTC")
EOF

echo "Generated reporter-comment.md"
ls -l reporter-comment.md
cat reporter-comment.md   # for debug visibility in logs
