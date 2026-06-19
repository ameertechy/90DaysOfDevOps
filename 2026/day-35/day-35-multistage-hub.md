# Day 35 – Multi-Stage Builds & Docker Hub
*#90DaysOfDevOps 2026*

---

## Task 1 — The Problem With Large Images (single stage)

A tiny Go app to make the size difference obvious.

**`main.go`**
```go
package main

import "fmt"

func main() { fmt.Println("Hello from a Docker image!") }
```

**`Dockerfile` (single stage)**
```dockerfile
FROM golang:1.23
WORKDIR /app
COPY . .
RUN go build -o app .
CMD ["./app"]
```

```bash
docker build -t hello:single .
docker images hello:single
# REPOSITORY   TAG      SIZE
# hello        single   ~1.27GB    <- the WHOLE Go toolchain shipped
```

**The problem:** the final image contains the entire Go compiler and build tools — none of which are needed to *run* a compiled binary. ~1.27GB to ship a few-MB program.

---

## Task 2 — Multi-Stage Build

**`Dockerfile.multistage`**
```dockerfile
# ---------- Stage 1: builder ----------
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o app .     # static binary, no external libs

# ---------- Stage 2: runner ----------
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/app .          # copy ONLY the built binary
CMD ["./app"]
```

```bash
docker build -f Dockerfile.multistage -t hello:multi .
docker images | grep hello
# hello   single   ~1.27GB
# hello   multi    ~15.6MB      <- ~80x smaller
```

### Size comparison

| Image | Size | What it contains |
|-------|------|------------------|
| `hello:single` | ~1.27 GB | Go toolchain + source + binary |
| `hello:multi` | ~15.6 MB | alpine base + the binary only |

### Why is the multi-stage image so much smaller?

The build stage (`golang:1.23`) has everything needed to **compile** — compiler, standard library, build tools — and produces the binary. The final stage starts from a **fresh, tiny base** (`alpine`) and uses `COPY --from=builder` to bring across **only the compiled binary**. Everything in the builder stage is discarded.

**In one line:** I ship the *result* of the build, not the *tools* that did the build.

> Even smaller: `FROM scratch` (empty base) for a fully static binary → final image is basically just the binary (~5MB). `alpine` is friendlier because it has a shell for debugging.

---

## Task 3 — Push to Docker Hub

```bash
# 1. Log in (create a free account at hub.docker.com first)
docker login
# Username: myusername
# Password: ********   (use an access token, not your password, for safety)

# 2. Tag the image as username/repo:tag
docker tag hello:multi myusername/hello-app:1.0

# 3. Push it
docker push myusername/hello-app:1.0

# 4. Verify — remove locally, then pull it back
docker rmi myusername/hello-app:1.0
docker pull myusername/hello-app:1.0
docker run myusername/hello-app:1.0
# -> Hello from a Docker image!   ✅ (pulled from the registry, ran anywhere)
```

| Step | Command | Meaning |
|------|---------|---------|
| Login | `docker login` | Authenticate to Docker Hub (token recommended over password) |
| Tag | `docker tag local user/repo:tag` | Rename the image to the `username/repo:tag` form the registry expects |
| Push | `docker push user/repo:tag` | Upload the image — like `git push` for images |
| Pull | `docker pull user/repo:tag` | Download it on any machine |

> The image is now public at `hub.docker.com/r/myusername/hello-app` — anyone can `docker pull` and run it.

---

## Task 4 — Docker Hub Repository

- **Description:** added a short description on the repo page so visitors know what the image is.
- **Tags tab:** shows every tag I've pushed (`1.0`, `latest`, …) with size and push date — this is how versioning is tracked.
- **`latest` vs a specific tag:**

```bash
docker pull myusername/hello-app           # defaults to :latest
docker pull myusername/hello-app:1.0        # pulls EXACTLY 1.0
```

**What I learned:** `latest` is **not** "the newest version" — it's just the default tag applied when you don't specify one. It points to whatever was last pushed as `latest`. For anything real, pull a **specific** tag so you always get the exact image you expect.

---

## Task 5 — Image Best Practices

Applied to the image and rebuilt, checking size each time.

**`Dockerfile` (hardened)**
```dockerfile
# 1. Minimal, SPECIFIC base tag (not :latest)
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o app .

FROM alpine:3.20

# 2. Don't run as root — create and switch to a non-root user
RUN adduser -D appuser
USER appuser

WORKDIR /app
COPY --from=builder /app/app .
CMD ["./app"]
```

| Practice | Why | How |
|----------|-----|-----|
| **Minimal base** | Smaller + fewer CVEs | `alpine` (~5MB) vs `ubuntu` (~78MB) |
| **Non-root user** | Security — don't run as root | `RUN adduser -D appuser` + `USER appuser` |
| **Fewer layers** | Smaller, cleaner image | Combine: `RUN apt-get update && apt-get install -y x && rm -rf /var/lib/apt/lists/*` |
| **Specific tags** | Reproducible builds | `FROM alpine:3.20`, never `FROM alpine:latest` |

**alpine vs ubuntu size check:**
```bash
docker pull alpine:3.20    # ~7MB
docker pull ubuntu:24.04   # ~78MB
```

---

## Command Reference — Multi-Stage & Registry

| Command | What It Does |
|---------|-------------|
| `FROM image AS builder` | Name a build stage |
| `COPY --from=builder /src /dst` | Copy an artifact from an earlier stage |
| `docker build -f File -t name:tag .` | Build using a specific Dockerfile |
| `docker images` | Compare image sizes |
| `docker login` | Authenticate to Docker Hub |
| `docker tag local user/repo:tag` | Tag for the registry |
| `docker push user/repo:tag` | Upload to Docker Hub |
| `docker pull user/repo:tag` | Download from Docker Hub |
| `docker history image` | See the layers (and what adds size) |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Multi-stage build | Ship the artifact, not the toolchain → tiny images |
| `COPY --from=builder` | The line that leaves the build tools behind |
| Minimal base | Smaller = faster pulls + smaller attack surface |
| Non-root USER | Security baseline for any image |
| Docker Hub | `git push` for images — distribute anywhere |
| `latest` | A default tag, not "newest" — pin specific tags in production |

---

*#90DaysOfDevOps 2026*
