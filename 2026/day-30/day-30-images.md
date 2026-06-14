# Day 30 – Docker Images & Container Lifecycle
*#90DaysOfDevOps 2026*

---

## Task 1 — Docker Images

```bash
# Pull three images from Docker Hub
docker pull nginx
docker pull ubuntu
docker pull alpine

# List all local images — note the SIZE column
docker images
```

Example sizes I saw:

| Image | Size (approx) |
|-------|--------------|
| `alpine` | ~5–8 MB |
| `nginx` | ~145 MB |
| `ubuntu` | ~78 MB |

```bash
# Inspect an image — full JSON metadata
docker inspect nginx

# Remove an image you no longer need
docker rmi alpine
```

### Why is `ubuntu` so much bigger than `alpine`?

Both are Linux base images, but they ship very different amounts:
- **Ubuntu** includes a full-featured userland — package manager, many default utilities, glibc. Convenient, but heavy.
- **Alpine** is built for minimalism — it uses `musl` libc and `busybox` instead of the usual GNU tools, so the whole base is only a few MB.

**The lesson:** pick the smallest base image that still has what your app needs. Smaller = faster pulls, faster deploys, smaller attack surface.

> `docker inspect` shows architecture, layers, environment variables, the default command, exposed ports, and more — it's the full spec sheet of an image.

---

## Task 2 — Image Layers

```bash
docker image history nginx
```

**What I saw:** a list of layers, each with a size. Some layers have a real size (they added files); some show **0B**.

### What are layers, and why does Docker use them?

An image is **not one solid blob** — it's a **stack of read-only layers**, each one the result of a build instruction. When you build an image, every instruction (install a package, copy a file, set a command) adds a new layer on top.

**Why this is brilliant:**
1. **Caching** — layers are cached. Rebuild after a small change and Docker reuses every unchanged layer; only the changed layer (and the ones after it) rebuild.
2. **Sharing** — layers are shared between images. Two images on the same base share that base's layers on disk and download it only once. That's why my *second* `docker pull` was nearly instant.
3. **Why some layers are 0B** — instructions that only set metadata (`CMD`, `EXPOSE`, `ENV`, `LABEL`) don't add files, so they weigh **0B**. Only file-changing instructions have a size.

> Mental model: a layer is a **set of filesystem changes**, not a line of text. The final image is all the layers stacked, viewed as one filesystem.

---

## Task 3 — Container Lifecycle (the full walk)

I ran one container through every stage, checking `docker ps -a` after each to watch the **STATUS** change.

```bash
# 1. CREATE — makes the container but does NOT start it
docker create --name lifecycle-demo nginx
docker ps -a        # STATUS: Created

# 2. START — now it's running
docker start lifecycle-demo
docker ps -a        # STATUS: Up (running)

# 3. PAUSE — freezes the processes (still in memory)
docker pause lifecycle-demo
docker ps -a        # STATUS: Up (Paused)

# 4. UNPAUSE — resume from frozen
docker unpause lifecycle-demo
docker ps -a        # STATUS: Up (running)

# 5. STOP — graceful: sends SIGTERM, then SIGKILL after a grace period
docker stop lifecycle-demo
docker ps -a        # STATUS: Exited (0)

# 6. RESTART — stop + start in one command
docker restart lifecycle-demo
docker ps -a        # STATUS: Up (running)

# 7. KILL — immediate: sends SIGKILL, no cleanup
docker kill lifecycle-demo
docker ps -a        # STATUS: Exited (137)

# 8. REMOVE — delete the container for good
docker rm lifecycle-demo
docker ps -a        # gone
```

### The states I observed

| State | Meaning |
|-------|---------|
| **Created** | Container exists but has never run |
| **Up (running)** | Active |
| **Up (Paused)** | Processes frozen, still held in memory |
| **Exited (0)** | Stopped cleanly (exit code 0) |
| **Exited (137)** | Killed (128 + 9 = SIGKILL) |

### stop vs kill (the distinction that stuck)

- **`docker stop`** → polite. Sends **SIGTERM**, gives the process time to shut down cleanly, *then* SIGKILL if it ignores. Use this normally.
- **`docker kill`** → forceful. Sends **SIGKILL** immediately — no cleanup, no goodbye. Use only when stop hangs.

This maps straight back to "a container is a process" — these are the same signals I'd send a Linux process with `kill`.

---

## Task 4 — Working With Running Containers

```bash
# Run Nginx detached
docker run -d --name web -p 8080:80 nginx

# Logs
docker logs web              # everything logged so far
docker logs -f web           # -f = follow live (Ctrl+C to stop watching)
docker logs --tail 20 web    # last 20 lines only

# Exec INTO the container
docker exec -it web bash     # interactive shell inside the running container
#   inside: ls /usr/share/nginx/html ; exit

# Run a single command WITHOUT entering
docker exec web ls /etc/nginx

# Inspect — find IP, ports, mounts
docker inspect web
docker inspect -f '{{ .NetworkSettings.IPAddress }}' web    # just the IP
docker inspect -f '{{ .NetworkSettings.Ports }}' web        # just the port mappings
```

| Command | What it gives me |
|---------|-----------------|
| `docker logs` / `-f` | What the container has printed / live stream |
| `docker exec -it … bash` | A shell inside a *running* container |
| `docker exec … <cmd>` | One-off command, no shell session |
| `docker inspect` | Full JSON: IP address, port mappings, mounts, env, state |
| `docker inspect -f '{{ … }}'` | `-f` applies a Go-template to pull out one field cleanly |

> **`run` vs `exec`:** `run` starts a **new** container from an image; `exec` runs a command in a container that's **already running**. Mixing these up is the classic beginner trip-up.

---

## Task 5 — Cleanup

```bash
# Stop ALL running containers in one command
docker stop $(docker ps -q)

# Remove ALL stopped containers
docker rm $(docker ps -aq)
# or the purpose-built command:
docker container prune -f

# Remove unused (dangling) images
docker image prune -f
docker rmi $(docker images -q)        # remove ALL images (aggressive)

# How much disk is Docker using?
docker system df
docker system prune -f                # remove stopped containers, unused networks + dangling images at once
```

| Part | Meaning |
|------|---------|
| `$(docker ps -q)` | Command substitution — `ps -q` lists running container **IDs only**; feeds them to `stop`. |
| `$(docker ps -aq)` | `-aq` = **a**ll containers, IDs only (**q**uiet) — including stopped. |
| `container prune` / `image prune` | Purpose-built cleanup; `-f` skips the confirmation. |
| `docker system df` | Disk-usage breakdown: images, containers, volumes, build cache. |
| `docker system prune` | One-shot reclaim of everything unused. Add `-a` to also drop unused (not just dangling) images. |

---

## Command Reference — Images & Lifecycle

| Command | What It Does |
|---------|-------------|
| `docker pull IMAGE` | Download an image from the registry |
| `docker images` | List local images + sizes |
| `docker image history IMAGE` | Show the layers an image is built from |
| `docker inspect IMAGE/CONTAINER` | Full JSON metadata |
| `docker rmi IMAGE` | Remove an image |
| `docker create --name N IMAGE` | Create a container without starting it |
| `docker start / stop / restart N` | Start / graceful stop / restart |
| `docker pause / unpause N` | Freeze / resume a running container |
| `docker kill N` | Force-stop (SIGKILL) |
| `docker rm N` | Remove a container |
| `docker logs -f N` | Follow a container's logs |
| `docker exec -it N bash` | Shell into a running container |
| `docker system df` / `prune` | Disk usage / reclaim space |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Image = stacked read-only layers | Built from instructions; final image is all layers viewed as one |
| Layer caching + sharing | Why rebuilds and second pulls are fast |
| 0B layers | Metadata-only instructions add no files |
| alpine vs ubuntu | Pick the smallest base that fits — size = speed + security |
| Lifecycle states | Created, Running, Paused, Exited — more than just on/off |
| stop vs kill | SIGTERM (graceful) vs SIGKILL (forceful) |
| `docker inspect` | The first stop when troubleshooting a container |

---

*#90DaysOfDevOps 2026*
