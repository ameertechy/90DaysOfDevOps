# Day 37 – Docker Revision & Cheat Sheet

## Overview

After eight straight days of Docker (Days 29–36), Day 37 is a deliberate pause — no new tool, no new project, just consolidation so all of it actually sticks. The job: mark myself honestly against a checklist, answer a set of quick-fire questions from memory and then verify them, build a one-page cheat sheet I'd genuinely reach for on the job, and redo the two topics I felt shaky on.

This is the kind of day my infra background already taught me to value — you don't really know a system until you can explain it without notes and rebuild it from a clean state. So I treated it like a self-run exam rather than a reading day: answer first, *then* check against what I actually did across the week.

The honest result: most of the muscle memory is there (run, build, volumes, networks, Compose, multi-stage, push to Hub). The two spots I marked **shaky** were **CMD vs ENTRYPOINT** and the **`restart` / healthcheck / `depends_on`** nuance — so those are the ones I redid hands-on.

---

## What I Produced

- [`docker-cheatsheet.md`](./docker-cheatsheet.md) — a categorized, one-line-per-command reference (containers, images, volumes, networks, Compose, cleanup, Dockerfile instructions)
- [`day-37-revision.md`](./day-37-revision.md) — my filled-in self-assessment checklist, all 8 quick-fire answers (from memory, then verified), and the two weak spots redone
- Screenshots of the revision and a few re-run commands in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Went through the **self-assessment checklist** honestly — marked each item *can do / shaky / haven't done* |
| 2 | Answered all **8 quick-fire questions from memory**, then verified each against my Day 29–36 notes |
| 3 | Built `docker-cheatsheet.md` — organized by category, one line per command |
| 4 | Picked my **2 shaky topics** (CMD vs ENTRYPOINT, restart/healthcheck/`depends_on`) and **redid the hands-on** for each |
| 5 | Wrote it all up in `day-37-revision.md` and committed |

---

## Key Observations

**Answering from memory first is what exposes the gaps.**
Reading my own notes back, everything looks obvious. But forcing the answer *before* checking is what surfaced the two I was fuzzy on. Recognition isn't recall — the checklist made that difference impossible to hide.

**CMD vs ENTRYPOINT finally clicked as "default vs fixed."**
The thing that stuck: extra args at `docker run` **replace** a `CMD`, but become **arguments to** an `ENTRYPOINT`. So `CMD` = a sensible default the user can swap out; `ENTRYPOINT` = the image *is* that command. The common combo (`ENTRYPOINT` sets the executable, `CMD` supplies overridable default args) is the bit I'd been hand-waving past.

**`restart: always` is not "always restart."**
This was my real blind spot from Day 34, so I re-tested it. `docker stop`/`docker kill` are treated as *intentional* stops — the policy stands down (RestartCount stays 0). It fires on **unexpected** exits: the process crashing on its own, an OOM kill, or a daemon/host reboot. To actually *see* self-healing you need a real crash (`sh -c "sleep 3; exit 1"`) or a reboot — not a manual stop.

**A cheat sheet you write yourself beats one you bookmark.**
Condensing a week into one line per command forced me to decide what I'd actually reach for under pressure. The act of trimming *is* the revision — the file is just the byproduct.

---

## Real-World Tie-in

- **Revision days are how knowledge survives contact with production.** In the datacenter I learned the hard way that a procedure you can't run from memory at 2 a.m. isn't a procedure you really have — the same logic applies to Docker commands during an incident.
- **The "answer first, verify after" loop is just self-troubleshooting.** It's the same discipline as forming a hypothesis before touching a misbehaving server, then proving it — not poking around hoping something works.
- **A personal cheat sheet is operational documentation.** One trustworthy page beats ten browser tabs of half-remembered Stack Overflow answers when you're mid-task.
- **Knowing the edge cases (like `restart: always` ignoring a manual stop) is what separates "I ran the command" from "I understand the behaviour"** — and that gap is exactly where production surprises live.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DevOps` `#Containers`
