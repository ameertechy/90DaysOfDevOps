# Day 28 – Revision Day: Everything From Day 1 to Day 27

## Overview

Day 28 has no new tool, no new commands — and it might be the most honest day of the challenge so far. Today's job was to **stop and grade myself** on everything from Days 1–27: Linux, shell scripting, networking, Git & GitHub, and the profile work. Not "did I do the tasks" — but *can I actually do this without looking it up*.

Here's the honest twist. I have 7 years in IT support — but most of that was on the Windows side. Linux only entered my daily life about 3 years ago, and lightly. So I expected the Linux column to scare me today. It didn't — and that's not my 7 years talking, it's the last 28 days of daily reps. What *did* earn honest "need to revisit" marks: shell scripting beyond the basics and some of the newer Git concepts. That's fine. The whole point of revision is finding the gaps *before* a production incident or an interview finds them for me.

So today: full self-assessment checklist, three weak spots re-drilled hands-on, ten quick-fire questions answered from memory, repo housekeeping verified, and one topic taught back in plain words.

---

## What I Produced

- [`day-28-notes.md`](./day-28-notes.md) — the full self-assessment, weak-spot rework, quick-fire answers, and my teach-it-back
- A clean, fully-pushed repo — Days 1–27 all committed, `git-commands.md` and the shell cheat sheet up to date

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Went through the full checklist — marked every item honestly: confident / revisit / not yet |
| 2 | Picked my 3 weakest topics (LVM, awk & sed, git rebase) and redid the hands-on for each |
| 3 | Answered all 10 quick-fire questions from memory first, then verified — scored 7/10 cold |
| 4 | Verified all daily submissions are pushed, references up to date, profile clean from Day 27 |
| 5 | Taught back file permissions — explained `chmod`/`chown` the way I'd explain it to a new support hire |

---

## Key Observations

**The Linux column held up — but the credit goes to the challenge, not my 7 years.**
Most of my support life was Windows; Linux only showed up for me ~3 years ago, and lightly. What support actually gave me is the troubleshooting *instinct* — read the symptoms, check the resources, isolate the layer — and that transfers from any platform. But the Linux *commands* under those ticks (processes, systemd, permissions, `top`/`df`/`free`) stuck because of 28 days of daily reps, not 7 years of tickets. Experience gives you the method; only practice gives you the tools.

**"I did it once on Day X" is not the same as "I can do it".**
I completed the rebase task on Day 24. Could I explain rebase vs merge from memory a week later? Roughly — but not crisply. Redoing it today without notes is what actually moved it from "did it" to "know it".

**The quick-fire test exposed exactly what passive reading hides.**
7/10 from memory. The three I fumbled — the exact behaviour of `set -euo pipefail`, the `lsof -i :8080` form, and a clean LVM explanation — are now written at the top of my notes. A wrong answer you catch yourself is worth more than ten pages re-read.

**Teaching back is the real exam.**
Explaining file permissions in plain words — no jargon, to an imaginary new hire — forced me to actually decide what matters: who you are (owner/group/other), what you can do (rwx), and how to change it. If you can't say it simply, you don't own it yet.

---

## Real-World Tie-in

- **This is exactly how I'd run a skills audit at work** — the confident/revisit/not-yet triage is the same honest triage we did in support before taking on a new system: what can the team handle today, and what needs training before go-live.
- **Revision before escalation** — in support, you re-verify the basics before escalating a ticket. Day 28 is the same discipline applied to learning: verify the foundation before stacking Docker, Kubernetes, and CI/CD on top of it.
- **Interview readiness** — every quick-fire question today is a real interview question for a junior DevOps role. Finding my three weak answers in a self-test costs nothing; finding them in an interview costs the job.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#Git` `#DevOps`
