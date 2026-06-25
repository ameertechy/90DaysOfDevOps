# Day 40 – Your First GitHub Actions Workflow
*#90DaysOfDevOps 2026*

The moment CI/CD stops being a concept (Day 39) and becomes real: write a workflow, push it, and watch GitHub run it in the cloud. Yesterday I learned the vocabulary — today those words become keys in a YAML file.

---

## Task 1 — Set Up

Instead of a throwaway repo, I put my first workflow straight into my own **DevBoard** project — a real repo deserves real CI, and this is what the next few days build on. I used a dedicated practice branch so `master` stays clean.

```bash
git clone https://github.com/ameertechy/devboard.git
cd devboard
git checkout -b ci-hello          # practice branch — keeps master green
mkdir -p .github/workflows
```
- `git checkout -b ci-hello` → `-b` creates a new branch and switches to it in one step.
- Workflow files **must** live in `.github/workflows/` and end in `.yml` — that exact path is how GitHub finds them.

---

## Task 2 — Hello Workflow

`.github/workflows/hello.yml`:
```yaml
name: Hello GitHub Actions      # the workflow's display name in the Actions tab

on: [push]                      # TRIGGER — run on every push

jobs:
  greet:                        # one job, named "greet"
    runs-on: ubuntu-latest      # the runner: a fresh Ubuntu VM GitHub gives me
    steps:
      - name: Check out the code
        uses: actions/checkout@v4      # pulls my repo onto the runner

      - name: Say hello
        run: echo "Hello from the DevBoard pipeline!"
```
```bash
git add .github/workflows/hello.yml
git commit -m "Add first GitHub Actions workflow"
git push -u origin ci-hello       # push the branch; -u sets its upstream
```
Then: **GitHub → Actions tab → watch the run.** It went **green** ✅ (screenshot in `screenshots/`). Clicking into the `greet` job shows each step and its log output.

---

## Task 3 — Workflow Anatomy

| Key | What it does |
|-----|-------------|
| `name:` (top) | The workflow's name shown in the Actions tab |
| `on:` | The **trigger** — what event starts the workflow (`push`, `pull_request`, `schedule`, …) |
| `jobs:` | The set of jobs to run; each job runs independently on its own runner |
| `runs-on:` | Which **runner** the job uses — `ubuntu-latest` is a clean Ubuntu VM |
| `steps:` | The ordered list of steps inside a job |
| `uses:` | Run a **prebuilt action** (e.g. `actions/checkout@v4`) instead of a raw command |
| `run:` | Run a **shell command** on the runner |
| `name:` (on a step) | A friendly label for that step in the logs |

**`uses:` vs `run:`** — `uses:` pulls in a reusable action somebody already wrote; `run:` is just a shell command I type myself.

---

## Task 4 — Add More Steps

Extended `hello.yml` so the `greet` job also does this:
```yaml
      - name: Show date and time
        run: date

      - name: Show the branch that triggered this
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List the files in the repo
        run: ls -la

      - name: Show the runner OS
        run: echo "Runner OS: ${{ runner.os }}"

      - name: Confirm DevBoard's tools are on the runner
        run: |
          go version
          node --version
```
- `${{ github.ref_name }}` → a built-in **context variable** — the branch/tag that triggered the run.
- `${{ runner.os }}` → another context variable — the runner's OS (`Linux` here).
- `ls -la` works because `actions/checkout` already put my repo on the runner — without that step there'd be nothing to list.
- `go version` / `node --version` → the GitHub-hosted `ubuntu-latest` runner ships with Go and Node **already installed**, which is exactly what DevBoard's backend and frontend need — a preview of building it for real in the next days. (`|` is the YAML block scalar from Day 38 — it lets one step run multiple lines.)

Pushed again → a new run appeared automatically, and each new step showed its output in the logs.

---

## Task 5 — Break It On Purpose

Added a step that fails:
```yaml
      - name: This fails on purpose
        run: exit 1          # non-zero exit code = step failed
```
Pushed, and in the Actions tab:
- The run went **red** ❌, with a red ✗ on the failing step.
- Every step **after** the failed one was **skipped** — the job stops at the first failure.
- Clicking the failed step showed the command and its exit code in the log, so I could see exactly what broke.

Then I removed that step, pushed again, and the run was green.

### What a failed pipeline looks like / how to read it
A red ✗ marks the exact step that failed; expand it and the log shows the command and error. The job halts there, so anything downstream (build, deploy) never runs — which is the whole safety net: **broken code can't move down the line.**

---

## 3 Key Things I Learned

1. **A workflow is just YAML describing trigger → job → steps.** Every concept from Day 39 is now a literal key: `on:`, `jobs:`, `steps:`, `runs-on:`.
2. **`uses:` reuses, `run:` runs.** Prebuilt actions (like `checkout`) save me from reinventing common steps; `run:` is for my own commands.
3. **Red is information, not failure.** A failed run stops everything downstream and tells me precisely where — exactly the early feedback CI is meant to give.

---

## Command / Key Reference

| Item | Meaning |
|------|---------|
| `.github/workflows/*.yml` | Where workflow files must live |
| `on: [push]` | Trigger on every push |
| `runs-on: ubuntu-latest` | Use a GitHub-hosted Ubuntu runner |
| `uses: actions/checkout@v4` | Check out the repo onto the runner |
| `run: <cmd>` | Run a shell command |
| `${{ github.ref_name }}` | Built-in variable: the triggering branch/tag |
| `${{ runner.os }}` | Built-in variable: the runner's OS |
| `exit 1` | Force a step to fail (non-zero exit) |

---

*#90DaysOfDevOps 2026*
