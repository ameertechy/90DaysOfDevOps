# Day 31 – Dockerfile: Build Your Own Images

## Overview

Day 31 is the line between *using* Docker and *shipping* with it. For the last two days I've been running other people's images — Nginx, Ubuntu, Postgres. Today I write the recipe myself: a **Dockerfile** that bakes my own image.

I got a preview of this in the weekend live session, so today was about doing it properly and slowly — understanding what every instruction actually does instead of copying a template. A Dockerfile is just a set of ordered instructions Docker runs top-to-bottom to assemble an image, and each instruction becomes one of those cached layers I learned about on Day 30. That connection clicked today: writing a Dockerfile *is* deciding what layers my image will have.

I worked through six things: my first custom image, every core instruction (`FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD`), the `CMD` vs `ENTRYPOINT` difference that confuses everyone, building a real Nginx web image, using `.dockerignore`, and finally *why layer order decides build speed*.

---

## What I Produced

- [`day-31-dockerfile.md`](./day-31-dockerfile.md) — every Dockerfile I wrote, with line-by-line explanations and the answers to each task
- Screenshots of my custom image building and running in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Wrote my first Dockerfile (ubuntu + curl + a custom message), built `my-ubuntu:v1`, ran it |
| 2 | Built an image using **all** core instructions: `FROM`, `RUN`, `COPY`, `WORKDIR`, `EXPOSE`, `CMD` |
| 3 | Compared **`CMD` vs `ENTRYPOINT`** — saw exactly how each behaves when you pass extra arguments |
| 4 | Built a real web image — `nginx:alpine` + my `index.html`, tagged `my-website:v1`, opened it in the browser |
| 5 | Added a `.dockerignore` and confirmed ignored files never enter the build |
| 6 | Watched the **build cache** in action and reordered instructions for faster rebuilds |

---

## Key Observations

**A Dockerfile is just ordered instructions — and each one is a layer.**
This tied Day 30 and Day 31 together for me. Every line (`FROM`, `RUN`, `COPY`…) produces a layer, and Docker caches each one. So a Dockerfile isn't just "setup steps" — it's me deciding, line by line, what the image's layers will be.

**`CMD` is a default you can override; `ENTRYPOINT` is fixed.**
This was the day's real lightbulb. `CMD` sets a default command that gets *replaced* if you pass your own at `docker run`. `ENTRYPOINT` sets a command that always runs, and anything you pass becomes *arguments* to it. `CMD` = changeable default; `ENTRYPOINT` = "this image always does X".

**Layer order is a performance decision, not a style choice.**
Docker caches layers top-down and invalidates everything *after* the first changed line. So copying `package.json` and installing dependencies **before** copying the rest of the code means a code edit doesn't re-run the install. Put what changes least at the top, what changes most at the bottom.

**`.dockerignore` keeps junk out of the build — like `.gitignore` for images.**
Without it, `COPY . .` would drag `node_modules`, `.git`, and `.env` into the image — bloating it and risking leaked secrets. One small file prevents all of that.

---

## Real-World Tie-in

- **This is infrastructure-as-code.** A Dockerfile turns "set up the environment" into a versioned, reviewable file instead of a server someone configured by hand and forgot. Coming from support, that's the cure for the undocumented box nobody dares touch.
- **`.dockerignore` is a security control.** Keeping `.env` and credentials out of images is the same secret-hygiene lesson from Day 27 — just applied to the build instead of the repo.
- **Layer-order discipline is what keeps CI/CD fast.** In a pipeline that rebuilds dozens of times a day, ordering the Dockerfile so dependencies stay cached is the difference between a 10-second and a 10-minute build step.
- **`ENTRYPOINT` vs `CMD` shows up in every real image.** Knowing which one an image uses is how you predict what happens when you append a command — essential the moment you debug or customize someone else's container.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#Dockerfile` `#DevOps`
