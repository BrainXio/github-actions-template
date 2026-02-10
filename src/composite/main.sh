#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Hello World – BrainXio GitHub Action Template
# ────────────────────────────────────────────────────────────────────────────────

readonly WHO_TO_GREET="${INPUT_WHO_TO_GREET:-World}"

echo "Hello, ${WHO_TO_GREET}!"

TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Modern way – primary method
echo "time=$TIME" >> "$GITHUB_OUTPUT" || {
  echo "Warning: Failed to write to \$GITHUB_OUTPUT" >&2
}

# Legacy fallback (still supported in composite actions, helps in some runners)
echo "::set-output name=time::$TIME" || true

# Debug line – remove after confirmation
echo "Debug: Wrote time=$TIME to outputs (GITHUB_OUTPUT=$GITHUB_OUTPUT)" >&2

# Optional: echo the file content for debugging
[ -f "$GITHUB_OUTPUT" ] && cat "$GITHUB_OUTPUT" >&2 || echo "Debug: GITHUB_OUTPUT file not found" >&2
