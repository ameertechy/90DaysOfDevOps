# Day 39 – What is CI/CD?

## Overview

Day 39 is a deliberate concepts day — no pipelines yet. After a week of Docker and a day of YAML, this is the bridge into automation: understand **why CI/CD exists** and what it actually does before writing a single workflow (that's Day 40).

I worked through the problem CI/CD solves (5 developers manually deploying to prod is a recipe for trouble), nailed down the three terms everyone blurs together — **Continuous Integration vs Delivery vs Deployment** — broke a pipeline down into its parts (trigger, stage, job, step, runner, artifact), drew a 3-stage pipeline, and then went and read a real workflow file in the wild.

The thing that made it click: a pipeline is just **YAML** (yesterday's lesson) describing **triggers, jobs, and steps** (today's vocabulary). The concepts aren't abstract — they're the exact keys I'll type into a workflow file tomorrow.

---

## What I Produced

- [`day-39-cicd-concepts.md`](./day-39-cicd-concepts.md) — my notes: CI vs CD vs CD with real examples, the pipeline anatomy table, a text pipeline diagram, and what I found reading a real repo's workflow
- A 3-stage pipeline diagram (test → build → deploy)
- A real-world reading of an open-source CI workflow in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Listed what goes wrong with manual deploys and what "works on my machine" really means |
| 2 | Wrote short definitions of **CI, Continuous Delivery, Continuous Deployment** with an example each |
| 3 | Defined each part of a pipeline — trigger, stage, job, step, runner, artifact |
| 4 | Drew a 3-stage pipeline: push → **test → build → deploy** to staging |
| 5 | Opened **Vite's** `.github/workflows/` and worked out its triggers, jobs, and purpose |

---

## Key Observations

**"It works on my machine" is an environment problem, not a code problem.**
The code didn't change between the laptop and the server — the environment did. Naming it that way made it obvious why containers came first in this challenge, and why a pipeline that builds in a clean, identical environment every time matters.

**The CI / Delivery / Deployment distinction is about *where the automation stops*.**
CI = integrate and test automatically. Delivery = every passing change is *ready* to ship, but a human presses the button. Deployment = it ships automatically. Same pipeline, the difference is just whether there's a human gate at the end.

**A failing pipeline is the system working.**
It caught a problem before it reached anyone — that's the point, not something to fear. This reframed "red build" from bad news to cheap, early feedback.

**The anatomy is the syntax.**
Trigger, job, step, runner aren't theory — they're the literal keys (`on:`, `jobs:`, `steps:`, `runs-on:`) I'll be writing tomorrow. Day 39 is just learning the vocabulary for Day 40.

---

## Real-World Tie-in

- **Manual change is risky change.** Running an on-prem datacenter taught me that the steps a human does by hand at 2 a.m. are exactly the ones that get skipped or fat-fingered. CI/CD is that lesson turned into automation — the pipeline does the steps the same way every time, with a record of who triggered what.
- **A pipeline is a runbook that runs itself.** I've written plenty of "do these steps in this order" procedures; a pipeline is that, except it can't forget a step and it tests itself.
- **Early feedback beats late firefighting.** Catching a broken build in minutes is far cheaper than discovering it after it's deployed — the same instinct as monitoring a server before it falls over, not after.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#CICD` `#GitHubActions` `#DevOps`
