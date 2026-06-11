# Day 27 – GitHub Profile Makeover: Building My Developer Identity

## Overview

Day 27 is different — no new tool, no new commands to memorize. Today is a **branding day**, and honestly it might matter more than half the technical days. The point is blunt: a GitHub profile is a developer resume. Recruiters and hiring managers open it before they ever read a CV — and after 26 days of daily commits, mine still looked like a storage room nobody visits.

Coming from 7 years in IT support, this lesson landed differently for me. In support, the work only "counts" if it's documented — the ticket closed, the runbook updated. A GitHub profile is the exact same principle, just public: it's the proof-of-work for everything I'm learning in this transition. If the evidence is messy, the effort is invisible.

So today I audited my profile like a stranger would, built a profile README, organized my repos with proper names and descriptions, pinned the ones that tell my story, and cleaned out everything that didn't.

---

## What I Produced

- [`day-27-notes.md`](./day-27-notes.md) — full audit, changes made, and before/after screenshots
- A **profile README** at [`github.com/ameertechy`](https://github.com/ameertechy) (the special `ameertechy/ameertechy` repo)
- Organized repos — clear names, one-line descriptions, READMEs, `.gitignore` files
- Before/after screenshots in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Audited my own profile as if I were a recruiter — wrote down the honest answers |
| 2 | Created the special `ameertechy/ameertechy` repo with a profile README that tells my story |
| 3 | Organized my repos — descriptive hyphenated names, one-line descriptions, proper READMEs |
| 4 | Pinned the 6 repos that best represent the journey so far |
| 5 | Archived dead repos, renamed unclear ones, checked history for exposed secrets |
| 6 | Captured before/after screenshots and wrote down the 3 biggest improvements |

---

## Key Observations

**The username-repo trick is the highest-leverage 10 minutes on GitHub.**
A repo named exactly after your username (`ameertechy/ameertechy`) gets its README rendered at the top of your profile page. It's the front door of your developer identity — and before today, mine was blank wall.

**Pinned repos are a shop window, not a junk drawer.**
By default GitHub shows whatever it feels like — random forks, empty experiments. Choosing 6 pins deliberately changes the first impression from "abandoned account" to "this person is actively building something."

**A repo without a description reads as a repo without a purpose.**
One line. That's all it takes for a stranger to know what they're looking at. I went through every repo and asked: would a recruiter understand this in 5 seconds? If not, I fixed the name, the description, or both.

**Secrets in commit history don't disappear when you delete the file.**
The cleanup task drilled this in: removing a `.env` from the latest commit does nothing — it's still in history for anyone to dig out. Checking the history (`git log -p`, secret scanners) is the real audit. Prevention (`.gitignore` from day one) beats cleanup every time.

---

## Real-World Tie-in

- **It's the same discipline as support documentation** — a runbook nobody can find or read may as well not exist. Same with code: an undocumented repo is invisible work.
- **Career-transition evidence** — for someone moving from support/sysadmin into DevOps, the profile *is* the portfolio. Certificates say "studied"; a green contribution graph with organized repos says "does".
- **Secret hygiene is a production skill** — leaked credentials in git history is a real incident category I've seen from the support side. Learning to audit for it now, on my own repos, is practice for doing it where it actually hurts.
- **University infrastructure angle** — the same makeover logic applies to internal repos at work: clear names, one-line purposes, READMEs. Onboarding the next engineer starts with how the repos look.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#GitHub` `#PersonalBranding` `#DevOps`
