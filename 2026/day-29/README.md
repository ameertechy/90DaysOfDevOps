# Day 29 – Introduction to Docker

## Overview

Day 29 is the one I'd been quietly waiting for — **Docker**. After a month of Linux, shell scripting, and Git, this is the first tool that feels like the "modern DevOps" everyone talks about. And it landed on a **live session day with Shubham**, which made a real difference: watching containers spin up live, with the *why* explained as it happened, is a different thing from reading docs alone.

Here's my honest starting point — I'd heard "containers" for years on the support side without ever really getting it. I knew VMs (I've built and broken plenty of those). But the leap from "a whole virtual machine" to "just the app and its dependencies, sharing the host kernel" never clicked until today. The penny-drop moment: a container isn't a tiny computer, it's a tiny *process* that thinks it has its own machine.

Today I covered what a container actually is, how it differs from a VM, the Docker architecture (daemon, client, images, containers, registry), then got hands-on: `hello-world`, Nginx in the browser, an interactive Ubuntu container, and the core lifecycle — run, list, stop, remove, detach, name, port-map, logs, exec.

---

## What I Produced

- [`day-29-docker-basics.md`](./day-29-docker-basics.md) — Docker concepts, architecture in my own words, and every hands-on command with what I observed
- Screenshots of my first running containers in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Wrote up what a container is, containers vs VMs, and the Docker architecture in my own words |
| 2 | Installed Docker, verified it, ran `hello-world` and actually read what the output was telling me |
| 3 | Ran Nginx (opened it in the browser), explored an interactive Ubuntu container, walked the full list/stop/remove lifecycle |
| 4 | Detached mode, custom `--name`, port mapping `-p`, `docker logs`, and `docker exec` into a live container |

---

## Key Observations

**A container is a process, not a tiny computer — that's the whole mental shift.**
A VM virtualizes hardware and boots a full guest OS (its own kernel, gigabytes, minutes to start). A container shares the host's kernel and packages only the app + its dependencies — megabytes, up in seconds. Once I stopped picturing "small VM" and started picturing "isolated process", everything else made sense.

**The Docker client isn't doing the work — the daemon is.**
When I type `docker run`, the client just sends that request to the Docker daemon (`dockerd`), which pulls the image, creates the container, and runs it. Realizing the CLI is a thin front-end to a background service explained a lot about how Docker behaves — and why it can manage things I'm not directly watching.

**Image vs container is the class-vs-object of Docker.**
An image is the read-only blueprint; a container is a running instance of it. One Nginx image → as many Nginx containers as I want. That single distinction cleared up half my early confusion.

**`-d`, `-it`, `-p`, `--name` are the four flags I'll use forever.**
Detached to run in the background, interactive to get a shell, port-map to actually reach the thing, and name so I'm not copy-pasting container IDs all day. These four came up in nearly every command today.

---

## Real-World Tie-in

- **This is the "works on my machine" fix I wished for in support.** Half my old tickets were environment drift — works here, breaks there. A container ships the environment *with* the app. That problem I lived with for years has an actual answer, and it's this.
- **Everything ahead of me starts here** — CI/CD pipelines, Kubernetes, microservices all sit on top of containers. Day 29 isn't a side topic; it's the foundation the rest of the challenge builds on.
- **Lightweight enough to actually experiment** — spinning up Nginx or Ubuntu in seconds, then throwing it away, means I can test ideas without provisioning a VM or fearing I'll break something. That speed changes how willing I am to try things.
- **University infrastructure angle** — instead of one bloated server hand-configured over years, containers mean each service is reproducible, isolated, and rebuildable from a definition. That's a cleaner, safer way to run internal tooling.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#Containers` `#DevOps`
