# Day 33 – Docker Compose: Multi-Container Basics

## Overview

Day 33 is the day all the manual work from yesterday collapses into one file. On Day 32 I hand-created a network, a volume, and ran each container one by one with a long string of `docker run` flags. **Docker Compose** does all of that from a single `docker-compose.yml` — one command up, one command down.

After yesterday's debugging session (where a single wrong bind-mount path broke my whole app), I really felt why Compose matters: when the setup lives in a file, it's repeatable and reviewable instead of a fragile sequence of terminal commands I have to retype perfectly every time. The setup becomes documentation.

I worked through five things: verifying Compose, a single-service file (Nginx), a real two-service app (**WordPress + MySQL**) with a named volume and service-name networking, the everyday Compose commands, and configuration via environment variables and a `.env` file. The persistence test was the highlight — `down`, `up`, and my WordPress site was still there.

---

## What I Produced

- [`day-33-compose.md`](./day-33-compose.md) — every compose file I wrote, the commands, and the answers to each task
- Screenshots of WordPress running via Compose and surviving a restart in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Verified Docker Compose (`docker compose version`) |
| 2 | Wrote my first `docker-compose.yml` — a single Nginx service with port mapping; `up` → browser → `down` |
| 3 | Ran **WordPress + MySQL** together: auto-network, named volume, WordPress reaching MySQL by service name |
| 4 | Practised the core commands — `up -d`, `ps`, `logs` (all + specific), `stop`, `down`, `build` |
| 5 | Set config via inline environment variables **and** a `.env` file, and verified they were picked up |

---

## Key Observations

**Compose is yesterday's manual commands, written down.**
Everything I did by hand on Day 32 — create a network, create a volume, run containers, wire them together — Compose declares in YAML and does in one `up`. Same Docker underneath; the difference is it's now a repeatable file instead of a sequence I have to remember.

**Compose creates the network for you — so service-name DNS just works.**
On Day 32 I had to *create* a custom network to get name-based communication. Compose makes one automatically and puts every service on it, so WordPress reaching MySQL as `db` worked with zero extra setup. The thing I learned the hard way yesterday is the default here.

**The persistence test is the proof Compose isn't magic.**
`docker compose down` removed the containers and network — but because MySQL had a named volume, `docker compose up` brought my WordPress site back exactly as it was. Containers are disposable; the volume is what makes the data permanent. Day 32's lesson, now inside a file.

**`.env` keeps secrets and config out of the YAML.**
Compose reads a `.env` file automatically, so passwords and settings live outside the committed compose file. That's the clean way to separate "what the app is" from "how this environment is configured" — and to keep credentials out of git.

---

## Real-World Tie-in

- **This is how real apps are run locally and in many small deployments** — a single `docker-compose.yml` brings up an app, its database, and its cache together. It's the exact shape of the three-tier app I built for practice.
- **The setup becomes documentation** — a new engineer reads one YAML file and runs `docker compose up`, instead of following a wiki of `docker run` commands that drift out of date. Coming from infra, that's the cure for tribal knowledge.
- **`.env` separation mirrors good config hygiene** — same principle as keeping credentials out of scripts on a server: the definition is shared, the secrets are local.
- **Compose is the on-ramp to orchestration** — thinking in declarative services, networks, and volumes is the same mental model Kubernetes uses, just at a bigger scale. Learning it here makes the next jump smaller.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DockerCompose` `#DevOps`
