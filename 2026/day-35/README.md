# Day 35 – Multi-Stage Builds & Docker Hub

## Overview

Day 35 is about two skills real teams use every day: building **small, secure images** with multi-stage builds, and **distributing** them through Docker Hub. I'd already used multi-stage builds earlier in the week, but today I focused on *why* they work and on the part I hadn't done yet — pushing my own image to a public registry so it can be pulled anywhere.

The multi-stage idea still impresses me: build the app with the full toolchain in one stage, then copy *only* the finished artifact into a tiny base image for the final stage. The heavy compilers and build tools never ship. The size drop is dramatic, and it's not a trick — it's just "don't ship what you don't run."

Then Docker Hub closed the loop on the whole Docker journey: I built an image, tagged it `myusername/app:tag`, pushed it, removed it locally, and pulled it back. That's the moment an image stops being something on my laptop and becomes something the world can run.

---

## What I Produced

- [`day-35-multistage-hub.md`](./day-35-multistage-hub.md) — the single-stage vs multi-stage Dockerfiles, the size comparison, the Docker Hub push, and the best-practices pass
- Dockerfiles demonstrating the multi-stage build
- An image pushed to my Docker Hub account
- Screenshots of the size difference and the Docker Hub repo in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Built a single-stage image and recorded its (large) size |
| 2 | Rewrote it as a **multi-stage build** and compared — a huge size drop |
| 3 | Logged in, tagged, **pushed to Docker Hub**, then pulled it back to verify |
| 4 | Added a repo description; explored the tags tab; compared `latest` vs a specific tag |
| 5 | Applied **image best practices** — minimal base, non-root user, fewer layers, pinned tags |

---

## Key Observations

**Multi-stage builds ship the result, not the workshop.**
The build stage has the full toolchain — compilers, dev dependencies, package managers. The final stage starts fresh from a tiny base and copies in *only* the built artifact. All the heavy build machinery stays behind. That's why the final image is a fraction of the size: I'm shipping the finished product, not the factory that made it.

**Smaller images aren't just about disk — they're about security and speed.**
A minimal base (alpine/distroless/scratch) has far fewer packages, which means a far smaller **attack surface** and fewer CVEs to patch. It also pulls and deploys faster. "Small" turns out to mean "safer and quicker" too.

**Docker Hub is `git push` for images.**
Tag with `username/repo:tag`, `docker push`, and the image is now pullable anywhere — exactly like pushing code to GitHub, but for runnable images. Pulling it back after deleting it locally made the whole registry idea concrete.

**`latest` is a convention, not a guarantee.**
`latest` is just the default tag — it doesn't mean "newest" or "stable", it's whatever was last pushed without a tag. Real deployments pin a **specific** tag (e.g. `:1.2.0`) so a build is reproducible and doesn't silently change under you.

---

## Real-World Tie-in

- **Small images are a production cost lever** — in a pipeline pulling images dozens of times a day across many nodes, the difference between a 900MB and a 15MB image is real time and bandwidth saved.
- **Non-root + minimal base is baseline security** — running containers as root on a fat image is exactly the kind of thing a security review flags. Building the habit now means it's automatic later.
- **A registry is how teams share work** — the same way I push notes to GitHub, teams push images to a registry so CI/CD, Kubernetes, and teammates can all pull the exact same artifact. This is the distribution half of containers.
- **Pinned tags = reproducibility** — coming from infra, "it changed and nobody knows why" is a nightmare; pinning image tags is the container version of controlling exactly what's running.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#DockerHub` `#DevOps`
