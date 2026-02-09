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

## What's included

- **Core action**
  `action.yml` → action metadata & definition
  `src/entrypoint.sh` → bash entrypoint logic

- **Development environment**
  `.devcontainer/` → full local devcontainer (setup.sh, firewall, MCP init)

- **Workflow & automation**
  `Makefile` → main commands (setup, lint, test-*, secrets, pre-commit)
  `.pre-commit-config.yaml` → automatic pre-commit checks
  `.github/workflows/ci.yml` → main CI + release pipeline
  `.github/workflows/issue-triage.yml` → optional issue auto-label & welcome

- **Documentation**
  `docs/development/` → full development guide (branching, commits, testing, releasing, etc.)
  `docs/workflows/` → detailed explanations of CI and issue-triage workflows

- **Supporting files**
  `.gitignore` → standard ignores
  `.releaserc.json` → semantic-release config
  `.github/events/` → mock event payloads for local act testing

## Quick start

1. **Use this template** to create a new repository
2. **Customize** `action.yml` (name, description, inputs, outputs, branding) and your script(s) in `src/`
3. **Open** in VS Code / Codespaces → **Reopen in Container**
4. **Wait** for automatic setup (runs `make setup` — installs act, shellcheck, pre-commit, etc.)
5. **Develop & test** with these core commands:

```bash
make setup         # one-time setup (safe to re-run)
make lint          # shellcheck on all bash files
make check-secrets # scan for accidental secrets
make test-push     # quick local test (push event)
make tests         # run all common event tests
```

Full command list: `make help`

## Developer Guide

Full documentation for working with this template:

| Topic                     | Description                                      | Link |
|---------------------------|--------------------------------------------------|------|
| Overview & Table of Contents | Landing page + quick navigation                  | [Development Guide](./docs/development/index.md) |
| Branching Strategy        | Naming, GitHub Flow, PR process                  | [Branching](./docs/development/branching.md) |
| Conventional Commits      | Commit message format + version bumping rules    | [Commits](./docs/development/commits.md) |
| Development Environment   | DevContainer, Makefile commands, daily workflow  | [Environment](./docs/development/environment.md) |
| Testing Locally           | act, make test-*, event simulation               | [Testing](./docs/development/testing.md) |
| Adding Features           | New inputs/outputs/logic, testing, PR flow       | [Adding Features](./docs/development/adding-features.md) |
| Releasing                 | Automated releases, first tag, dry-run results   | [Releasing](./docs/development/releasing.md) |
| Common Scenarios          | Real-world recipes & examples                    | [Common Scenarios](./docs/development/common-scenarios.md) |

## License

Not set (Public domain)
