# Day 36 – Docker Project: Dockerizing DevBoard
*#90DaysOfDevOps 2026*

---

## The App I Chose — and Why

**DevBoard** — a full-stack **Kanban project/task board** I'd been building:

```
browser ──▶ frontend (React/Vite) ──/api──▶ backend (Go + Gin) ──▶ PostgreSQL
```

- **Frontend** — React + Vite + Tailwind. A Kanban UI (projects, tasks with status `todo / in_progress / blocked / done` and priority `low / medium / high`). It forwards `/api/*` to the backend.
- **Backend** — a small Go + Gin REST API (`lib/pq`) over Postgres. Projects + tasks CRUD, no auth — kept deliberately small so the *wiring* (UI → gateway → Go → DB) is the whole lesson.
- **Database** — Postgres 16, with schema + seed data loaded on first start from `init/postgres/`.

**Why this app:** it's a real multi-service system with a database and service-to-service networking — exactly the shape of app you Dockerize on the job, not a hello-world. It needed proper multi-stage images, persistence, and a registry push.

---

## Task 2 — The Dockerfiles (multi-stage)

### Backend — `backend/Dockerfile.multistage`
```dockerfile
# ---------- Stage 1: builder ----------
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./           # deps first → better layer caching
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o devboard-backend .   # static binary, no libc

# ---------- Stage 2: runner ----------
FROM alpine:3.20
RUN adduser -D -u 10001 app     # non-root user (security)
USER app
WORKDIR /app
COPY --from=builder /app/devboard-backend .        # ONLY the binary
EXPOSE 8080
ENTRYPOINT ["./devboard-backend"]
```

### Frontend — `frontend/Dockerfile.multistage`
```dockerfile
# ---------- Stage 1: builder ----------
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                       # clean, reproducible install
COPY . .
RUN npm run build                # build the static bundle into /dist

# ---------- Stage 2: runner ----------
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf      # serve SPA + proxy /api
COPY --from=builder /app/dist /usr/share/nginx/html # ONLY the built files
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### `frontend/nginx.conf` (the routing that makes it work)
```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / { try_files $uri $uri/ /index.html; }   # SPA fallback

    # /api/tasks -> http://backend:8080/tasks  (trailing slash strips /api)
    location /api/ {
        proxy_pass http://backend:8080/;
        proxy_set_header Host $host;
    }
}
```

Both images also use a `.dockerignore` (`node_modules`, `dist`, `.git` for the frontend; `.git`, `*.md` for the backend) so junk never enters the build context.

---

## Task 3 — Docker Compose

`docker-compose.yml` — three services, all config from `.env`:
```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - pgdata:/var/lib/postgresql/data            # named volume → persistence
      - ./init/postgres:/docker-entrypoint-initdb.d:ro   # schema + seed on first init
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10
    ports: ["${POSTGRES_HOST_PORT}:5432"]

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.multistage
    environment:
      PORT: "${BACKEND_PORT}"
      POSTGRES_URL: "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable"
    depends_on:
      postgres:
        condition: service_healthy                 # wait for a READY db
    ports: ["${BACKEND_HOST_PORT}:${BACKEND_PORT}"]

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.multistage
    depends_on: [backend]
    ports: ["${FRONTEND_HOST_PORT}:80"]

volumes:
  pgdata:
```

- **Named volume** `pgdata` → the database survives `down`/`up`.
- **Network** → Compose creates one automatically; services reach each other by name (`backend`, `postgres`).
- **`.env` single source of truth** → credentials + ports live in one file; the backend's `POSTGRES_URL` is built from the same Postgres vars.
- **Healthcheck + `condition: service_healthy`** → the backend waits until Postgres actually accepts connections.

Run it:
```bash
cp .env.example .env
docker compose up --build
# open http://localhost:8080
```

---

## Task 4 — Ship It (Docker Hub)

```bash
docker login
# tag the compose-built images and push
docker tag devboard-backend  muja96/devboard-backend:1.0
docker tag devboard-frontend muja96/devboard-frontend:1.0
docker push muja96/devboard-backend:1.0
docker push muja96/devboard-frontend:1.0
```

**Docker Hub:** https://hub.docker.com/u/muja96
- `muja96/devboard-backend`
- `muja96/devboard-frontend`

---

## Task 5 — Test the Whole Flow (fresh run)

```bash
docker compose down -v                 # remove containers, network, AND the volume
docker image rm devboard-backend devboard-frontend   # wipe local images
docker compose up --build              # rebuild + run from clean
# open http://localhost:8080 → board loads, tasks come from Postgres ✅
```
If it works from a clean state, the project is genuinely portable — not just "works on the machine I built it on."

---

## Challenges I Faced (and how I solved them)

**1. Single-stage images were huge.**
The first versions were single-stage: the backend shipped the whole Go toolchain (~900MB) and the frontend shipped the full node image (~830MB). **Fix:** multi-stage builds — compile/build in one stage, copy only the artifact into a tiny base. Dramatic size drop.

**2. The bind mount silently mounted an empty directory (the Day-32 bug).**
Earlier, my Postgres init scripts didn't run — the tables didn't exist and the API returned `{"error":"internal error"}`. The cause was a Windows/Git-Bash `$PWD` path that Docker mounted as an **empty** directory, so `/docker-entrypoint-initdb.d` had nothing to run. **Fix:** correct the mount path and verify the files were actually inside with `docker exec ... ls` before trusting it. Compose's relative `./init/postgres` mount avoids the `$PWD` trap entirely.

**3. Moving the `/api` proxy from Vite to nginx.**
In dev/preview, Vite proxied `/api` to the backend and **stripped** the `/api` prefix (my Go routes are at `/projects`, `/tasks`, `/search`). Serving the built bundle with nginx meant rebuilding that in `nginx.conf` — a `proxy_pass http://backend:8080/` with a **trailing slash** to strip `/api`. **Lesson:** the routing has to move with the serving layer.

**4. Start-order race.**
The backend would try to connect before Postgres was ready. **Fix:** a healthcheck on Postgres + `depends_on: condition: service_healthy` so the backend waits for a *ready* DB, not just a started container.

---

## Final Image Sizes

| Image | Single-stage | Multi-stage | What changed |
|-------|-------------|-------------|--------------|
| `devboard-backend` | 912 MB | **31 MB** | Ship only the Go binary on alpine |
| `devboard-frontend` | 830 MB | **74 MB** | nginx serving the static build, no node toolchain |

> The backend dropped ~29× and the frontend ~11× — same app, a fraction of the size.

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Multi-stage builds | Biggest win — ship the artifact, not the toolchain |
| nginx for the SPA | Static serving + `/api` proxy (strip prefix with a trailing slash) |
| `.env` single source | Config + secrets in one place, not in the compose file |
| Healthcheck-gated start | Backend waits for a *ready* DB |
| Fresh-run test | Proves the project is actually portable |
| Registry push | The exact artifact is now pullable anywhere |

---

*#90DaysOfDevOps 2026*
