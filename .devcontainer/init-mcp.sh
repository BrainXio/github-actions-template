#!/usr/bin/env bash
# init-mcp.sh
# One-time / post-create script to register useful MCP servers in Claude
# Only enables servers when relevant conditions are met

set -euo pipefail
IFS=$'\n\t'

echo "Initializing MCP servers for Claude..."

# ────────────────────────────────────────────────────────────────────────────────
# Helper: Check if a command exists
# ────────────────────────────────────────────────────────────────────────────────
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ────────────────────────────────────────────────────────────────────────────────
# 1. Serena (IDE-aware code editing)
#    Enable if: current directory looks like a project (has package.json or pyproject.toml or Makefile)
# ────────────────────────────────────────────────────────────────────────────────
if [[ -f "package.json" || -f "pyproject.toml" || -f "Makefile" || -d "src" || -d "app" ]]; then
    echo "Project detected → adding Serena MCP (IDE assistant mode)..."
    claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server \
        --context ide-assistant \
        --project "$(pwd)" \
        || echo "Warning: Failed to add Serena MCP"
else
    echo "No obvious project files detected → skipping Serena"
fi

# ────────────────────────────────────────────────────────────────────────────────
# 2. SearXNG (privacy-friendly web search)
#    Enable if: SEARXNG_URL is set and looks valid (contains a dot + scheme or hostname)
# ────────────────────────────────────────────────────────────────────────────────
if [[ -n "${SEARXNG_URL:-}" ]] && [[ "${SEARXNG_URL}" =~ \. ]] && [[ "${SEARXNG_URL}" =~ ^(https?://|[a-zA-Z0-9.-]+) ]]; then
    echo "Valid SEARXNG_URL detected → adding SearXNG MCP..."
    # Prefer npx over global npm install for one-time / ephemeral containers
    claude mcp add searxng -- npx -y mcp-searxng \
        --env SEARXNG_URL="${SEARXNG_URL}" \
        || echo "Warning: Failed to add SearXNG MCP"
else
    echo "No valid SEARXNG_URL → skipping SearXNG MCP"
fi

# ────────────────────────────────────────────────────────────────────────────────
# 3. Playwright MCP (browser automation & debugging)
#    Enable if: Node.js project detected (package.json) OR frontend-related files exist
# ────────────────────────────────────────────────────────────────────────────────
shopt -s nullglob globstar   # Enable extended globbing
frontend_files=(**/*.{js,ts,jsx,tsx,html,css,vue,svelte})

if [[ -f "package.json" ]] || ((${#frontend_files[@]} > 0)); then
    echo "Node.js or frontend files detected → adding Playwright MCP (headless)..."
    claude mcp add playwright -- npx @playwright/mcp@latest \
        --env PLAYWRIGHT_HEADLESS=true \
        || echo "Warning: Failed to add Playwright MCP"
else
    echo "No Node.js/frontend files detected → skipping Playwright MCP"
fi

# ────────────────────────────────────────────────────────────────────────────────
# Optional extras you can uncomment / adapt
# ────────────────────────────────────────────────────────────────────────────────

# # Bash/shell execution (if many scripts or Makefile-heavy project)
# if [[ -f "Makefile" || -d "scripts" || -f ".github/workflows" ]]; then
#     echo "Shell-heavy project detected → adding bash-mcp..."
#     claude mcp add bash -- npx bash-mcp || echo "bash-mcp add failed"
# fi

# # Filesystem access (always useful in large repos)
# echo "Adding fs-mcp (project filesystem access)..."
# claude mcp add fs -- npx fs-mcp --root "$(pwd)" || echo "fs-mcp add failed"

echo ""
echo "MCP server initialization complete."
echo "Run 'claude mcp list' to verify added servers."
echo "You can now use them in Claude Desktop/Code."
