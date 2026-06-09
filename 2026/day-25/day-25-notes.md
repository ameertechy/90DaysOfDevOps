# Day 25 – Git Reset vs Revert and Branching Strategies
*#90DaysOfDevOps 2026*

---

## Task 1 — Git Reset

### Setup

```bash
cd ~/devops-git-practice

# Create 3 commits
echo "Commit A content" > reset-test.txt
git add . && git commit -m "commit A"

echo "Commit B content" >> reset-test.txt
git add . && git commit -m "commit B"

echo "Commit C content" >> reset-test.txt
git add . && git commit -m "commit C"

git log --oneline
# a1b2c3d commit C
# e4f5g6h commit B
# i7j8k9l commit A
```

---

### `git reset --soft HEAD~1`

```bash
git reset --soft HEAD~1
```

**What happened:**
- Commit C is gone from `git log`
- `git status` shows: `Changes to be committed` — the content from commit C is staged
- `reset-test.txt` still has all content including "Commit C content"

**State after:**
```
Working directory: unchanged (has commit C content)
Staging area:      commit C changes are staged
Repository:        HEAD moved back to commit B
```

```bash
# Re-commit to restore
git commit -m "commit C restored"
```

---

### `git reset --mixed HEAD~1` (default behaviour)

```bash
git reset --mixed HEAD~1
# or just: git reset HEAD~1
```

**What happened:**
- Commit C is gone from `git log`
- `git status` shows: `Changes not staged for commit` — unstaged
- `reset-test.txt` still has all content but nothing is staged

**State after:**
```
Working directory: unchanged (has commit C content)
Staging area:      empty — changes unstaged
Repository:        HEAD moved back to commit B
```

```bash
# Restore — must stage again
git add . && git commit -m "commit C restored"
```

---

### `git reset --hard HEAD~1`

```bash
git reset --hard HEAD~1
```

**What happened:**
- Commit C is gone from `git log`
- `git status` shows nothing — working directory is clean
- `cat reset-test.txt` — "Commit C content" line is GONE

**State after:**
```
Working directory: reverted to commit B state — C changes deleted
Staging area:      empty
Repository:        HEAD moved back to commit B
```

**This is destructive.** The only recovery is `git reflog`.

```bash
# Recovery after hard reset
git reflog
# a1b2c3d HEAD@{0}: reset: moving to HEAD~1
# b2c3d4e HEAD@{1}: commit: commit C restored

git reset --hard b2c3d4e   # hash of the lost commit
git log --oneline           # commit C is back
```

---

### Answers

**Difference between `--soft`, `--mixed`, and `--hard`:**

| Flag | Repository | Staging Area | Working Directory |
|------|-----------|--------------|-------------------|
| `--soft` | HEAD moves back | Changes stay staged | Unchanged |
| `--mixed` | HEAD moves back | Changes unstaged | Unchanged |
| `--hard` | HEAD moves back | Cleared | **Reverted — changes deleted** |

**Which is destructive and why?**
`--hard` is the only destructive one. It deletes changes from the working directory — they are not in the staging area, not in any commit. Without `git reflog`, they are unrecoverable.

**When to use each:**

| Situation | Use |
|-----------|-----|
| Commit message was wrong, keep changes ready | `--soft` |
| Want to re-stage selectively before recommitting | `--mixed` |
| Commit was completely wrong, discard everything | `--hard` |
| Undo staged changes without losing work | `--mixed HEAD` |

**Should you use `git reset` on pushed commits?**
No. Never. `reset` rewrites history. If you push after resetting, the remote has commits your local does not. Others who pulled now have a diverged history. `git push --force` would overwrite their work. Use `git revert` instead — it undoes without rewriting.

---

## Task 2 — Git Revert

```bash
# Setup: 3 new commits
echo "Commit X" > revert-test.txt
git add . && git commit -m "commit X"

echo "Commit Y — this one has a bug" >> revert-test.txt
git add . && git commit -m "commit Y"

echo "Commit Z" >> revert-test.txt
git add . && git commit -m "commit Z"

git log --oneline
# c3d4e5f commit Z
# b2c3d4e commit Y
# a1b2c3d commit X
```

```bash
# Revert commit Y — the middle one
git revert b2c3d4e --no-edit
# --no-edit skips the commit message editor, uses the default
```

**What happened:**
- A new commit was added: `Revert "commit Y"`
- `git log --oneline`:
  ```
  f4g5h6i Revert "commit Y"
  c3d4e5f commit Z
  b2c3d4e commit Y     ← still here — not removed
  a1b2c3d commit X
  ```
- Commit Y is still in the history — it was not removed
- The revert commit undoes the changes Y introduced

**Why reverting the middle commit is safe:**
Git calculates the diff of commit Y and applies the inverse. The file goes back to what it was before Y — but commit Z is preserved because its changes are separate.

**What if there is a conflict?**
If commit Y's changes conflict with commit Z (e.g. both edited the same line), `git revert` will pause with a conflict. Resolve it the same way as a merge conflict, then `git revert --continue`.

---

### Answers

**How is `git revert` different from `git reset`?**
`reset` removes commits from history — it moves HEAD backwards. `revert` adds a new commit that undoes a previous one — history is preserved and grows forward.

**Why is revert safer for shared branches?**
History is never rewritten. Every team member who pulls gets the revert commit — they see exactly what happened and when. No diverged histories, no force push needed, no broken pipelines.

**When to use revert vs reset?**

| Situation | Use |
|-----------|-----|
| Bad commit on main that was pushed | `revert` |
| Local commit not yet pushed | `reset` (any mode) |
| Need a record that something was undone | `revert` |
| Want to cleanly undo without trace | `reset --hard` (local only) |

---

## Task 3 — Reset vs Revert Comparison

| | `git reset` | `git revert` |
|---|---|---|
| What it does | Moves HEAD backwards — removes commits from history | Creates a new commit that undoes a previous one |
| Removes commit from history? | Yes — commit disappears | No — revert commit is added, original stays |
| Modifies existing commits? | Yes | No |
| Safe for shared/pushed branches? | No — rewrites history | Yes — preserves history |
| When to use | Local cleanup before pushing | Undoing pushed commits safely |
| Recovery if wrong | `git reflog` (within 90 days) | Another `git revert` |
| Team impact | Breaks others' history if pushed | Zero impact — they just pull the revert |

---

## Task 4 — Branching Strategies

---

### 1. GitFlow

**How it works:**
Two permanent branches — `main` (production) and `develop` (integration). Features branch from `develop`. When a release is ready, a `release` branch is cut from `develop`, tested, then merged to both `main` and `develop`. Hotfixes branch from `main` and merge back to both.

**Text diagram:**
```
main:     ──●──────────────────────●── (production releases)
              \                   /|
release:       ●──●──●───────────● |  (stabilization)
                    \            / |
develop:  ──●──●──●──●──●──●──●── |  (integration)
                \       \         |
feature:         ●──●──●─/         |
                                    |
hotfix:                             ●──● (emergency fix)
```

**Where it is used:** Large teams, enterprise software, apps with formal release cycles and QA gates.

**Pros:**
- Clear separation of stable and in-development code
- Structured process for releases and hotfixes
- Good for teams with multiple versions in production

**Cons:**
- Complex — many branch types to manage
- Slow for teams that deploy frequently
- Merging back to both `main` and `develop` creates overhead

---

### 2. GitHub Flow

**How it works:**
One permanent branch — `main`. All work happens on short-lived feature branches. When a feature is ready, a Pull Request is opened, reviewed, and merged directly to `main`. `main` is always deployable.

**Text diagram:**
```
main:     ──●──────────────────●──────────────────●──
              \               / \                /
feature-a:     ●──●──●──●──●/   feature-b: ●──●/
               (PR → review → merge)
```

**Where it is used:** Startups, teams with CI/CD pipelines that deploy on every merge, open-source projects, GitHub's own internal workflow.

**Pros:**
- Simple — one rule: main is always deployable
- Fast iteration — short feedback loops
- Easy to understand for new team members

**Cons:**
- Requires strong CI/CD and automated testing gates
- No built-in support for multiple release versions
- Can be chaotic without PR review discipline

---

### 3. Trunk-Based Development

**How it works:**
Everyone commits to `main` (the trunk) directly or via very short-lived branches (max 1-2 days). Feature flags hide incomplete features in production. The focus is on keeping integration continuous — no long-lived branches that diverge from main.

**Text diagram:**
```
main (trunk): ──●──●──●──●──●──●──●──●──●──●──
                    \   /  \  /
feature:      (max 1-2 day branches, merged immediately)
```

**Where it is used:** High-frequency deployment teams (Google, Facebook, Netflix), teams with extensive automated test coverage, teams practicing continuous deployment.

**Pros:**
- Eliminates merge hell — no long-lived branches to integrate
- Forces continuous integration discipline
- Fastest path from code to production

**Cons:**
- Requires mature CI/CD and test coverage
- Feature flags add complexity to the codebase
- Not suitable for teams without automated quality gates

---

### Answers

**Which strategy for a startup shipping fast?**
GitHub Flow. Simple, fast, one permanent branch. Every merged PR goes to production. Requires a solid CI/CD pipeline but no complex branching ceremony.

**Which strategy for a large team with scheduled releases?**
GitFlow. The structured release branch gives time for stabilization and testing before production. The develop branch provides an integration point for parallel feature work. Hotfixes can ship without waiting for the release cycle.

**Which does the Kubernetes project use?**
Kubernetes uses a variant of GitFlow — `main` for active development, `release-1.x` branches for each version, cherry-picks for backporting fixes to older releases. Large open-source projects with multiple supported versions typically follow this pattern.

---

## Task 5 — Updated `git-commands.md` Sections to Add

Add these to your existing `git-commands.md`:

```markdown
## Reset and Revert

| Command | What It Does |
|---------|-------------|
| `git reset --soft HEAD~N` | Undo N commits — keep changes staged |
| `git reset --mixed HEAD~N` | Undo N commits — keep changes unstaged (default) |
| `git reset --hard HEAD~N` | Undo N commits — DELETE changes |
| `git reset HEAD~1` | Same as --mixed (default mode) |
| `git revert <hash>` | Create new commit that undoes a specific commit |
| `git revert HEAD` | Revert the most recent commit |
| `git revert HEAD --no-edit` | Revert without opening message editor |
| `git revert --continue` | Continue after resolving revert conflict |
| `git reflog` | Show all HEAD movements — safety net for recovery |

## Branching Strategies Summary

| Strategy | Branches | Cadence | Best For |
|----------|---------|---------|---------|
| GitFlow | main, develop, feature, release, hotfix | Scheduled releases | Enterprise, regulated environments |
| GitHub Flow | main + short feature branches | Continuous deployment | Startups, CI/CD teams |
| Trunk-Based | main (trunk) only | Multiple daily deploys | Mature engineering orgs with automation |
```

---

*#90DaysOfDevOps 2026*
