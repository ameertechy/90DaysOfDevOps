# Day 40 – Your First GitHub Actions Workflow

## Overview

This is the day CI/CD stopped being a concept and became real. After understanding the *why* on Day 39, Day 40 is the *how*: write a **GitHub Actions** workflow, push it, and watch GitHub run it in the cloud — on a fresh Ubuntu runner it spins up just for me.

Rather than a throwaway repo, I put the workflow straight into my own **DevBoard** project (on a practice branch so `master` stays clean). I wrote `.github/workflows/hello.yml` (trigger on push, one job, check out the code, print a greeting), and watched it go **green** in the Actions tab. Then I extended it — date, the triggering branch, a file listing, the runner OS, and a check that Go and Node are present (the tools DevBoard actually needs) — and finally **broke it on purpose** with `exit 1` to see what a red run looks like and how the job halts at the first failure.

Everything from the last two days came together here: the file is **YAML** (Day 38), and its structure is **trigger → job → steps** (Day 39). The vocabulary became keys I could actually type.

---

## What I Produced

- [`day-40-first-workflow.md`](./day-40-first-workflow.md) — my notes: the full workflow YAML, the anatomy of every key, the extra steps, and what a failed run looks like
- A working `hello.yml` in my **DevBoard** repo (push-triggered, runs on `ubuntu-latest`)
- Screenshot of my first **green** pipeline run in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Used my **DevBoard** repo (practice branch) and added the `.github/workflows/` folder |
| 2 | Wrote `hello.yml` — trigger on `push`, job `greet`, `actions/checkout`, print a greeting → **green run** |
| 3 | Documented what each key does: `on`, `jobs`, `runs-on`, `steps`, `uses`, `run`, `name` |
| 4 | Added steps for the date, the triggering branch, a file listing, the runner OS, and a Go/Node check |
| 5 | **Broke it on purpose** with `exit 1`, read the red run, then fixed it |

---

## Key Observations

**A workflow is just YAML describing trigger → job → steps.**
Every Day 39 concept turned into a literal key: `on:` is the trigger, `jobs:` holds the jobs, `steps:` are the steps, `runs-on:` is the runner. The abstract vocabulary became something I typed and watched execute.

**`uses:` reuses, `run:` runs.**
`uses: actions/checkout@v4` pulls in an action someone already wrote (checking out my code), while `run:` executes a shell command I write myself. Knowing which is which is most of reading any workflow file.

**Context variables come from GitHub, not from me.**
`${{ github.ref_name }}` (the triggering branch) and `${{ runner.os }}` are injected by GitHub at run time — my first taste of how a pipeline knows about its own environment.

**Red is information.**
A failed step (`exit 1`) turned the run red, skipped everything after it, and pointed at the exact command. That's the safety net working: broken code can't move down the pipeline.

---

## Real-World Tie-in

- **The cloud runner is the "clean room" I never had.** Every run starts on a fresh Ubuntu VM with nothing left over from a previous run — the opposite of a long-lived server that slowly drifts. That reproducibility is exactly what makes pipeline results trustworthy.
- **This is a runbook that executes itself.** I've written plenty of step-by-step procedures for the datacenter; a workflow is that, except it runs the same way every time and records every step's output.
- **Failing fast is cheaper than failing late.** Watching the pipeline stop at the first broken step is the automation version of catching a problem on a monitor before it becomes an outage.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#GitHubActions` `#CICD` `#DevOps`
