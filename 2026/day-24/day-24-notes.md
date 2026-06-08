# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## 🚀 Overview
Today I practiced advanced Git workflows including merging strategies, rebasing, stashing, and cherry-picking. These concepts are critical for real-world DevOps collaboration and CI/CD workflows.

---

# 🧪 Task 1: Git Merge

## 🔹 Fast-forward merge
A fast-forward merge happens when the main branch has no new commits and Git simply moves the pointer forward.

## 🔹 Merge commit
A merge commit is created when both branches have independent commits.

## 🔹 Observations
- If main has no new commits → fast-forward merge
- If both branches diverge → merge commit is created

## 🔹 Merge conflict
A conflict occurs when the same file/line is modified in both branches.

### How to resolve:
- Manually edit file
- git add
- git commit

---

# 🧪 Task 2: Git Rebase

## 🔹 What rebase does
Rebase moves feature branch commits on top of the latest main branch.

## 🔹 Difference from merge
- Merge keeps history
- Rebase rewrites history (linear)

## 🔹 Warning
Never rebase commits that are already pushed/shared.

## 🔹 When to use
- Clean linear history → rebase
- Preserving history → merge

---

# 🧪 Task 3: Squash vs Merge

## 🔹 Squash merge
Combines multiple commits into a single commit.

## 🔹 Observations
- Only 1 commit appears in main after squash
- Feature branch commits are not individually visible in main

## 🔹 Regular merge
- Keeps full commit history
- Adds merge commit

## 🔹 Trade-off
- Squash → clean history but loses detail
- Merge → full history but more clutter

---

# 🧪 Task 4: Git Stash

## 🔹 What stash does
Temporarily saves uncommitted work.

## 🔹 pop vs apply
- pop → applies + removes stash
- apply → applies but keeps stash

## 🔹 Real use cases
- Switching branches quickly
- Emergency hotfixes
- Saving incomplete work

---

# 🧪 Task 5: Cherry Pick

## 🔹 What it does
Applies a specific commit from another branch into current branch.

## 🔹 Use cases
- Hotfix deployment
- Selectively applying commits
- Backporting fixes

## 🔹 Risks
- Merge conflicts
- Duplicate commits later
- History inconsistency

---

# 🎯 Key Learnings

- Git merge = combine branches
- Rebase = rewrite history
- Squash = clean commit history
- Stash = temporary save
- Cherry-pick = select specific commit