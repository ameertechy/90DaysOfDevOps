# Day 23 – Git Branching and Working with GitHub

## Overview

Day 23 puts branching and GitHub into practice — the workflow that every team uses to develop features in isolation, push to remote, and collaborate without breaking main.

Coming from 7+ years in infrastructure where change management is critical, branching is the Git equivalent of a change window — work in isolation, test thoroughly, merge only when ready.

---

## What I Produced

- [`day-23-notes.md`](./day-23-notes.md) — concept answers in my own words
- Updated [`git-commands.md`](../day-22/git-commands.md) — branching section added

---

## Tasks Completed

| Task | Description |
|------|-------------|
| Task 1 | Answered: branch, HEAD, file switching |
| Task 2 | Created `feature-1`, `feature-2`, made commits, verified isolation, deleted branches |
| Task 3 | Connected local repo to GitHub, pushed `main` and `feature-1`, verified both visible |
| Task 4 | Edited file on GitHub, pulled changes locally — confirmed `git fetch` vs `git pull` |
| Task 5 | Cloned a public repo, forked it, cloned the fork, documented clone vs fork |

---

## Key Observations

**Branches are just pointers to commits — not copies of files.**
When I create `feature-1`, Git does not copy all the files. It creates a new pointer that starts at the current commit. Switching branches moves `HEAD` — the working directory files change to reflect that branch's state. This is why branching is instant and cheap in Git, unlike creating a full copy of a directory.

**`git switch` vs `git checkout` — modern vs legacy.**
`git checkout` does too many things — switch branches, restore files, detach HEAD. `git switch` was introduced to handle branch switching only. `git restore` handles file restoration. The newer commands are clearer and harder to misuse. Always use `git switch` going forward.

**`origin` is your remote — `upstream` is the original source.**
When I fork a repo, `origin` is my fork on GitHub. `upstream` is the original repo I forked from. Keeping my fork in sync means pulling from `upstream` and pushing to `origin`.

**`git fetch` downloads — `git pull` downloads and merges.**
`git fetch` updates the remote tracking branches (`origin/main`) without touching local branches. `git pull` = `git fetch` + `git merge`. When in doubt, fetch first, review the diff, then merge manually.

---

## Real-World Tie-in

- Feature branches are how every team in this challenge will work from Docker week onwards — nobody commits directly to main
- The fork + PR workflow is exactly how I contribute to Shubham's `90DaysOfDevOps` repo — fork, commit to my fork, raise a PR
- `git fetch` before `git pull` is the safe production habit — see what is coming before applying it

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Git` `#GitHub` `#DevOps`
