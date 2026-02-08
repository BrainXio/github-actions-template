#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Hello World – BrainXio GitHub Action Template
# ────────────────────────────────────────────────────────────────────────────────

readonly WHO_TO_GREET="${INPUT_WHO_TO_GREET:-World}"

echo "Hello, ${WHO_TO_GREET}!"

# Set output (time example)
echo "time=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> "$GITHUB_OUTPUT"
