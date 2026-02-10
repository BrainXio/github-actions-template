#!/usr/bin/env bash
set -euo pipefail

readonly WHO_TO_GREET="${INPUT_WHO_TO_GREET:-World}"

echo "Hello, ${WHO_TO_GREET}!"

TIME=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Modern output only – no legacy
echo "time=$TIME" >> "${GITHUB_OUTPUT:-/dev/null}"

# Debug: force visibility in logs
echo "DEBUG: Wrote time=$TIME" >&2
echo "DEBUG: GITHUB_OUTPUT path = ${GITHUB_OUTPUT:-unset}" >&2
[ -f "${GITHUB_OUTPUT:-}" ] && echo "DEBUG: File contents:" >&2 && cat "$GITHUB_OUTPUT" >&2 || echo "DEBUG: Output file not found" >&2
