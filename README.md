# GitHub Actions Template

<p align="center">
  <a href="https://github.com/BrainXio">
    <img src="https://github.com/BrainXio.png" alt="BrainXio Logo" width="80" height="80">
  </a>

  <p align="center" style="font-size: 1.1em; font-style: italic; margin: 1.5em auto;">
    Curiosity. Freedom. Creation.
  </p>
</p>

---

<p align="center">
  <a href="https://github.com/BrainXio"><strong>Explore the Factory →</strong></a>
  ·
  <a href="https://github.com/BrainXio/github-actions-template/issues/new?labels=bug&template=bug-report.md">Report Bug</a>
  ·
  <a href="https://github.com/BrainXio/github-actions-template/issues/new?labels=enhancement&template=feature-request.md">Request Feature</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/BrainXio/github-actions-template?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/stars/BrainXio/github-actions-template?style=flat-square" alt="Stars">
  <img src="https://img.shields.io/github/forks/BrainXio/github-actions-template?style=flat-square" alt="Forks">
  <img src="https://github.com/BrainXio/github-actions-template/workflows/CI/badge.svg" alt="CI">
</p>

## Quick start

1. Use this template to create a new repository
2. Customize `action.yml` and your script(s)
3. Open in VS Code / Codespaces → Reopen in Container
4. Run:

```bash
make setup         # installs act, shellcheck, pre-commit, etc.
make lint
make check-secrets
make test-push     # quick local test
```

## What's included

- `.devcontainer/`          → full local dev environment
- `Makefile`                → commands (setup, lint, test-*, secrets)
- `.pre-commit-config.yaml` → auto checks on commit
- `action.yml`              → placeholder action
- `.github/workflows/ci.yml` → basic test workflow

## License

Not specified (public domain)
