#!/usr/bin/env bash
set -euo pipefail

{
  echo "### Release Preview"
  echo ""

  if [[ "${JOB_STATUS:-unknown}" == "success" ]]; then
    echo "**Status**: ✅ Dry-run completed successfully"
  else
    echo "**Status**: ⚠️ Dry-run had issues (check job logs)"
  fi

  echo ""
  echo "**Next version preview**: ${NEXT_VERSION:-unknown}"

  case "$NEXT_VERSION" in
    "no-release-pending")
      echo "→ No commits qualify for a new release (e.g., no feat/fix/breaking changes since last tag)"
      ;;
    "failed")
      echo "→ Dry-run failed — review the step logs above for errors"
      ;;
    "unknown"|"")
      echo "→ Could not determine next version (unexpected output format)"
      ;;
    *)
      echo "→ Would create release: **v${NEXT_VERSION}**"
      ;;
  esac

  echo ""
} >> "$GITHUB_STEP_SUMMARY"

# Optional: also set as step output if you want to use it in later steps of the same job
echo "next_version=${NEXT_VERSION:-unknown}" >> "$GITHUB_OUTPUT"
