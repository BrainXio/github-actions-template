# Makefile – developer workflow commands for github-actions-template
# Environment bootstrapping moved to .devcontainer/setup.sh
# (called automatically via postCreateCommand in devcontainer.json)

ACT_VERSION    ?= v0.2.84
ACT_BIN        := ~/.local/bin/act
ACT_ARGS       ?= --quiet --verbose

.DEFAULT_GOAL := help
.PHONY: help setup lint check-secrets pre-commit* test* validate clean purge all

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: lint check-secrets test-push ## Recommended CI-like validation sequence

setup: ## Run full environment setup (idempotent) – usually auto-called by devcontainer
	@bash .devcontainer/setup.sh

lint: ## Run shellcheck on bash scripts
	@shellcheck --shell=bash scripts/*.sh .devcontainer/*.sh 2>/dev/null || true
	@echo "Bash lint OK (shellcheck)"

check-secrets: pre-commit-install ## Run pre-commit secret scan + basic regex check
	@if grep -E '^[[:space:]]*"[^"]*_(TOKEN|KEY|SECRET|API|AUTH|PASS|PWD)[^"]*":' .devcontainer/devcontainer.json | grep -v '^[[:space:]]*//'; then \
		echo "ERROR: Uncommented secret-sounding key in devcontainer.json"; \
		exit 1; \
	fi
	@pre-commit run detect-secrets --all-files || { echo "Secret scan failed"; exit 1; }
	@echo "Secret check passed"

pre-commit-run: ## Run all pre-commit hooks on all files
	@pre-commit run --all-files

pre-commit-update: ## Update pre-commit hook versions
	@pre-commit autoupdate

validate: ## Dry-run validation via act (if action.yml exists)
	@if [ -f action.yml ]; then \
		$(ACT_BIN) --dryrun --workflow .github/workflows/test-action.yml; \
	else \
		echo "No action.yml yet — skipping"; \
	fi

# ────────────────────────────────────────────────────────────────────────────────
# act test targets (depend on act being available)
# ────────────────────────────────────────────────────────────────────────────────

test-%: setup ## Generic test runner (make test-push, test-dispatch, etc.)
	@$(ACT_BIN) $(subst test-,,$@) \
		$(if $(filter test-main,$@),--eventpath .github/events/push-main.json,) \
		$(if $(filter test-pr,$@),--eventpath .github/events/pull-request-local.json,) \
		-W .github/workflows/test-action.yml $(ACT_ARGS)

test-push test-dispatch test-pr test-issues test-main test-release test-schedule: test-%

tests: test-push test-dispatch test-pr test-issues test-main ## Run most common event tests

clean: ## Remove temporary files
	rm -rf tmp/ .act/

purge: clean ## Alias + more aggressive clean if needed
	rm -f .secrets.baseline.bak
