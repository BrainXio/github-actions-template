#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "=== DevContainer / Codespaces setup script ==="

# ────────────────────────────────────────────────────────────────────────────────
# Common setup (local + container)
# ────────────────────────────────────────────────────────────────────────────────

echo "→ Common tools"

# act (pinned version)
ACT_VERSION="v0.2.84"
ACT_BIN="$HOME/.local/bin/act"
if ! command -v act >/dev/null 2>&1 && [ ! -f "$ACT_BIN" ]; then
    echo "  Installing act $ACT_VERSION ..."
    mkdir -p ~/.local/bin
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b ~/.local/bin "$ACT_VERSION"
else
    echo "  act already available"
fi

# Installing shellcheck
if ! command -v shellcheck >/dev/null; then
    echo "  Installing shellcheck ..."
    if [[ "$(uname)" == "Linux" ]]; then
        sudo apt-get update -qq && sudo apt-get install -y --no-install-recommends shellcheck
    elif [[ "$(uname)" == "Darwin" ]]; then
        brew install --quiet shellcheck
    else
        echo "Unsupported OS – install shellcheck manually"
        exit 1
    fi
fi

# detect-secrets baseline
if ! pipx list | grep -q detect-secrets; then
    echo "  Installing detect-secrets via pipx ..."
    pipx install detect-secrets
fi

if [[ -f .secrets.baseline ]]; then
    echo "  Updating secrets baseline ..."
    detect-secrets audit .secrets.baseline
else
    echo "  Creating initial secrets baseline ..."
    detect-secrets scan > .secrets.baseline
fi

# pre-commit hooks
pre-commit install --install-hooks || echo "pre-commit install failed (non-fatal)"

# ────────────────────────────────────────────────────────────────────────────────
# Container-only setup
# ────────────────────────────────────────────────────────────────────────────────

if [[ "${REMOTE_CONTAINERS:-}" != "true" && "${CODESPACES:-}" != "true" ]]; then
    echo "Not in devcontainer/Codespaces → skipping container-specific steps"
    echo "Setup finished."
    exit 0
fi

echo "→ Container-only steps"

# Dev utilities via apt
echo "  Installing apt packages ..."
sudo apt-get update -qq && \
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        less git procps fzf zsh man-db unzip gnupg gh iptables ipset iproute2 dnsutils jq nano vim tree curl && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Firewall
echo "  Applying strict outbound firewall ..."
sudo -E ./init-firewall.sh

# Claude + MCP
if ! command -v claude >/dev/null; then
    echo "  Installing Claude Code ..."
    curl -fsSL https://claude.ai/install.sh | bash
    ./init-mcp.sh
else
    echo "  Claude already installed"
fi

echo -e "\033[1;32mContainer setup complete\033[0m"
