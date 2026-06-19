# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Overview

Day 33 was Compose basics; Day 34 is Compose the way real apps actually use it. Today I built a **3-service stack — web app + database + cache (Redis)** — and added the things that separate a toy compose file from a production-like one: **healthchecks**, **`depends_on` with `condition: service_healthy`**, **restart policies**, **building from a Dockerfile**, and **explicit networks, volumes, and labels**.

This was the most "this is the real job" day so far. It also pulled together everything from the Docker week into one file: an image I build myself (Day 31), a volume so data survives (Day 32), a network for service-name communication (Day 32), and Compose to orchestrate it all (Day 33). The three-tier app I built for practice is basically this exercise — so today made that click even harder.

The highlight was the dependency ordering. Plain `depends_on` only waits for a container to *start*; my app would race ahead and fail because the database wasn't *ready* yet. Adding a healthcheck and `condition: service_healthy` fixed it properly — the app now waits until the DB can actually accept connections.

---

## What I Produced

- [`day-34-compose-advanced.md`](./day-34-compose-advanced.md) — the full stack, the app Dockerfile, and the answers to each task (restart policies, scaling, healthchecks)
- Screenshots of the 3-service stack running, the healthcheck wait, and the scaling experiment in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Built a **3-service stack**: a web app (with its own Dockerfile) + Postgres + Redis |
| 2 | Added a DB **healthcheck** and `depends_on: condition: service_healthy` — app waits for a *ready* DB |
| 3 | Tested **restart policies** — killed the DB with `restart: always` (came back) vs `on-failure` |
| 4 | Used `build:` to build the app from a Dockerfile; changed code and rebuilt with one command |
| 5 | Declared **explicit networks, named volumes, and labels** instead of relying on defaults |
| 6 | Tried **scaling** the web app to 3 replicas — saw exactly why port mapping breaks it |

---

## Key Observations

**`depends_on` alone waits for *started*, not *ready* — healthchecks fix that.**
This was the real lesson. Plain `depends_on` starts the DB first, but the container being "up" doesn't mean Postgres is accepting connections yet, so the app crashed on startup. A `healthcheck` plus `condition: service_healthy` made the app wait until the DB actually passed a `pg_isready` check. Started ≠ ready.

**Restart policies are how containers self-heal — but `docker kill` won't show it.**
A gotcha I tested: `restart: always` does **not** revive a container you stop with `docker kill`/`docker stop`, because Docker records that as an *intentional* stop. The policy fires on **unexpected** exits — the process crashing on its own, an OOM kill, or the host rebooting — which is exactly the resilience you want for a long-running database. `restart: on-failure` only restarts on a non-zero exit. Choosing the right policy is a real reliability decision, not a default to ignore.

**`build:` turns Compose into my build tool too.**
Pointing a service at a Dockerfile with `build:` means `docker compose up --build` rebuilds my image and restarts the stack in one command. The whole edit → rebuild → run loop collapses into a single line.

**Simple scaling breaks the moment you hard-map a port.**
Scaling the web app to 3 replicas failed because all three tried to bind the *same* host port. Only one can own a host port at a time. That's the lightbulb: real scaling needs a load balancer / reverse proxy in front, or an orchestrator that handles it — which is exactly the problem Kubernetes is built to solve.

---

## Real-World Tie-in

- **This is a production-shaped stack** — app + database + cache, with health-gated startup and self-healing restarts is the baseline pattern for real services, not a tutorial toy.
- **Healthcheck-gated dependencies prevent the classic startup race** — the "app started before the DB was ready" bug is one of the most common real deployment failures; solving it in Compose is a transferable skill.
- **The scaling wall is the reason orchestrators exist** — hitting the port-binding limit first-hand makes *why* Kubernetes exists concrete instead of abstract. Today is the natural bridge to it.
- **Infra parallel** — restart policies are the container version of "make the service come back after a crash or reboot," and labels are how you keep a growing fleet organized — both daily concerns when you run systems at scale.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DockerCompose` `#DevOps`
