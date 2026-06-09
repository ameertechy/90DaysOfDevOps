# Day 25 – Git Reset vs Revert and Branching Strategies

## Overview

Day 25 covers two things that every engineer working in a team environment must understand cold: how to undo mistakes safely, and how teams structure their branching workflow to ship code without stepping on each other.

Reset and revert are both "undo" tools — but they operate at different levels of safety and have completely different implications for shared branches. Getting this wrong in a team environment causes real damage.

Branching strategies are the policies that determine how code moves from a developer's machine to production. Choosing the wrong one for your team's pace creates friction — too rigid for a fast-moving team, too loose for a regulated environment.

---

## What I Produced

- [`day-25-notes.md`](./day-25-notes.md)
- Updated `git-commands.md`

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Ran all three reset modes — observed staging area and working dir after each |
| 2 | Reverted the middle commit — observed it stays in history as a revert commit |
| 3 | Built reset vs revert comparison table |
| 4 | Documented GitFlow, GitHub Flow, Trunk-Based Development with diagrams |
| 5 | Updated `git-commands.md` with Days 22–25 coverage |

---

## Key Observations

**`--soft` keeps everything staged — it is the safest reset.**
The commit is undone but all changes stay staged and ready to recommit. Use it when the commit was premature — content is right, timing or message was wrong.

**`--hard` is the only destructive one — and `git reflog` is the only recovery.**
After `git reset --hard HEAD~1`, the commit is gone from history and the changes are gone from the working directory. The only way back is `git reflog` to find the commit hash and `git reset --hard <hash>` to restore it. This works only within 90 days of the original operation.

**GitFlow is structured — GitHub Flow is simple — Trunk-Based is fast.**
The right branching strategy is determined by release cadence, team size, and compliance requirements. A university IT team shipping infrastructure automation daily would use GitHub Flow. A regulated financial platform with quarterly releases would use GitFlow. A startup with multiple daily deploys would use Trunk-Based Development.

---

## Real-World Tie-in

- `git revert` is the production-safe undo — used when a bad commit needs to be undone on `main` without rewriting history that the team has already pulled
- GitFlow maps directly to how I manage university infrastructure changes — `develop` = staging, `release` = change approval, `main` = production, `hotfix` = emergency change
- Trunk-based development is what CI/CD pipelines are designed around — short-lived branches, frequent integration, automated testing gates

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Git` `#GitHub` `#DevOps`
