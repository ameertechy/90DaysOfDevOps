# Day 41 – Triggers & Matrix Builds

## Overview

Running on every push is just the starting point. Day 41 is about controlling exactly *when* a workflow fires — PR events, a schedule, a manual button press — and how a single job definition multiplies into parallel runs across environments using a matrix strategy.

I practiced this in a dedicated concept lab, my [`github-actions-practice`](https://github.com/ameertechy/github-actions-practice) repo, working directly on `main` — clean experiments, one concept at a time. (These same concepts combine into the real DevSecOps pipeline on my DevBoard project on Days 48–49.) The matrix run was the highlight: one job definition, multiple runners spinning up simultaneously — the Actions tab was busy in a way that made the parallel nature of CI actually visible.

---

## What I Produced

- [`day-41-triggers.md`](./day-41-triggers.md) — notes covering every trigger type, matrix strategy, exclude, and the fail-fast toggle
- Five workflow files on `main` of **github-actions-practice**: `pr-check.yml`, `scheduled.yml`, `manual.yml`, `matrix.yml`, `combined-triggers.yml`
- Five screenshots of the runs in [`screenshots/`](./screenshots/) — PR check, manual dispatch, matrix jobs, combined triggers, `gh run list`

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | PR trigger — `pr-check.yml` fires when a PR is opened or updated against `main`; opened a test PR, watched the check run green, closed it |
| 2 | `schedule:` trigger — daily midnight cron (`0 0 * * *`); worked out the Monday 9 AM expression. No run yet — schedules fire silently at the next matching UTC time on the default branch |
| 3 | `workflow_dispatch:` with an `environment` input (choice: staging / production); ran it from the Actions tab button — first attempt failed, fixed and re-ran green |
| 4 | Matrix build across Python 3.10 / 3.11 / 3.12 — 3 jobs ran in parallel |
| 5 | Extended matrix to 2 OSes with an `exclude:` (6 jobs → 5) and `fail-fast: false` |
| 6 | Combined triggers — `push` + `pull_request` + `workflow_dispatch` on one workflow with a `paths: backend/**` filter; pushed a backend change (fired) and a frontend-only change (skipped). Some push runs failed during experimentation before I got the config right |
| 7 | Monitored everything from the terminal with `gh run list` / `gh run watch` |

---

## Key Observations

**A trigger is a filter on a GitHub event.** `on: push` catches everything. `on: pull_request: branches: [main]` is far more precise — it only fires when someone opens or updates a PR targeting `main`. Wrong trigger = wrong noise in the Actions tab.

**Matrix multiplies, not duplicates.** One job definition, one `strategy: matrix:` block, and GitHub expands it into N parallel jobs, each injecting a different value via `${{ matrix.key }}`. No copy-pasting jobs.

**`fail-fast: false` is a debugging lever.** Default is `true` — the moment one matrix job fails, the rest are cancelled. Setting it to `false` lets all jobs finish, which tells you whether it's one bad combination or a systemic problem. In production, fast feedback wins; in debugging, full visibility wins.

**`workflow_dispatch` is the manual override.** Any workflow you want to trigger without a code push needs this. The `inputs:` key makes it parameterisable — environment name, version number, flags — whatever the job needs at runtime.

**Path filters are the mono-repo cost saver.** With `paths: backend/**`, a frontend-only push doesn't even start the workflow. Watching one commit trigger the run and the next one skip it made the filter concrete.

---

## Real-World Tie-in

- **Schedule triggers ≈ cron jobs I already manage.** In the datacenter I have maintenance scripts that run at set times regardless of what anyone is pushing. `schedule:` does the same for CI — backups, nightly reports, health checks.
- **Matrix across OSes is a multi-server test.** Before rolling a new config script across campus, I'd want to know it works on Ubuntu 22.04 and 24.04 both. A matrix with two OS values is exactly that verification — automated, parallel, recorded.
- **Manual triggers ≈ runbooks with inputs.** I've written step-by-step runbooks where an operator picks an environment before executing. `workflow_dispatch` with a `choice` input is that runbook, automated.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#GitHubActions` `#CI` `#DevOps`
