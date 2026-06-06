# Git Commands Reference
*#90DaysOfDevOps 2026 | Updated daily from Day 22*

---

## Setup and Configuration

| Command | What It Does |
|---------|-------------|
| `git --version` | Check Git version installed |
| `git config --global user.name "Name"` | Set your identity — name |
| `git config --global user.email "email"` | Set your identity — email |
| `git config --global core.editor "vim"` | Set default editor for commit messages |
| `git config --list` | View all current configuration |
| `git config user.name` | View a specific config value |

```bash
# Set identity — required before first commit
git config --global user.name "Ameerul Mujahidin"
git config --global user.email "ameerulmujahidin96@gmail.com"

# Verify
git config --list | grep user
```

---

## Creating and Initializing

| Command | What It Does |
|---------|-------------|
| `git init` | Initialize a new Git repo in current directory |
| `git init <folder>` | Initialize a new repo in a new folder |
| `git clone <url>` | Clone a remote repository locally |
| `git clone <url> <folder>` | Clone into a specific folder name |

```bash
# Initialize
mkdir devops-git-practice && cd devops-git-practice
git init
# Creates .git/ directory — the entire Git database

# Clone via HTTPS
git clone https://github.com/ameertechy/90DaysOfDevOps.git

# Clone via SSH (after SSH key setup)
git clone git@github.com:ameertechy/90DaysOfDevOps.git
```

---

## The Three Areas

```
Working Directory  →  git add  →  Staging Area  →  git commit  →  Repository
     (edit)                         (stage)                         (history)
```

| Command | What It Does |
|---------|-------------|
| `git status` | Show state of working directory and staging area |
| `git add <file>` | Stage a specific file |
| `git add .` | Stage ALL changes in current directory |
| `git add -p` | Interactively stage chunks (partial staging) |
| `git restore --staged <file>` | Unstage a file (keep changes in working dir) |
| `git restore <file>` | Discard changes in working directory |
| `git commit -m "message"` | Commit staged changes with a message |
| `git commit --amend` | Modify the most recent commit |

```bash
# Standard workflow
git status              # see what changed
git add file.txt        # stage one file
git add .               # stage everything
git status              # confirm what is staged
git commit -m "Add nginx config for production"

# Amend last commit message (before pushing)
git commit --amend -m "Better message"
```

---

## Viewing History and Changes

| Command | What It Does |
|---------|-------------|
| `git log` | Full commit history |
| `git log --oneline` | Compact one-line per commit |
| `git log --oneline --graph` | Visual branch graph |
| `git log --oneline --graph --all` | All branches in graph |
| `git log -n 5` | Last 5 commits only |
| `git log --author="Ameerul"` | Commits by specific author |
| `git diff` | Changes not yet staged |
| `git diff --staged` | Changes staged but not committed |
| `git diff HEAD` | All changes since last commit |
| `git show <commit>` | Show changes in a specific commit |

```bash
# Most useful log format
git log --oneline --graph --all

# See what changed in a file
git diff git-commands.md

# See what is staged
git diff --staged
```

---

## Branching

| Command | What It Does |
|---------|-------------|
| `git branch` | List local branches |
| `git branch -a` | List all branches including remote |
| `git branch <name>` | Create a new branch |
| `git switch <name>` | Switch to a branch |
| `git switch -c <name>` | Create and switch in one command |
| `git branch -d <name>` | Delete a merged branch |
| `git branch -D <name>` | Force delete (even if unmerged) |
| `git branch -m <old> <new>` | Rename a branch |

```bash
# Create and switch to a feature branch
git switch -c feature/nginx-config

# Work, commit, then switch back
git add .
git commit -m "Add nginx virtual host config"
git switch main

# Delete after merging
git branch -d feature/nginx-config
```

---

## Merging

| Command | What It Does |
|---------|-------------|
| `git merge <branch>` | Merge branch into current branch |
| `git merge --no-ff <branch>` | Merge with a merge commit always |
| `git merge --squash <branch>` | Squash all branch commits into one staged change |
| `git merge --abort` | Abort a merge in progress |

```bash
# Merge feature branch into main
git switch main
git merge feature/nginx-config

# Squash merge — condense all feature commits into one
git switch main
git merge --squash feature/nginx-config
git commit -m "Add complete nginx configuration"
# All feature commits become one clean commit on main
```

**Merge vs Squash:**
- `merge` — all commits from branch appear in main's history
- `--squash` — all commits collapsed into one staged change, you write one clean commit message

---

## Rebase

| Command | What It Does |
|---------|-------------|
| `git rebase <branch>` | Rebase current branch onto another |
| `git rebase -i HEAD~N` | Interactive rebase — last N commits |
| `git rebase --continue` | Continue after resolving conflict |
| `git rebase --abort` | Abort rebase and return to original state |

```bash
# Rebase feature branch onto latest main
git switch feature/nginx-config
git rebase main
# Replays feature commits on top of latest main — linear history

# Interactive rebase — squash last 3 commits
git rebase -i HEAD~3
# Opens editor — change 'pick' to 'squash' on commits to combine
```

**When to rebase vs merge:**
- Local feature branch before PR → rebase onto main to stay current
- Shared branch (others have pulled) → never rebase — use merge
- Cleaning up messy local commits → interactive rebase

---

## Stash

| Command | What It Does |
|---------|-------------|
| `git stash` | Save current changes and clean working directory |
| `git stash push -m "message"` | Stash with a description |
| `git stash list` | List all stashes |
| `git stash pop` | Apply most recent stash and remove it |
| `git stash apply stash@{N}` | Apply specific stash, keep it in list |
| `git stash drop stash@{N}` | Delete a specific stash |
| `git stash clear` | Delete all stashes |

```bash
# Scenario: mid-feature work, urgent production fix needed
git stash push -m "WIP: nginx config changes"
git switch main
# fix production issue, commit, push
git switch feature/nginx-config
git stash pop   # restore your work
```

---

## Cherry-Pick

| Command | What It Does |
|---------|-------------|
| `git cherry-pick <hash>` | Apply a specific commit to current branch |
| `git cherry-pick <hash1> <hash2>` | Apply multiple specific commits |
| `git cherry-pick --abort` | Abort cherry-pick in progress |

```bash
# Apply a specific hotfix commit from another branch
git log --oneline feature/hotfix   # find the commit hash
git switch main
git cherry-pick a1b2c3d            # apply just that commit

# Use case: a bug fix in a development branch needs to go to production now
# without merging all the unfinished development work
```

---

## Reset and Revert

| Command | What It Does |
|---------|-------------|
| `git reset --soft HEAD~1` | Undo last commit — keep changes staged |
| `git reset --mixed HEAD~1` | Undo last commit — keep changes unstaged (default) |
| `git reset --hard HEAD~1` | Undo last commit — discard all changes |
| `git revert <hash>` | Create new commit that undoes a previous commit |
| `git revert HEAD` | Revert the most recent commit |

```bash
# Soft reset — undo commit, keep changes ready to recommit
git reset --soft HEAD~1

# Hard reset — completely undo last commit and discard changes
git reset --hard HEAD~1
# WARNING: changes are gone — cannot recover

# Revert — safe for pushed commits
git revert a1b2c3d
# Creates a new commit: "Revert: Add nginx config"
# Original commit stays in history
```

**Rule: reset for local only, revert for shared/pushed:**
- `reset` rewrites history — breaks others who pulled the original commit
- `revert` adds to history — safe for shared branches

---

## Remote and GitHub

| Command | What It Does |
|---------|-------------|
| `git remote -v` | List remote connections |
| `git remote add origin <url>` | Add a remote named origin |
| `git remote set-url origin <url>` | Change remote URL |
| `git push origin <branch>` | Push branch to remote |
| `git push -u origin <branch>` | Push and set upstream tracking |
| `git push --force-with-lease` | Force push safely (checks for others' changes) |
| `git fetch origin` | Download changes without merging |
| `git pull origin <branch>` | Fetch and merge remote branch |
| `git pull --rebase origin main` | Fetch and rebase instead of merge |

```bash
# First time push — set upstream
git push -u origin main

# After that — just
git push
git pull

# Safe force push (after rebase)
git push --force-with-lease origin feature/my-branch
```

---

## GitHub Authentication on EC2

### HTTPS with PAT Token

```bash
# Clone with HTTPS
git clone https://github.com/ameertechy/90DaysOfDevOps.git

# On first push, enter:
# Username: ameertechy
# Password: <your PAT token — not your GitHub password>

# Cache credentials so you don't enter every time
git config --global credential.helper store
# After next push (enter credentials once), they are saved to ~/.git-credentials
```

**PAT = Personal Access Token.** GitHub removed password authentication for git operations. PAT is generated at GitHub → Settings → Developer settings → Personal access tokens. Scope: `repo` for full repository access.

### SSH Key Authentication (Production Standard)

```bash
# Step 1 — Generate SSH key pair on EC2
ssh-keygen -t ed25519 -C "ameerulmujahidin96@gmail.com"
# Accept default path: ~/.ssh/id_ed25519
# Optionally set a passphrase

# Step 2 — View the public key
cat ~/.ssh/id_ed25519.pub
# Starts with: ssh-ed25519 AAAA...

# Step 3 — Add public key to GitHub
# GitHub → Settings → SSH and GPG keys → New SSH key
# Paste the public key content

# Step 4 — Test the connection
ssh -T git@github.com
# Expected: Hi ameertechy! You've successfully authenticated...

# Step 5 — Clone using SSH
git clone git@github.com:ameertechy/90DaysOfDevOps.git

# Step 6 — Change existing repo from HTTPS to SSH
git remote set-url origin git@github.com:ameertechy/90DaysOfDevOps.git
git remote -v   # verify
```

**`ssh-keygen -t ed25519`:**
- `-t ed25519` = key type. Ed25519 is the modern standard — faster and more secure than RSA.
- `-C "email"` = comment — labels the key so you know which account it belongs to.
- Generates two files: `~/.ssh/id_ed25519` (private — never share) and `~/.ssh/id_ed25519.pub` (public — add to GitHub).

---

## Squash Commits (Interactive Rebase)

```bash
# You have 4 messy commits, want to clean to 1
git log --oneline
# a1b2c3d Fix typo again
# e4f5g6h Fix typo
# i7j8k9l Add feature draft
# m1n2o3p Start feature

git rebase -i HEAD~4
```

Editor opens:
```
pick m1n2o3p Start feature
pick i7j8k9l Add feature draft
pick e4f5g6h Fix typo
pick a1b2c3d Fix typo again
```

Change to:
```
pick m1n2o3p Start feature
squash i7j8k9l Add feature draft
squash e4f5g6h Fix typo
squash a1b2c3d Fix typo again
```

Save and close. Another editor opens for the combined commit message. Write one clean message. Result: one commit instead of four.

---

*#90DaysOfDevOps 2026 | Updated: Day 22*
