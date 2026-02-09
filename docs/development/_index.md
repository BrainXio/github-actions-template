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

Phase                     | Document                                      | Key Commands / Focus
--------------------------|-----------------------------------------------|---------------------------------------
1. Environment & Tools    | [01-setup.md](01-setup.md)                    | `make setup`, `make help`
2. Branching rules        | [02-branching.md](02-branching.md)            | `feat/…`, `fix/…` branches
3. Commit & PR conventions| [03-commits.md](03-commits.md)                | `feat:`, `fix:`, `BREAKING CHANGE:`
4. Local testing          | [04-testing.md](04-testing.md)                | `make test-push`, `make tests`
5. Adding features        | [05-adding-features.md](05-adding-features.md)| New inputs, outputs, logic
6. Releasing              | [06-releasing.md](06-releasing.md)            | Automatic after merge
7. Recipes & examples     | [07-common-scenarios.md](07-common-scenarios.md)| Real-world how-tos
8. Troubleshooting        | [08-troubleshooting.md](08-troubleshooting.md)| When things go wrong

Start here → [01 – Development Environment Setup](01-setup.md)
