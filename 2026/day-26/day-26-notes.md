# Day 26 – GitHub CLI (`gh`): Manage GitHub From Your Terminal
*#90DaysOfDevOps 2026*

---

## Task 1 — Install and Authenticate

### Install

```bash
# Windows (winget)
winget install --id GitHub.cli

# macOS (Homebrew)
brew install gh

# Linux (Debian/Ubuntu)
sudo apt install gh

# Verify the install
gh --version
# gh version 2.x.x
```

### Authenticate

```bash
gh auth login
```

`gh auth login` walks through an interactive prompt:
- **What account?** → GitHub.com (or GitHub Enterprise)
- **Preferred protocol?** → HTTPS or SSH
- **Authenticate how?** → *Login with a web browser* (gives a one-time code) or *Paste an authentication token*

### Verify

```bash
gh auth status
# ✓ Logged in to github.com account ameertechy (keyring)
# - Active account: true
# - Git operations protocol: https
# - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

### Answer — What authentication methods does `gh` support?

| Method | How it works |
|--------|-------------|
| **Web browser (OAuth)** | `gh` opens github.com, you paste a one-time code, GitHub issues a token. Easiest and most secure for a personal machine. |
| **Personal Access Token (PAT)** | Paste an existing token, or pipe it: `gh auth login --with-token < token.txt`. Best for **CI/CD and automation** where no browser exists. |
| **GitHub Enterprise** | Same flows, but against a self-hosted host: `gh auth login --hostname git.company.com`. |
| **Protocol choice** | During login you also choose **HTTPS** or **SSH** as the git transport. |

> In automation, the token method (via the `GH_TOKEN` / `GITHUB_TOKEN` env var) is what makes `gh` work headlessly inside a pipeline.

---

## Task 2 — Working with Repositories

```bash
# 1. Create a new PUBLIC repo with a README, from the terminal
gh repo create gh-cli-test --public --add-readme --description "Day 26 gh test repo"

# 2. Clone a repo using gh (resolves owner automatically)
gh repo clone ameertechy/gh-cli-test

# 3. View details of a repo from the terminal
gh repo view ameertechy/gh-cli-test

# 4. List all my repositories
gh repo list ameertechy --limit 30

# 5. Open the repo in the browser from the terminal
gh repo view ameertechy/gh-cli-test --web

# 6. Delete the test repo (careful — irreversible!)
gh repo delete ameertechy/gh-cli-test --yes
```

**What happened:**
- `gh repo create` made the repo **and** initialised it with a README in one shot — no browser, no `git init` + remote dance.
- `gh repo clone` is `git clone` with owner-awareness — `owner/repo` is enough, no full URL needed.
- `gh repo view` printed the README and repo metadata right in the terminal; adding `--web` opened it in the browser instead.
- `gh repo delete` required the `--yes` flag (or an interactive confirmation) — a deliberate guard against fat-finger deletion. *(Deleting needs the `delete_repo` token scope: `gh auth refresh -s delete_repo`.)*

---

## Task 3 — Issues

```bash
# 1. Create an issue with a title, body, and a label
gh issue create --repo ameertechy/gh-cli-test \
  --title "Document the gh workflow" \
  --body "Add a section covering gh issue and gh pr commands." \
  --label "documentation"

# 2. List all open issues
gh issue list --repo ameertechy/gh-cli-test

# 3. View a specific issue by its number
gh issue view 1 --repo ameertechy/gh-cli-test

# 4. Close an issue from the terminal
gh issue close 1 --repo ameertechy/gh-cli-test
```

**What happened:**
- The issue was created and `gh` returned the issue URL immediately.
- `gh issue list` showed number, title, labels, and age in a clean table.
- `gh issue close` flipped the state to closed without touching the browser.

### Answer — How could you use `gh issue` in a script or automation?

- **Auto-create issues from failures** — a failed cron job or monitoring check can run `gh issue create` to file a ticket automatically, with logs in the body.
- **Triage at scale** — loop over `gh issue list --json number,labels` piped to `jq` to auto-label, assign, or close stale issues.
- **Bridge other systems** — sync alerts from Datadog/PagerDuty into GitHub issues, or close issues automatically when a deploy succeeds.
- **Reporting** — `gh issue list --json` feeds dashboards: open-bug counts, oldest issues, label breakdowns.

---

## Task 4 — Pull Requests

```bash
# 1. Branch → change → push → PR, entirely from the terminal
git checkout -b feature-readme-update
echo "## Usage" >> README.md
git add README.md
git commit -m "docs: add usage section"
git push -u origin feature-readme-update

gh pr create --title "Add usage section" --body "Documents how to use the tool." --base main
# or auto-fill title/body from commits:
# gh pr create --fill

# 2. List all open PRs
gh pr list --repo ameertechy/gh-cli-test

# 3. View PR details — status, reviewers, checks
gh pr view 2 --repo ameertechy/gh-cli-test
gh pr checks 2 --repo ameertechy/gh-cli-test   # CI check status

# 4. Merge the PR from the terminal
gh pr merge 2 --squash --delete-branch
```

**What happened:**
- `gh pr create` opened the PR and returned its URL — no browser round-trip.
- `gh pr view` showed the PR body, the reviewers, and the check status inline; `gh pr checks` listed each CI check with pass/fail.
- `gh pr merge --squash --delete-branch` squashed the commits, merged to `main`, and cleaned up the feature branch in one command.

### Answer — What merge methods does `gh pr merge` support?

| Flag | Strategy | Result |
|------|----------|--------|
| `--merge` | Merge commit | Keeps all commits + adds a merge commit (full history) |
| `--squash` | Squash merge | Combines all PR commits into **one** commit on the base branch |
| `--rebase` | Rebase merge | Replays the PR commits onto the base — linear history, no merge commit |

> These are the same three strategies from **Day 24** — now driven from the terminal. Add `--delete-branch` to remove the branch after merge, and `--auto` to merge automatically once checks pass.

### Answer — How would you review someone else's PR using `gh`?

```bash
gh pr list                       # find the PR
gh pr checkout 7                 # check out their branch locally to test it
gh pr diff 7                     # read the diff in the terminal
gh pr review 7 --approve         # approve
gh pr review 7 --request-changes --body "Please add tests"
gh pr review 7 --comment --body "Looks good, one nit below"
```

- `gh pr checkout` pulls the contributor's branch so I can run and test it locally.
- `gh pr review` submits the verdict — approve, request changes, or comment — without opening GitHub.

---

## Task 5 — GitHub Actions & Workflows (Preview)

```bash
# 1. List recent workflow RUNS on a repo that uses Actions
gh run list --repo cli/cli --limit 10

# 2. View the status/details of a specific run (by its ID)
gh run view 1234567890 --repo cli/cli

# List the WORKFLOWS defined in a repo
gh workflow list --repo cli/cli
```

**What happened:**
- `gh run list` showed each run's status (✓/✗/in-progress), the triggering event, the branch, and the run ID.
- `gh run view <id>` drilled into a single run's jobs and steps.
- `gh workflow list` showed the workflow definitions (the `.github/workflows/*.yml` files), each with an ID and state.

### Answer — How could `gh run` and `gh workflow` be useful in a CI/CD pipeline?

- **Watch a run live** — `gh run watch` streams a run to completion; great for a deploy you need to babysit.
- **Re-trigger without the browser** — `gh run rerun <id>` retries a flaky failed run; `gh workflow run <name>` manually kicks off a `workflow_dispatch` job.
- **Gate scripts on results** — `gh run view --json conclusion` lets a script wait for a pipeline to go green before doing the next step (e.g. promote to prod).
- **Debug fast** — `gh run view --log-failed` dumps just the failed step's logs straight into the terminal during an incident.

---

## Task 6 — Useful `gh` Tricks

```bash
# gh api — raw GitHub API calls from the terminal
gh api /user                                   # your authenticated profile
gh api /repos/ameertechy/90DaysOfDevOps        # any REST endpoint
gh api /repos/cli/cli/issues --jq '.[].title'  # filter with built-in jq

# gh gist — create and manage Gists
gh gist create notes.md --public --desc "My gh notes"
gh gist list

# gh release — create and manage releases
gh release create v1.0.0 --title "First release" --notes "Initial version"
gh release list

# gh alias — shortcuts for commands you use often
gh alias set prc 'pr create --fill'    # now `gh prc` = gh pr create --fill
gh alias set bugs 'issue list --label "bug"'
gh alias list

# gh search — search GitHub from the terminal
gh search repos "kubernetes operator" --language=go --limit 10
gh search issues "is:open label:good-first-issue" --repo cli/cli
```

**Most useful for me:**
- **`gh api`** — the universal escape hatch; anything the website can do, the REST API (and `gh api`) can do, scriptably.
- **`gh alias`** — turns my most-typed command (`gh pr create --fill`) into a two-letter shortcut.
- **`gh search repos`** — research and discovery without leaving the terminal.

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| One-time auth | `gh auth login` stores a token securely; everything afterward reuses it — the basis for automation. |
| `--json` + `jq` | Turns every list/view command into structured, scriptable data. |
| `gh pr merge` strategies | `--merge` / `--squash` / `--rebase` = the Day 24 merge concepts, now executable. |
| `--repo owner/repo` | Targets any repo without being inside its folder. |
| Destructive guard | `gh repo delete` needs `--yes` — the same caution as `git reset --hard`. |

---

*#90DaysOfDevOps 2026*
