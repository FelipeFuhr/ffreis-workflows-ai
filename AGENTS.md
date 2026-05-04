# Agent Context

**This repo:** `ffreis-workflows-ai` — reusable GitHub Actions workflow library for
AI-assisted repo maintenance. Exposes `ai-standardize.yml` which any repo can call
to run AI-powered tasks (drift detection, documentation updates, etc.) against itself.

The actual implementation lives in `devops/ffreis-workflow-ai-standardizer`.
This repo is just the workflow wrapper layer.

## Non-obvious rules (read before changing anything)

1. **Every new `ai-*.yml` workflow must be exercised in `ci.yml`** using `dry_run: true`.
   The dry-run validates the pipeline (checkout, build, prompt rendering) without
   spending LLM tokens. Full LLM testing is done manually via `workflow_dispatch`.

2. **`devops-*.yml` workflows are exempt from `ci.yml`** — repo-maintenance workflows
   (stale, security scans) cannot be meaningfully self-tested.

3. **`fetch-depth: 0` is required** on the calling-repo checkout.
   The standardizer needs full git history to compute `diff_since_agents_update`.
   Do not change this to a shallow clone.

4. **`GH_TOKEN` defaults to `github.token`** if the secret is not passed. This is
   intentional: the calling repo's default GITHUB_TOKEN has push access to itself,
   which is sufficient for opening PRs on that repo.

5. **`standardizer_ref` input** lets callers pin to a specific commit SHA of the
   standardizer. Use it for stability in production workflows; leave as `main` for
   development.

6. **Shell injection prevention:** Never interpolate `${{ inputs.* }}` directly into
   `run:` blocks. All inputs are either passed as env vars or validated against
   an allow-list.

## Structure

```
.github/workflows/
  ai-standardize.yml    ← reusable library (the main workflow)
  ci.yml                ← self-test (dry-run) + actionlint
  devops-*.yml          ← repo-maintenance (exempt from self-test)
scripts/hooks/          ← standard git hook scripts
Makefile                ← setup, lint, secrets-scan-staged, hooks
lefthook.yml            ← local git hooks
```

## How to call this workflow from another repo

```yaml
# .github/workflows/ai-standardize.yml in the calling repo
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  standardize:
    uses: FelipeFuhr/ffreis-workflows-ai/.github/workflows/ai-standardize.yml@main
    with:
      task: detect-drift
      dry_run: false
    secrets:
      LLM_API_KEY: ${{ secrets.LLM_API_KEY }}
      # GH_TOKEN defaults to github.token — no need to pass it explicitly
```

## Build/test

```bash
make setup          # install lefthook + check actionlint + gitleaks
make lint           # actionlint on all workflows
make secrets-scan-staged
```

## Keeping this file current

- **If you discover a fact not reflected here:** add it before finishing your task.
- **If something here is wrong or outdated:** correct it in the same commit.
- **If you rename a file, command, or concept:** update the reference here.
