#!/bin/bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
#  WARNING – AGGRESSIVE FIREWALL
# ────────────────────────────────────────────────────────────────────────────────
# This script applies a very strict outbound firewall.
# It may BREAK apt, curl, act, gh, docker pulls, etc. if domains/IPs are missing.
#
# → Comment out or customize ALLOWED_DOMAINS / ports if things fail.
# → Consider running only when ENV var ENABLE_STRICT_FIREWALL=1
# → Debugging: add -j LOG --log-prefix "DROPPED: " before final REJECT
#
# This is intentional security hardening for LLM/devcontainer use.
# ────────────────────────────────────────────────────────────────────────────────

IFS=$'\n\t'

# ────────────────────────────────────────────────────────────────────────────────
#  CONFIGURATION CONSTANTS ───────────────────────────────────────────────────────
# ────────────────────────────────────────────────────────────────────────────────

DOCKER_DNS_IP="127.0.0.11"

ALLOWED_PORTS_OUTPUT=(
    "udp 53"           # DNS
    "tcp 22"           # SSH
    "tcp 11434"        # Ollama / local LLM inference
)

ALLOWED_PORTS_INPUT_RELATED=(
    "udp 53"
    "tcp 22"
    "tcp 11434"
)

ALLOWED_DOMAINS=(
    "api.anthropic.com"
    "files.pythonhosted.org"
    "github.com"
    "marketplace.visualstudio.com"
    "production.cloudflare.docker.com"
    "pypi.org"
    "registry-1.docker.io"
    "registry.npmjs.com"
    "registry.npmjs.org"
    "storage.googleapis.com"
    "update.code.visualstudio.com"
    "vscode.blob.core.windows.net"
)

ALLOWED_DOMAINS_LOG=".devcontainer/domains.log"

FALLBACK_GATEWAY="192.168.0.1"
LOCAL_NETWORK_SUFFIX=".0/24"

IPSET_NAME="allowed-domains"
GITHUB_META_URL="https://api.github.com/meta"

# ────────────────────────────────────────────────────────────────────────────────
#  MAIN SCRIPT ───────────────────────────────────────────────────────────────────
# ────────────────────────────────────────────────────────────────────────────────

# ------------------------------------------------------------------------------
# Handle optional SearXNG domain safely (with set -u friendly syntax)
# ------------------------------------------------------------------------------

SEARXNG_DOMAIN=""

# Only process if the variable exists and is non-empty
if [ -n "${SEARXNG_URL:-}" ]; then
    # Try to extract host (after scheme, before port/path)
    if [[ "${SEARXNG_URL}" =~ ^(https?://)?([^/:]+)(:[0-9]+)?(/.*)?$ ]]; then
        SEARXNG_DOMAIN="${BASH_REMATCH[2]}"
        # Strip any port if captured (though your regex already isolates host)
        SEARXNG_DOMAIN="${SEARXNG_DOMAIN%%:*}"
    else
        # Fallback — use raw value if parsing failed (rare)
        SEARXNG_DOMAIN="${SEARXNG_URL}"
        echo "Warning: Could not cleanly parse domain from SEARXNG_URL='${SEARXNG_URL}'" >&2
    fi
else
    echo "Note: SEARXNG_URL not set → skipping SearXNG domain in firewall" >&2
fi

# Add to array only if we have something valid
if [ -n "$SEARXNG_DOMAIN" ]; then
    echo "Adding SearXNG domain to allowed list: $SEARXNG_DOMAIN"
    ALLOWED_DOMAINS=("$SEARXNG_DOMAIN" "${ALLOWED_DOMAINS[@]}")
else
    echo "No valid SearXNG domain added."
fi

# Capture Docker DNS rules before flushing
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "${DOCKER_DNS_IP}" || true)

# Flush everything
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

ipset destroy "${IPSET_NAME}" 2>/dev/null || true

# Restore Docker DNS NAT rules if they existed
if [ -n "${DOCKER_DNS_RULES}" ]; then
    iptables -t nat -N DOCKER_OUTPUT   2>/dev/null || true
    iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
    echo "${DOCKER_DNS_RULES}" | xargs -L 1 iptables -t nat
fi

# Allow essential outbound ports
for rule in "${ALLOWED_PORTS_OUTPUT[@]}"; do
    iptables -A OUTPUT -p "${rule% *}" --dport "${rule#* }" -j ACCEPT
done

# Allow related inbound
for rule in "${ALLOWED_PORTS_INPUT_RELATED[@]}"; do
    iptables -A INPUT -p "${rule% *}" --sport "${rule#* }" \
        -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
done

# Loopback
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Create ipset
ipset create "${IPSET_NAME}" hash:net family inet

# GitHub ranges
gh_ranges=$(curl -s "${GITHUB_META_URL}" || echo '{}')
echo "${gh_ranges}" | jq -r '(.web + .api + .git)[]' | grep -v ':' | while read -r cidr; do
    ipset add "${IPSET_NAME}" "${cidr}" 2>/dev/null || true
done

# Local network
HOST_IP=$(ip route | grep default | awk '{print $3}' || echo "${FALLBACK_GATEWAY}")
HOST_NETWORK="${HOST_IP%.*}${LOCAL_NETWORK_SUFFIX}"

iptables -A INPUT  -s "${HOST_NETWORK}" -j ACCEPT
iptables -A OUTPUT -d "${HOST_NETWORK}" -j ACCEPT

# Allowed domains → resolve to IPs
for domain in "${ALLOWED_DOMAINS[@]}"; do
    ips=$(dig +short A "${domain}" | grep -v ':' || true)
    if [ -z "${ips}" ]; then
        echo "Warning: No IPv4 found for ${domain}" >&2
        continue
    fi
    while read -r ip; do
        [[ ${ip} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || continue
        ipset add "${IPSET_NAME}" "${ip}" 2>/dev/null || true
    done <<< "${ips}"
done

# Default drop policy
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# Established / related
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow whitelisted destinations
iptables -A OUTPUT -m set --match-set "${IPSET_NAME}" dst -j ACCEPT

# Explicit reject (helps when debugging what was blocked)
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

echo "Allowed domains:" > "${ALLOWED_DOMAINS_LOG}"
for domain in "${ALLOWED_DOMAINS[@]}"; do
    echo "  $domain" >> "${ALLOWED_DOMAINS_LOG}"
    ips=$(dig +short A "$domain" | grep -v ':' || true)
    if [ -z "$ips" ]; then
        echo "     (no IPv4 found)"
    else
        while read -r ip; do
            echo "     → $ip" >> "${ALLOWED_DOMAINS_LOG}"
        done <<< "$ips"
    fi
done

echo "Firewall configured"

exit 0
