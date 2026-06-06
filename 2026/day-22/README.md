# Day 22 – Git: From Basics to Advanced in One Session

## Overview

Day 22 was a full live session with Shubham covering Git from ground up to advanced — basics, branching, merging, rebase, stash, cherry-pick, reset, revert, squash, and GitHub authentication via SSH and HTTPS with PAT tokens.

Git is not just a DevOps tool. It is the foundation every other tool builds on — Dockerfiles, Kubernetes manifests, Ansible playbooks, Terraform configs, CI/CD pipelines. Every change to every file in a DevOps pipeline is tracked by Git. Learning it properly once means never being blocked by it again.

---

## What I Produced

- [`git-commands.md`](./git-commands.md) — living reference, updated each day
- [`day-22-notes.md`](./day-22-notes.md) — concepts answered in my own words

---

## Key Observations

**Git has three areas — working directory, staging area, repository.**
This is the mental model that makes everything else click. The working directory is where you edit files. The staging area is where you decide what goes into the next commit. The repository is the permanent history. `git add` moves changes from working directory to staging. `git commit` moves staged changes into the repository.

**Rebase rewrites history — merge preserves it.**
`git merge` creates a merge commit — the branch history stays visible. `git rebase` moves commits onto a new base — the history is linear but rewritten. For local branches, rebase keeps things clean. For shared branches, never rebase — it rewrites commits others have already pulled.

**Reset vs revert — the key difference is safety.**
`git reset` moves the branch pointer backwards — it rewrites history. Safe only on local unpushed commits. `git revert` creates a new commit that undoes a previous one — history is preserved. Always use `revert` on commits that have been pushed to a shared branch.

**SSH authentication is the production standard.**
HTTPS with PAT tokens works but requires credential management. SSH key pairs authenticate without passwords — the private key stays on the machine, the public key is added to GitHub once. Every git push and pull authenticates automatically. This is the standard for CI/CD pipelines and server automation.

**Squash keeps commit history clean.**
Multiple small commits during feature development get squashed into one meaningful commit before merging. Instead of "fix typo", "fix again", "finally working" — one clean "Add user authentication feature" commit in the main branch history.

---

## Real-World Tie-in

- Every infrastructure change I make from Day 29 onwards — Docker configs, Kubernetes manifests — lives in a Git repo with meaningful commit messages
- Branching strategy is how teams work in parallel without breaking each other's code — same as how I coordinate change windows in the data centre
- `git stash` is what I use when a production incident interrupts feature work — save current state, fix the incident, restore
- SSH key authentication on EC2 is identical to the GitHub SSH key pattern — same key pair concept I use daily for server access

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Git` `#GitHub` `#DevOps`
