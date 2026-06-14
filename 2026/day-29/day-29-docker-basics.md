# Day 29 – Introduction to Docker
*#90DaysOfDevOps 2026 · Live session with Shubham*

---

## Task 1 — What is Docker?

### What is a container, and why do we need them?

A container is a **way to package an application together with everything it needs to run** — its code, runtime, libraries, and settings — into one isolated unit that runs the same way on any machine.

The problem it solves is the oldest one in IT: *"it works on my machine."* Software breaks when it moves between environments because the environments differ — a missing library, a different version, a wrong setting. A container removes that variable by **shipping the environment with the app**. If it runs in the container on my laptop, it runs in the same container on the server.

### Containers vs Virtual Machines — the real difference

| | Virtual Machine | Container |
|---|----------------|-----------|
| What it virtualizes | The **hardware** | The **operating system** (process-level) |
| Guest OS | Full OS + its own kernel | **Shares the host's kernel** — no guest OS |
| Size | Gigabytes | Megabytes |
| Startup | Minutes (it boots an OS) | Seconds (it starts a process) |
| Isolation | Strong (hardware-level) | Lighter (process-level, via namespaces/cgroups) |
| Overhead | Heavy — each VM runs a kernel | Light — kernel is shared |

**The mental model that made it click:** a VM is a whole house with its own foundation. A container is an apartment in a shared building — it has its own locked door and rooms (isolation), but shares the building's foundation and plumbing (the host kernel). You fit *many* apartments where you'd fit one house.

> A container is not a small VM. It's an **isolated process** that's been given its own view of the filesystem, network, and process tree.

### Docker Architecture (in my own words)

```
   ┌──────────────┐      docker run / build / pull      ┌─────────────────────┐
   │ Docker CLIENT│ ───────────────────────────────────▶│   Docker DAEMON     │
   │  (docker ..) │                                      │     (dockerd)       │
   └──────────────┘                                      │                     │
        what I type                                      │  builds images      │
                                                         │  runs containers    │
                                       ┌─────────────────┤  manages everything │
                                       │   pulls images  └─────────┬───────────┘
                                       ▼                           │ runs
                              ┌─────────────────┐         ┌────────▼────────┐
                              │   REGISTRY      │         │   CONTAINERS    │
                              │ (Docker Hub)    │         │ (running images)│
                              │  stores IMAGES  │         └─────────────────┘
                              └─────────────────┘
```

- **Docker Client** — the `docker` command I type. It just sends requests; it doesn't do the heavy lifting.
- **Docker Daemon (`dockerd`)** — the background service that does the actual work: building images, pulling them, and running/stopping containers.
- **Image** — a read-only **blueprint** (app + dependencies + instructions). Built once, run many times.
- **Container** — a **running instance** of an image. Image is the class; container is the object.
- **Registry (Docker Hub)** — the online store of images. `docker pull` downloads from it; `docker push` uploads to it.

The flow: I type a command (client) → daemon receives it → daemon pulls the image from the registry if needed → daemon runs it as a container.

---

## Task 2 — Install Docker & first container

```bash
# Verify the install
docker --version
docker info        # shows daemon status, containers, images — proves the daemon is running

# The traditional first container
docker run hello-world
```

**What `hello-world` actually told me** (reading the output, not skipping it):
1. The client contacted the daemon.
2. The daemon couldn't find the `hello-world` image locally, so it **pulled it from Docker Hub**.
3. The daemon **created a container** from that image.
4. The container ran, printed its message, and **exited**.

That four-step message is literally the whole architecture demonstrated in one command — that's why it exists.

---

## Task 3 — Run real containers

```bash
# Nginx — a real web server, reachable in the browser
docker run -d -p 8080:80 --name my-nginx nginx
# then open http://localhost:8080  → the Nginx welcome page

# Ubuntu — interactive, like a mini Linux box
docker run -it ubuntu
# I'm now INSIDE the container's shell:
#   cat /etc/os-release   → Ubuntu
#   ls /                  → its own filesystem
#   exit                  → leaves and stops the container

# List containers
docker ps          # only RUNNING containers
docker ps -a       # ALL containers, including stopped ones

# Stop and remove
docker stop my-nginx
docker rm my-nginx
```

**What I observed:**
- Nginx came up in ~1 second and served a real page on port 8080 — a full web server, no install, no config.
- The Ubuntu container dropped me into a shell that *felt* like a fresh Linux machine but is just an isolated process. Typing `exit` stopped it.
- `docker ps` confused me at first until I learned `-a` — a stopped container still **exists**, it's just not running. That's why you `rm` it separately.

---

## Task 4 — Explore (the flags that matter)

```bash
# Detached mode — runs in the background, gives me my terminal back
docker run -d --name web1 -p 8081:80 nginx

# Custom name (instead of a random like "adoring_einstein")
docker run -d --name my-app -p 8082:80 nginx

# Port mapping — host:container
docker run -d -p 9090:80 nginx     # host 9090 → container 80

# Logs of a running container
docker logs my-app
docker logs -f my-app              # -f follows live, like tail -f

# Run a command INSIDE a running container
docker exec -it my-app bash        # open a shell in the live container
docker exec my-app ls /usr/share/nginx/html   # run one command without entering
```

**What's different in detached mode?**
Without `-d`, the container holds my terminal — its output streams and I can't type. With `-d`, it runs in the background and returns the container ID, leaving my prompt free. For a long-running service like a web server, `-d` is what you want; `docker logs` is how you check on it afterward.

---

## Command Reference — Docker Basics

| Command | What It Does |
|---------|-------------|
| `docker --version` / `docker info` | Verify install / check daemon status |
| `docker run IMAGE` | Create + start a container from an image |
| `docker run -d ...` | Detached — run in the background |
| `docker run -it IMAGE` | Interactive + TTY — get a shell inside |
| `docker run -p host:container` | Map a host port to a container port |
| `docker run --name NAME ...` | Give the container a friendly name |
| `docker ps` / `docker ps -a` | List running / all containers |
| `docker stop NAME` | Stop a running container |
| `docker rm NAME` | Remove a (stopped) container |
| `docker logs NAME` / `-f` | Show / follow container logs |
| `docker exec -it NAME bash` | Open a shell inside a running container |
| `docker images` | List local images |
| `docker pull IMAGE` | Download an image from the registry |

---

## Flag Cheat-Sheet (the four I'll use forever)

| Flag | Long form | Meaning |
|------|-----------|---------|
| `-d` | `--detach` | Run in the background, free up the terminal |
| `-it` | `-i` + `-t` | Interactive (`-i` keep input open) + TTY (`-t` give a terminal) = a usable shell |
| `-p` | `--publish` | Publish a container port to the host: `host:container` |
| `--name` | | Name the container so you're not juggling random IDs |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Container = isolated process | Not a small VM — shares the host kernel, starts in seconds |
| Image vs container | Image = blueprint (class); container = running instance (object) |
| Client vs daemon | The `docker` CLI just sends requests; `dockerd` does the work |
| Registry | Docker Hub is the image store — `pull` down, `push` up |
| `ps` vs `ps -a` | Stopped containers still exist — that's why `rm` is separate |
| The "works on my machine" cure | The environment ships *with* the app |

---

*#90DaysOfDevOps 2026*
