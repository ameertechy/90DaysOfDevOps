# Day 26 – GitHub CLI: Manage GitHub From Your Terminal

## Overview

Day 26 is about killing the context-switch. Every time I leave the terminal to open a browser tab — to raise a PR, check an issue, or spin up a repo — I lose focus and break my flow. The **GitHub CLI (`gh`)** brings GitHub *into* the terminal, so repos, issues, pull requests, releases, and even GitHub Actions runs are all a single command away.

For a DevOps engineer this is not a convenience — it is a foundation. The moment GitHub becomes scriptable, it becomes automatable. `gh` speaks JSON, plugs into shell pipelines, and authenticates once — which means PR reviews, issue triage, and repo provisioning can all be wired into automation later.

Today I installed and authenticated `gh`, then drove the full GitHub lifecycle from the command line: created and deleted repos, opened and closed issues, raised and merged a pull request end-to-end, previewed GitHub Actions runs, and explored the power-user tricks (`gh api`, `gh alias`, `gh search`).

---

## What I Produced

- [`day-26-notes.md`](./day-26-notes.md)
- Updated `git-commands.md` (now a complete Git **and** GitHub reference, Days 22–26)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Installed `gh`, authenticated via browser OAuth, verified the active account with `gh auth status` |
| 2 | Created a public repo from the terminal, cloned with `gh repo clone`, viewed + listed repos, opened in browser, then deleted the test repo |
| 3 | Created a labelled issue, listed open issues, viewed one by number, closed it from the terminal |
| 4 | Branched → committed → pushed → raised a PR → checked status → merged it, all without leaving the terminal |
| 5 | Listed and inspected GitHub Actions workflow runs on a public repo with `gh run` / `gh workflow` |
| 6 | Explored `gh api`, `gh gist`, `gh release`, `gh alias`, and `gh search repos` |

---

## Key Observations

**`gh` authenticates once and remembers — that single login is what unlocks automation.**
After `gh auth login`, the token is stored securely and every later command reuses it. No re-typing credentials, no embedding tokens in scripts. This one-time trust is exactly why `gh` slots so cleanly into CI/CD and shell automation.

**The `--json` flag turns GitHub into a data source.**
Almost every list/view command accepts `--json` with a field selector, emitting machine-readable output. Piped into `jq`, that means issues, PRs, and runs become structured data I can filter, count, and act on in a script — the difference between *reading* GitHub and *programming* it.

**`gh pr merge` carries the same three strategies I learned on Day 24.**
`--merge`, `--squash`, and `--rebase` map directly to the merge concepts from earlier in the week — only now I'm choosing the integration strategy from the terminal instead of clicking a green button. The CLI didn't add new theory; it made the theory executable.

**`gh repo delete` is the `--hard` reset of GitHub — irreversible.**
Deleting a repo from the terminal is instant and asks for a confirmation by design. It reinforced the same lesson as `git reset --hard`: destructive commands deserve a deliberate pause, not muscle memory.

---

## Real-World Tie-in

- **Repo provisioning at scale** — `gh repo create` from a script means a new university microservice, lab project, or automation repo can be stamped out with consistent settings instead of hand-clicking the GitHub UI each time.
- **Issue + PR automation** — `gh issue` and `gh pr` with `--json` are the building blocks of bots: auto-labelling tickets, nudging stale PRs, or gating a merge on checks — the kind of glue that keeps a busy infrastructure team moving.
- **CI/CD visibility** — `gh run` and `gh workflow` let me watch and re-trigger pipeline runs without opening the browser, which is exactly how you debug a failed deployment fast when production is waiting.
- **The terminal becomes the single pane of glass** — for managing university infrastructure changes, staying in one tool (code, commits, PRs, pipeline status) removes the friction that causes mistakes during a change window.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#GitHub` `#GitHubCLI` `#DevOps`
