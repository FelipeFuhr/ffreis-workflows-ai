# ffreis-workflows-ai

Reusable GitHub Actions workflow library for AI-assisted repository maintenance in the ffreis fleet.

All workflows use `on: workflow_call` and should be consumed from other repositories by pinning to a specific commit SHA.

```yaml
uses: FelipeFuhr/ffreis-workflows-ai/.github/workflows/ai-standardize.yml@<sha> # vX.Y.Z
```

## Workflows

| Workflow file | Purpose | Key inputs |
|---|---|---|
| `ai-standardize.yml` | AI-driven drift detection, AGENTS.md updates, and PR automation | `task`, `dry_run`, `standardizer_ref`; secret `LLM_API_KEY` |

## How to call from another repo

```yaml
# .github/workflows/devops-automation.yml in the consumer repo
jobs:
  ai-standardize:
    uses: FelipeFuhr/ffreis-workflows-ai/.github/workflows/ai-standardize.yml@<sha> # vX.Y.Z
    with:
      task: detect-drift
      dry_run: false
    secrets:
      LLM_API_KEY: ${{ secrets.LLM_API_KEY }}
```

The actual AI implementation lives in [ffreis-workflow-ai-standardizer](https://github.com/FelipeFuhr/ffreis-workflow-ai-standardizer).
This repo is the workflow wrapper layer only.
