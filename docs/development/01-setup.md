# 01 – Development Environment Setup

One-click, reproducible dev environment using **DevContainer** — everything you need to build, test, and release GitHub Actions locally.

## Why DevContainer?

- Identical tools & versions for everyone (no “works on my machine” issues)
- Pre-installs act, shellcheck, pre-commit, gh CLI, detect-secrets, jq, etc.
- Isolated from your host system
- Fast local GitHub Actions simulation with `act`
- Works in VS Code, Codespaces, or any compatible editor

## One-time setup (automatic – do this first)

1. Open the repository in VS Code (or Codespaces)
2. Click **Reopen in Container** (green button bottom-left or popup)
3. Wait 2–6 minutes the first time
   → DevContainer installs Docker, pulls images, runs `make setup`

After the first run, container startup takes ~5 seconds.

**Manual trigger if needed (e.g. after git pull that changed tools):**

```bash
make setup
```

(`make setup` is idempotent — safe to run anytime.)

## Everyday commands (all via Makefile)

Open a terminal in the container and run:

```bash
make help           # ← Print this list + descriptions
make setup          # Re-run full tool installation if needed
make lint           # Shellcheck on all .sh files
make check-secrets  # Scan for accidental secrets / tokens
make test-push      # Quick test of your action (most common)
make tests          # Run push + dispatch + pr + issues
make validate       # Dry-run the full CI workflow
make clean          # Remove temporary files
```

## Recommended daily workflow

```bash
# Once after container start or git pull
make setup

# Quick health & behavior check before coding
make lint
make test-push

# … edit files, add commits …
git commit -m "feat: …"
git push
```

## What’s actually installed?

- `act` (pinned version) – local GitHub Actions runner
- `shellcheck` – bash linter
- `pre-commit` + hooks (black, shellcheck, trailing whitespace, etc.)
- `detect-secrets` – secret scanning
- `gh` CLI – GitHub from terminal
- Utilities: jq, fzf, tree, curl, git
- Strict outbound firewall (configurable in `.devcontainer/init-firewall.sh`)

Next → [02 – Branching Strategy](02-branching.md)
