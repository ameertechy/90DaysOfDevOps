# Day 36 – Docker Project: Dockerize a Full Application

## Overview

Day 36 is the capstone of the Docker week — no tutorial, no hand-holding: take a real app and Dockerize it end-to-end, the way you'd do it on the job. I used **DevBoard**, a full-stack Kanban project/task board I'd been building: a **React (Vite) frontend → Go (Gin) REST API → PostgreSQL** database.

This day pulled together everything from Days 29–35 into one working system: my own images built from Dockerfiles (Day 31), multi-stage builds to shrink them (Days 30/35), volumes for data persistence and a network for service-name communication (Day 32), Docker Compose to orchestrate it all (Days 33–34), and a push to Docker Hub so anyone can pull and run it (Day 35).

The headline win: I **upgraded both images to multi-stage builds**. The backend dropped from a ~900MB single-stage image to a tiny binary on alpine, and the frontend went from a ~830MB node image to a small nginx image serving the built bundle. Same app, a fraction of the size — and a non-root user in both.

---

## What I Produced

- [`day-36-docker-project.md`](./day-36-docker-project.md) — the full project write-up: the app, the Dockerfiles (commented), the challenges I hit, final image sizes, and the Docker Hub link
- A complete, runnable project — `docker-compose.yml`, multi-stage Dockerfiles, app code, Postgres init scripts, `.env`-driven config
- Images pushed to Docker Hub
- Screenshots of the running stack and the image-size drop in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Chose **DevBoard** (React + Go + Postgres) — my own full-stack app that needed proper Dockerization |
| 2 | Wrote **multi-stage** Dockerfiles for both services — non-root user, alpine base, `.dockerignore` |
| 3 | `docker-compose.yml` — app + DB, named volume, compose network, `.env` config, Postgres healthcheck |
| 4 | Tagged and **pushed the images to Docker Hub**, with a project README |
| 5 | Tore everything down and ran it **fresh** to prove it works from a clean state |

---

## Key Observations

**Multi-stage builds are the single biggest win for a real app.**
Switching the backend to a builder→alpine multi-stage build took it from ~900MB to a tiny image — it ships only the compiled Go binary, not the whole toolchain. The frontend went from a node image running `vite preview` to an **nginx** image serving the static build (~830MB → a small nginx image). Production images should ship the *result*, not the build machinery.

**The frontend's `/api` proxy had to move from Vite to nginx.**
My dev/preview setup used Vite's proxy to forward `/api` to the backend (stripping the `/api` prefix). Serving the built bundle with nginx meant rebuilding that behaviour in `nginx.conf` — a `proxy_pass` with a trailing slash that strips `/api` so it matches the Go routes mounted at the root. Same routing, different layer.

**`.env` as the single source of truth keeps the whole stack honest.**
Every credential and port lives in `.env`; Compose substitutes them into the db and the backend (the backend's `POSTGRES_URL` is even built from the same Postgres vars). One place to change config, no secrets hard-coded in the compose file.

**The fresh-run test is the real exam.**
Tearing it all down and bringing it back from a clean state is what proves the project is actually portable — not just "works on the machine I built it on." If the healthcheck ordering, the init scripts, and the env wiring are right, `docker compose up` just works.

---

## Real-World Tie-in

- **This is what "Dockerize the app" actually means on the job** — not a hello-world, but a real multi-service system with a database, persistence, and service-to-service networking, shipped as images anyone can pull.
- **Image size is a production cost** — smaller images pull and deploy faster across every node and shrink the attack surface. The multi-stage drop is the difference between a heavy and a lean deployment.
- **Non-root + pinned bases are baseline security** — both images run as a non-root user on specific alpine tags, the kind of thing a security review expects by default.
- **A registry makes the app shareable** — pushing to Docker Hub means a teammate (or a CI/CD pipeline, or Kubernetes) pulls the exact same artifact I built, no "works on my machine."

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DockerCompose` `#DevOps`
