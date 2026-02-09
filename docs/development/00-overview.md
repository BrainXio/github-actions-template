# Overview

This document provides a comprehensive overview of the GitHub Actions template project and its development workflow.

## What This Template Provides

This is a modern, beginner-friendly, production-ready template for building **composite** GitHub Actions. It includes everything you need to create, test, and release GitHub Actions with a robust development workflow.

## Core Principles

1. **GitHub Flow** – only one long-lived branch: `main`
2. **Conventional Commits** – automatic semantic versioning & changelogs
3. **Fast local testing** with `act` (no need to push every change)
4. **One-command reproducible environment** via DevContainer
5. **Zero manual release steps** after initial baseline tag

## Project Structure

```
.
├── action.yml                 # Main action definition
├── src/                       # Action source code
│   └── entrypoint.sh         # Bash script that executes the action
├── .devcontainer/             # VS Code devcontainer configuration
├── .github/
│   └── workflows/            # CI/CD workflows
├── docs/                      # Documentation
│   └── development/          # Development guide
├── Makefile                   # Development workflow commands
├── .pre-commit-config.yaml    # Pre-commit hooks configuration
└── CLAUDE.md                  # Guidance for Claude Code
```

## Development Workflow

The template follows a well-defined development lifecycle that integrates with GitHub's ecosystem:

1. **Environment Setup** – Local development with VS Code/Codespaces
2. **Branching Strategy** – Feature branches with conventional commits
3. **Local Testing** – Using `act` for event simulation
4. **CI Pipeline** – Automated validation and testing
5. **Releasing** – Automated versioning and publishing

## Key Tools

- **VS Code DevContainer** – Reproducible local environment
- **act** – Local GitHub Actions testing
- **pre-commit hooks** – Automated code quality checks
- **shellcheck** – Bash script linting
- **semantic-release** – Automated versioning and releases
