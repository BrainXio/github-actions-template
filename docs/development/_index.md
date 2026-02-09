# GitHub Actions Template – Development Guide

Modern, beginner-friendly, production-ready template for building **composite** GitHub Actions.

**Core principles**
- GitHub Flow – only one long-lived branch: `main`
- Conventional Commits → automatic semantic versioning & changelogs
- Fast local testing with `act` (no need to push every change)
- One-command reproducible environment via DevContainer
- Zero manual release steps after initial baseline tag

## Quick Start (5–10 minutes)

1. Create your new repository from this template
2. Open in VS Code or Codespaces → **Reopen in Container**
3. Wait for automatic setup (`make setup`) to complete
4. Customize the basics in `action.yml`:

```yaml
name:        'My Awesome Action'
description: 'Does one thing really well'
author:      '@your-username'
```

5. Replace or extend the placeholder logic in `src/entrypoint.sh`
6. Run your first local test:

```bash
make test-push
```

7. Start your first real change:

```bash
git checkout -b feat/add-my-first-input

# … make changes …
make lint
make test-push

git commit -m "feat: add my first input"
git push -u origin HEAD
```

Open a PR → squash-merge → watch automatic release happen.

## Development Lifecycle at a Glance

- [01-setup.md](01-setup.md) – **Environment & Tools** (`make setup`, `make help`)
- [02-branching.md](02-branching.md) – **Branching rules** (`feat/…`, `fix/…` branches)
- [03-conventional-commits.md](03-conventional-commits.md) – **Commit & PR conventions** (`feat:`, `fix:`, `BREAKING CHANGE:`)
- [04-testing.md](04-testing.md) – **Local testing** (`make test-push`, `make tests`)
- [05-adding-features.md](05-adding-features.md) – **Adding features** (New inputs, outputs, logic)
- [06-releasing.md](06-releasing.md) – **Releasing** (Automatic after merge)
- [07-common-scenarios.md](07-common-scenarios.md) – **Recipes & examples** (Real-world how-tos)
- [08-troubleshooting.md](08-troubleshooting.md) – **Troubleshooting** (When things go wrong)
- [10-claude.md](10-claude.md) – **Working with Claude** (Claude Code integration)

Start here → [01 – Development Environment Setup](01-setup.md)
