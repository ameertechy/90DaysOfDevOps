# Day 30 – Docker Images & Container Lifecycle

## Overview

Day 30 builds straight on yesterday. Day 29 was "what *is* a container" — today is what's *underneath* it: how images are actually built, why they're the size they are, and every state a container moves through in its life.

After running containers yesterday, the questions I couldn't answer were exactly today's topics. Why is the second `docker pull` instant? Why is `alpine` tiny and `ubuntu` not? Is a container only ever "running" or "stopped", or is there more going on? Today answered all three by digging into **image layers** and walking one container through its **full lifecycle** — create, start, pause, unpause, stop, restart, kill, remove — watching the state change at each step.

Honest context: this is all still new ground. I'm 30 days into learning DevOps in public, coming from IT support (mostly Windows), and containers weren't part of my world a month ago. But stepping through the lifecycle one command at a time, and checking `docker ps -a` after each, made it concrete instead of abstract.

---

## What I Produced

- [`day-30-images.md`](./day-30-images.md) — image layers explained, the full container lifecycle, and the working/inspect/cleanup commands
- Screenshots of key commands in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Pulled `nginx`, `ubuntu`, `alpine`; compared sizes; inspected an image; removed one I didn't need |
| 2 | Ran `docker image history nginx` and learned what layers are and why some show 0B |
| 3 | Walked one container through the **full lifecycle**: create → start → pause → unpause → stop → restart → kill → rm |
| 4 | Logs, follow-mode logs, exec, single commands, and `inspect` (found IP, port mappings, mounts) |
| 5 | Cleanup one-liners — stop all, remove all stopped, prune unused images, `docker system df` for disk usage |

---

## Key Observations

**Layers are why Docker is fast — and why the second pull is basically free.**
An image is a stack of read-only layers. `alpine` is ~5MB and `ubuntu` ~78MB because Alpine ships almost nothing. The real eye-opener from `docker image history`: layers are cached and *shared* between images. Pull two images built on the same base and the shared layers download once — which is exactly why my second pull was instant. Docker already had the layers.

**Some layers show 0B — and that makes sense once you see why.**
In `docker image history`, instruction layers that only set metadata (like `CMD` or `EXPOSE`) add no files, so they weigh 0B. Only layers that actually add or change files have a size. Layers aren't "lines" — they're filesystem changes.

**A container has more states than "running" and "stopped".**
Stepping through the lifecycle and checking `docker ps -a` each time exposed states I didn't know existed: *Created* (exists, never started), *Paused* (frozen, still in memory), *Exited*. "Container = process" clicked harder here — pause literally freezes the process, `kill` is a hard `SIGKILL`, `stop` is a polite `SIGTERM` that lets it shut down cleanly.

**`docker inspect` is the container's full medical chart.**
One command returned its IP address, port mappings, mounts, environment, and state — all the things I'd otherwise hunt for in five places. When something misbehaves, this is the first place to look.

---

## Real-World Tie-in

- **Image size is a real cost, not trivia** — smaller images (Alpine) mean faster pulls, faster deploys, and less attack surface. In a pipeline that builds dozens of times a day, "78MB vs 5MB" adds up fast.
- **Layer caching is what makes CI/CD quick** — because unchanged layers are reused, rebuilding an image after a small change only rebuilds what changed. That's the difference between a 10-second and a 10-minute pipeline step.
- **Lifecycle states map to real operations** — knowing the difference between stop, kill, and restart is exactly what you need when a service hangs in production and you have to decide how forcefully to bounce it.
- **`docker inspect` is a troubleshooting reflex** — coming from support, this is the container equivalent of pulling full system info before you start guessing. Look first, then act.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#Containers` `#DevOps`
