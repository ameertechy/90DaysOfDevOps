# Day 41 – Triggers & Matrix Builds
*#90DaysOfDevOps 2026*

Day 40 hardwired `on: [push]`. Today is about all the other ways to start a workflow — and how to multiply one job into many without duplicating code.

All workflows go into my **github-actions-practice** repo, directly on `main`.

---

## Task 1 — Pull Request Trigger

`.github/workflows/pr-check.yml`:
```yaml
name: PR Check

on:
  pull_request:
    branches: [main]           # only PRs targeting main

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Print PR branch
        run: echo "PR check running for branch: ${{ github.head_ref }}"
```

Key points:
- `on: pull_request` fires on PR events: `opened`, `synchronize` (new commit pushed to the PR), and `reopened` by default.
- `branches: [main]` — only PRs targeting `main`. PRs to other branches are ignored.
- `${{ github.head_ref }}` — the **source** branch of the PR (the branch being merged from). `${{ github.base_ref }}` is the target.
- The workflow appears as a **check on the PR page**. If you mark it required in branch protection rules, the PR can't be merged until it passes.

### PR event types (activity types)
```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, closed]
```
Default is `[opened, synchronize, reopened]`. `closed` is the only one you'd add manually.

---

## Task 2 — Scheduled Trigger

```yaml
on:
  schedule:
    - cron: '0 0 * * *'     # every day at midnight UTC
```

### Cron syntax: `minute hour day-of-month month day-of-week`

| Field | Range | Example |
|-------|-------|---------|
| minute | 0–59 | `30` = at :30 |
| hour | 0–23 (UTC) | `9` = 09:00 UTC |
| day-of-month | 1–31 | `*` = every day |
| month | 1–12 | `*` = every month |
| day-of-week | 0–7 (Sun=0 or 7) | `1` = Monday |

| Expression | Meaning |
|-----------|---------|
| `0 0 * * *` | Every day at midnight UTC |
| **`0 9 * * 1`** | **Every Monday at 09:00 UTC** ← answer to Task 2 |
| `*/15 * * * *` | Every 15 minutes |
| `0 8-18 * * 1-5` | Every hour 8am–6pm, Mon–Fri |
| `0 2 1 * *` | 1st of every month at 02:00 |

⚠️ GitHub doesn't guarantee exact cron timing under load — runs may be delayed by minutes. Don't use `schedule:` for hard real-time requirements.

---

## Task 3 — Manual Trigger (`workflow_dispatch`)

```yaml
name: Manual Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Target environment"
        required: true
        default: "staging"
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Print chosen environment
        run: echo "Deploying to ${{ inputs.environment }}"
```

- `workflow_dispatch` — adds a **Run workflow** button in the Actions tab.
- `inputs:` — parameters the user fills in before triggering. The run won't start until all `required` inputs are supplied.
- Input types: `string`, `boolean`, `number`, `choice` (dropdown), `environment`.
- Access values via `${{ inputs.<input-name> }}`.

---

## Task 4 — Matrix Builds

```yaml
name: Matrix Build

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    steps:
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - name: Print Python version
        run: python --version
```

- `strategy: matrix:` — a map of variable names to arrays of values.
- GitHub expands this into one job **per combination** and runs them in parallel.
- `${{ matrix.python-version }}` — injects the current combination's value.
- 3 values → 3 parallel jobs.

### Extended matrix: 2 OSes × 3 versions = 6 jobs

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    python-version: ["3.10", "3.11", "3.12"]

runs-on: ${{ matrix.os }}
```

The matrix is the Cartesian product of all arrays: 2 × 3 = 6 total jobs.

---

## Task 5 — Exclude & Fail-Fast

```yaml
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, windows-latest]
    python-version: ["3.10", "3.11", "3.12"]
    exclude:
      - os: windows-latest
        python-version: "3.10"    # skip this combination → 5 jobs
```

### `fail-fast: true` vs `fail-fast: false`

| | `true` (default) | `false` |
|--|--|--|
| When a job fails | All remaining matrix jobs are cancelled immediately | Other jobs continue to run to completion |
| Result | Faster feedback that *something* broke | Full picture of which combinations pass and which fail |
| Use when | All combos are expected to pass; you want speed | Debugging — want to see the full failure map |

---

## All Trigger Types (Summary)

| Trigger | YAML | When |
|---------|------|------|
| Push | `on: push` | Any commit pushed |
| Pull request | `on: pull_request: branches: [main]` | PR opened / updated / merged |
| Schedule | `on: schedule: - cron: '...'` | Cron-defined time |
| Manual | `on: workflow_dispatch` | Button in Actions tab |
| Another workflow | `on: workflow_call` | Called by a parent workflow |
| Release published | `on: release: types: [published]` | GitHub release created |

---

## Command / Key Reference

| Item | Meaning |
|------|---------|
| `on: pull_request: branches: [main]` | Trigger on PRs targeting main |
| `on: schedule: - cron: '0 9 * * 1'` | Every Monday 09:00 UTC |
| `on: workflow_dispatch: inputs:` | Manual trigger with parameters |
| `strategy: matrix: key: [v1, v2]` | Expand job across multiple values |
| `${{ matrix.key }}` | Current matrix slot value |
| `fail-fast: false` | Don't cancel other jobs on first failure |
| `exclude: - key: val` | Skip one specific combination |
| `${{ github.head_ref }}` | Source branch of a PR |
| `${{ github.base_ref }}` | Target branch of a PR |
| `${{ inputs.name }}` | Value of a workflow_dispatch input |
|  `git clone .../github-actions-practice.git` | Clone the concept-lab repo |
| `git push -u origin <branch>` | Push branch + set upstream |

---

*#90DaysOfDevOps 2026*
