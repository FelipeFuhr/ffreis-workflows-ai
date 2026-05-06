.DEFAULT_GOAL := help
SHELL         := /usr/bin/env bash

.PHONY: help lint fmt-check secrets-scan-staged lefthook-bootstrap lefthook-install hooks setup

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Lint all workflow YAML with actionlint
	@command -v actionlint >/dev/null 2>&1 || { \
		echo "ERROR: actionlint not found. Install from https://github.com/rhysd/actionlint"; exit 1; }
	actionlint

fmt-check: ## Validate workflow YAML syntax (actionlint fallback: python yaml)
	@command -v actionlint >/dev/null 2>&1 && actionlint || \
	  python3 -c "import glob, yaml; [yaml.safe_load(open(f)) for f in glob.glob('.github/workflows/*.yml')]; print('YAML valid')"

secrets-scan-staged: ## Scan staged files for secrets
	@command -v gitleaks >/dev/null 2>&1 || { \
		echo "ERROR: gitleaks not found. Install from https://github.com/gitleaks/gitleaks#installing"; exit 1; }
	gitleaks protect --staged --redact

lefthook-bootstrap: ## Download lefthook binary to .bin/
	bash ./scripts/bootstrap_lefthook.sh

lefthook-install: ## Install git hooks via lefthook
	lefthook install

hooks: lefthook-bootstrap lefthook-install ## Bootstrap and install all git hooks

setup: hooks ## Install hooks and verify required tools
	@command -v gitleaks >/dev/null 2>&1 || { \
		echo ""; echo "ACTION REQUIRED: gitleaks is not installed."; \
		echo "Install from https://github.com/gitleaks/gitleaks#installing then re-run 'make setup'."; \
		echo ""; exit 1; }
	@command -v actionlint >/dev/null 2>&1 || { \
		echo ""; echo "ACTION REQUIRED: actionlint is not installed."; \
		echo "Install from https://github.com/rhysd/actionlint then re-run 'make setup'."; \
		echo ""; exit 1; }
	@echo "Dev environment ready."
