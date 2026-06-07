# Day 23 – Git Branching Notes
*#90DaysOfDevOps 2026*

---

## Task 1 — Understanding Branches

### Q1: What is a branch in Git?

A branch is a lightweight movable pointer to a specific commit. When I create a new branch, Git creates a new pointer — it does not copy files or create a new directory. The pointer starts at the commit I am currently on.

As I make new commits on that branch, the pointer automatically moves forward to point to the latest commit. `main` is just a branch like any other — it is the default one Git creates.

### Q2: Why use branches instead of committing everything to `main`?

Committing directly to `main` means every change — including incomplete, broken, or experimental work — is immediately in the production-ready branch. One bad commit can break a deployment.

Branches provide isolation:
- Feature work happens on `feature/nginx-config`
- Bug fixes happen on `hotfix/ssl-cert`
- Main stays stable and deployable at all times
- Changes are reviewed and tested before merging

In infrastructure terms: branching is the Git equivalent of a change freeze on production. You work in a controlled isolated environment and only promote to production when ready.

### Q3: What is `HEAD` in Git?

`HEAD` is a pointer to the currently checked-out commit. In most cases it points to the tip of the current branch. When I switch branches with `git switch main`, `HEAD` moves to point to `main`.

`HEAD` is how Git knows "what is the current state of my working directory." When I make a new commit, it becomes the new tip of the current branch — and `HEAD` moves to point to it.

`HEAD~1` means one commit behind HEAD. `HEAD~3` means three commits behind. Used in `git reset HEAD~1` or `git rebase -i HEAD~3`.

**Detached HEAD:** When you check out a specific commit hash instead of a branch name, HEAD points directly to that commit — not to any branch. New commits in this state are not on any branch and can be lost. Always switch to a named branch before committing.

### Q4: What happens to your files when you switch branches?

Git swaps the working directory files to match the state of the branch being switched to.

When I switch from `feature-1` to `main`:
1. Git reads the commit that `main` points to
2. Updates every tracked file in the working directory to match that commit
3. Moves `HEAD` to point to `main`

Files that exist only in `feature-1` disappear from the working directory. Files that were modified in `feature-1` revert to their `main` state. This is why uncommitted changes must be committed or stashed before switching branches — Git will warn or refuse if uncommitted changes conflict with the switch.

---

## Task 2 — Branching Commands

```bash
# 1. List all branches
git branch        # local only
git branch -a     # local + remote tracking

# 2. Create feature-1
git branch feature-1

# 3. Switch to feature-1
git switch feature-1

# 4. Create and switch in one command
git switch -c feature-2

# 5. git switch vs git checkout
# git switch  — branch switching only — clear purpose, modern
# git checkout — does many things: switch branch, restore files, detach HEAD
# git switch is the modern replacement — use it for branches
# git restore is the modern replacement — use it for file restoration

# 6. Make a commit on feature-1 that doesn't exist on main
git switch feature-1
echo "This only exists on feature-1" >> feature-notes.txt
git add feature-notes.txt
git commit -m "feature-1: add feature-only notes"

# 7. Switch back to main — verify commit is not there
git switch main
cat feature-notes.txt   # file not found — or shows older content
git log --oneline       # feature-1 commit is not here

# 8. Delete a branch
git branch -d feature-2        # safe delete — fails if unmerged
git branch -D feature-2        # force delete — use when sure
```

---

## Task 3 — Push to GitHub

```bash
# Connect local repo to GitHub remote
git remote add origin git@github.com:ameertechy/devops-git-practice.git
git remote -v   # verify

# Push main branch — -u sets upstream tracking
git push -u origin main

# Push feature-1 branch
git push -u origin feature-1

# After -u is set, subsequent pushes are just:
git push
```

### Q: What is the difference between `origin` and `upstream`?

**`origin`** — the default name for the remote I cloned from or connected to. It is my own remote — either my personal repo or my fork on GitHub. When I push, I push to `origin`.

**`upstream`** — a convention for the original source repo when I have forked someone else's repository.

Example: I fork `TrainWithShubham/90DaysOfDevOps` on GitHub.
- `origin` = `ameertechy/90DaysOfDevOps` (my fork)
- `upstream` = `TrainWithShubham/90DaysOfDevOps` (the original)

```bash
# Add upstream after forking
git remote add upstream https://github.com/TrainWithShubham/90DaysOfDevOps.git
git remote -v   # shows both origin and upstream
```

---

## Task 4 — Pull from GitHub

```bash
# Make a change directly on GitHub (web editor)
# Then pull it locally:

# Option 1 — fetch first, review, then merge
git fetch origin
git log origin/main --oneline   # see what came in
git merge origin/main           # apply it

# Option 2 — fetch and merge in one command
git pull origin main
```

### Q: What is the difference between `git fetch` and `git pull`?

**`git fetch`** downloads changes from the remote into remote tracking branches (`origin/main`) but does NOT modify my local branches or working directory. I can review what came in with `git diff main origin/main` before deciding to merge.

**`git pull`** = `git fetch` + `git merge`. Downloads AND applies the changes to the current branch immediately.

**Production habit:** Always `git fetch` first, review the diff, then `git merge` or `git rebase`. Avoid `git pull` on branches where unexpected changes could cause conflicts. Especially important in shared team repositories where others are committing actively.

---

## Task 5 — Clone vs Fork

```bash
# Clone — download a copy to work locally
git clone https://github.com/TrainWithShubham/90DaysOfDevOps.git

# Fork — GitHub concept: copy the repo to YOUR GitHub account
# Done via GitHub UI: Fork button on the repo page
# Then clone YOUR fork:
git clone git@github.com:ameertechy/90DaysOfDevOps.git
```

### Clone vs Fork

| Aspect | Clone | Fork |
|--------|-------|------|
| Where it lives | Local machine only | Your GitHub account + local |
| Push access | Only if you have permission on original | You own the fork — full access |
| Contributing back | Need write access to original | Raise a PR from your fork |
| Use case | Your own repo, or team repos you have access to | Contributing to open-source or external repos |

**Clone** = local copy of a repo. Used when I have push access or just want to read/build.

**Fork** = my own copy on GitHub. Used when I want to contribute to someone else's project without needing their permission. I push to my fork, raise a Pull Request, they review and merge.

### Keeping Your Fork in Sync

```bash
# Add original repo as upstream
git remote add upstream git@github.com:TrainWithShubham/90DaysOfDevOps.git

# Fetch latest from original
git fetch upstream

# Merge upstream main into my local main
git switch main
git merge upstream/main

# Push synced main to my fork
git push origin main
```

---

*#90DaysOfDevOps 2026*
