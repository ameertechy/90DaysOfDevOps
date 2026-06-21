# Docker Cheat Sheet
*My own one-page reference — Day 37, #90DaysOfDevOps 2026. One line per command, the stuff I actually reach for.*

---

## Container commands

| Command | What it does |
|---------|-------------|
| `docker run IMAGE` | Create + start a container from an image |
| `docker run -d IMAGE` | Detached — run in the background, free up the terminal |
| `docker run -it IMAGE` | Interactive + TTY — drop into a shell inside |
| `docker run -p 8080:80 IMAGE` | Publish host port 8080 → container port 80 |
| `docker run --name NAME IMAGE` | Give the container a friendly name |
| `docker ps` / `docker ps -a` | List running / all (incl. stopped) containers |
| `docker stop NAME` / `docker start NAME` | Stop / start a container |
| `docker rm NAME` | Remove a stopped container (`-f` to force a running one) |
| `docker exec -it NAME bash` | Open a shell inside a running container |
| `docker exec NAME <cmd>` | Run a single command inside without entering |
| `docker logs NAME` / `docker logs -f NAME` | Show / follow (live) a container's logs |
| `docker inspect NAME` | Full low-level details (IP, mounts, config) as JSON |

---

## Image commands

| Command | What it does |
|---------|-------------|
| `docker build -t name:tag .` | Build an image from the Dockerfile in `.` (build context) |
| `docker build -f File -t name .` | Build using a specific Dockerfile (`-f`) |
| `docker images` | List local images |
| `docker pull user/repo:tag` | Download an image from a registry |
| `docker push user/repo:tag` | Upload an image to a registry (after `docker login`) |
| `docker tag local user/repo:tag` | Re-tag an image into `user/repo:tag` form |
| `docker rmi name:tag` | Remove a local image |
| `docker history name:tag` | Show the layers (and what adds size) |

---

## Volume commands

| Command | What it does |
|---------|-------------|
| `docker volume create NAME` | Create a named volume |
| `docker volume ls` | List volumes |
| `docker volume inspect NAME` | Inspect a volume (mountpoint, driver) |
| `docker volume rm NAME` | Remove a volume |
| `-v name:/path` | Attach a **named volume** to a container path (persistent) |
| `-v /host/path:/path` | **Bind mount** a host folder (add `:ro` for read-only) |

---

## Network commands

| Command | What it does |
|---------|-------------|
| `docker network ls` | List networks |
| `docker network create NAME` | Create a custom bridge network (gives name-based DNS) |
| `docker network inspect NAME` | Inspect a network (subnet, connected containers) |
| `--network NAME` | Attach a container to a network at run time |
| `docker network connect NET CONTAINER` | Attach a running container to another network |
| `docker network rm NAME` | Remove a network |

---

## Compose commands

| Command | What it does |
|---------|-------------|
| `docker compose up -d` | Start the whole stack detached |
| `docker compose up -d --build` | Rebuild images, then start detached |
| `docker compose down` | Stop + remove containers/networks (keeps named volumes) |
| `docker compose down -v` | Same, **plus** remove named volumes (deletes data) |
| `docker compose ps` | List services + health status |
| `docker compose logs -f web` | Follow one service's logs |
| `docker compose build web` | Rebuild just the `web` service |
| `docker compose config` | Render the resolved config (verify `.env` substitution) |

---

## Cleanup commands

| Command | What it does |
|---------|-------------|
| `docker system df` | Show how much disk Docker is using (images/containers/volumes) |
| `docker system prune` | Remove stopped containers, unused networks, dangling images |
| `docker system prune -a --volumes` | Aggressive cleanup — also unused images **and** volumes |
| `docker image prune` | Remove dangling images |
| `docker container prune` | Remove all stopped containers |
| `docker volume prune` | Remove unused volumes |

---

## Dockerfile instructions

| Instruction | Purpose |
|-------------|---------|
| `FROM image:tag` | Base image — always first; pin a specific tag, not `:latest` |
| `RUN <cmd>` | Run a command at **build** time → creates a layer |
| `COPY src dst` | Copy files from build context into the image |
| `ADD src dst` | Like COPY, also handles URLs / auto-extracts tar — **prefer COPY** |
| `WORKDIR /app` | Set the working directory for everything that follows |
| `ENV KEY=value` | Set an environment variable in the image |
| `EXPOSE 80` | Document a port (informational — still need `-p` to publish) |
| `CMD ["exec","arg"]` | Default command at **run** time (overridable by `docker run` args) |
| `ENTRYPOINT ["exec"]` | Fixed command at **run** time (run args become its arguments) |
| `FROM image AS builder` | Name a build stage (multi-stage builds) |
| `COPY --from=builder /src /dst` | Copy an artifact from an earlier stage — ship the result, not the toolchain |
| `USER appuser` | Run as a non-root user (security baseline) |

---

*#90DaysOfDevOps 2026 — TrainWithShubham*
