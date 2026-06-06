# Day 22 – Git Concepts: My Own Words
*#90DaysOfDevOps 2026*

---

## Q1: What is the difference between `git add` and `git commit`?

`git add` moves changes from the working directory into the staging area. It is selecting what you want to include in the next snapshot. Nothing is saved permanently yet — you are just deciding what goes in.

`git commit` takes everything in the staging area and saves it permanently into the repository as a snapshot with a timestamp, author, and message. Once committed, that state is part of the history forever.

Think of it like packing a shipment: `git add` = put items in the box. `git commit` = seal the box, label it, and send it.

---

## Q2: What does the staging area do? Why not commit directly?

The staging area gives fine-grained control over what goes into each commit. Without it, every change in the working directory would go into every commit — messy and hard to read.

With staging, I can change 5 files but only stage and commit 2 of them — keeping the commit focused on one thing. Then commit the other 3 separately with a different message.

In production this matters: one commit for "fix nginx config", another for "update SSL cert path". Clean history is searchable, debuggable, and reviewable.

---

## Q3: What information does `git log` show?

Each commit entry shows:
- Commit hash — the unique 40-character SHA1 identifier
- Author — who made the commit
- Date — when it was committed
- Message — what the commit contains

`git log --oneline` shows just the short hash and message — the most useful format for navigating history quickly.

---

## Q4: What is the `.git/` folder and what happens if you delete it?

`.git/` is the entire Git database — every commit, every branch, every config, every blob of every file ever committed. It lives inside the project folder.

If you delete it: the project files remain but all Git history is gone. The directory is no longer a Git repository. There is no undo. The remote repository on GitHub would be the only surviving copy of the history.

This is why Git repos are backed up — the `.git/` directory is what needs protecting.

---

## Q5: Working directory vs staging area vs repository

**Working directory:** The actual files on disk that I edit. Git tracks changes here but does not store them yet.

**Staging area (index):** A holding area between working directory and repository. `git add` puts changes here. I review and decide before making permanent.

**Repository:** The `.git/` database. Every committed snapshot is stored here permanently. `git commit` moves staged changes into the repository.

The flow is one-way: working directory → staging area → repository. To go backwards, `git restore` or `git reset` is needed.

---

## Q6: Merge vs Rebase — when to use each?

**Merge** preserves the full history. When feature branch is merged into main, a merge commit is created and the branch history is visible. Honest — shows exactly what happened and when.

**Rebase** rewrites history. It takes commits from the feature branch and replays them on top of main — as if the feature was always developed on top of the latest main. Result is a clean linear history.

**Rule:** Rebase local feature branches before opening a PR — keeps the history clean. Never rebase a branch that others have already pulled — it rewrites commits they have and causes conflicts.

---

## Q7: Reset vs Revert — when to use each?

**Reset** moves the branch pointer backwards — it undoes commits by removing them from history.
- `--soft` = undo commit, keep changes staged
- `--mixed` = undo commit, keep changes unstaged
- `--hard` = undo commit, delete changes completely

Use reset only on local commits that have NOT been pushed. Rewriting pushed history breaks everyone who has pulled.

**Revert** creates a NEW commit that undoes a previous commit. The original commit stays in history — nothing is rewritten. Safe on any branch, pushed or not.

**Rule:** Reset for local cleanup. Revert for anything already shared.

---

## Q8: What is git stash and when do I use it?

`git stash` saves the current state of the working directory and staging area into a temporary holding area, then cleans the working directory back to the last commit.

Use it when: I am mid-way through a feature, an urgent production issue comes in. I cannot commit half-finished work. Stash it, fix the issue, pop the stash and continue.

`git stash pop` restores the stashed changes and removes them from the stash list. `git stash apply` restores but keeps the stash — useful if I want to apply the same changes to multiple branches.

---

## Q9: What is cherry-pick?

`git cherry-pick <hash>` takes a specific commit from any branch and applies it to the current branch — without merging the entire branch.

Use case: a critical bug fix was committed on the development branch. Production is on main. I do not want all the unfinished development work — I only want that one fix. Cherry-pick applies just that commit to main.

---

## Q10: SSH vs HTTPS — which and why?

**HTTPS** uses username + PAT token. Simple to set up. Requires credential management — either re-entering credentials or using a credential helper to cache them.

**SSH** uses a key pair. Public key on GitHub, private key on the machine. Authentication is automatic — no password or token entry. More secure and the standard for production servers, CI/CD pipelines, and automation.

On EC2, SSH is the correct choice. The server already uses SSH key pairs for access. Adding a GitHub SSH key follows the same pattern I already understand.

---

*#90DaysOfDevOps 2026*
