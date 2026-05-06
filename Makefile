.PHONY: lint setup secrets-scan-staged hooks

lint:
	actionlint

setup:
	@command -v gitleaks >/dev/null 2>&1 || (echo "install gitleaks first"; exit 1)
	@command -v actionlint >/dev/null 2>&1 || (echo "install actionlint first"; exit 1)
	./scripts/bootstrap_lefthook.sh

secrets-scan-staged:
	gitleaks protect --staged --no-banner

hooks:
	./scripts/bootstrap_lefthook.sh
