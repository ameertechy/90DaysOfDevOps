# Day 34 – Docker Compose: Real-World Multi-Container Apps
*#90DaysOfDevOps 2026*

---

## Task 1 — Build a 3-Service App Stack (web + database + cache)

Folder layout:
```
day-34-stack/
├── docker-compose.yml
├── .env
└── app/
    ├── Dockerfile
    ├── package.json
    └── server.js
```

### The web app (minimal Node.js — DB + Redis)

**`app/server.js`** — a tiny app that proves it can reach both backing services:
```js
const express = require("express");
const { Pool } = require("pg");
const redis = require("redis");

const app = express();
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});
const cache = redis.createClient({ url: `redis://${process.env.REDIS_HOST}:6379` });
cache.connect();

app.get("/", async (req, res) => {
  const visits = await cache.incr("visits");          // cache (Redis)
  const db = await pool.query("SELECT NOW()");          // database (Postgres)
  res.send(`Hello! Visits: ${visits}. DB time: ${db.rows[0].now}`);
});

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.listen(3000, () => console.log("web app on :3000"));
```

**`app/package.json`**
```json
{
  "name": "stack-web",
  "version": "1.0.0",
  "dependencies": { "express": "^4.19.2", "pg": "^8.12.0", "redis": "^4.7.0" }
}
```

**`app/Dockerfile`**
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

> The app is deliberately trivial — the point is the **Compose orchestration**, not the code. It just proves all three services talk to each other.

---

## The full `docker-compose.yml` (everything from Tasks 2–5)

```yaml
services:
  web:
    build: ./app                       # Task 4 — build from a Dockerfile
    ports:
      - "${WEB_PORT}:3000"
    environment:
      DB_HOST: db
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}
      REDIS_HOST: cache
    depends_on:
      db:
        condition: service_healthy     # Task 2 — wait until DB is READY
      cache:
        condition: service_started
    networks: [appnet]                 # Task 5 — explicit network
    labels:                            # Task 5 — labels
      app: "day34-stack"
      tier: "frontend"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - db_data:/var/lib/postgresql/data   # Task 5 — named volume
    healthcheck:                           # Task 2 — healthcheck
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: always                        # Task 3 — restart policy
    networks: [appnet]
    labels:
      app: "day34-stack"
      tier: "database"

  cache:
    image: redis:7-alpine
    restart: on-failure                    # Task 3 — different policy
    networks: [appnet]
    labels:
      app: "day34-stack"
      tier: "cache"

networks:
  appnet:
    driver: bridge

volumes:
  db_data:
```

**`.env`**
```
WEB_PORT=8000
DB_USER=appuser
DB_PASSWORD=apppass
DB_NAME=appdb
```

```bash
docker compose up -d --build
# open http://localhost:8000  ->  "Hello! Visits: 1. DB time: ..."
# refresh -> Visits increments (Redis), DB time updates (Postgres)
```

---

## Task 2 — depends_on & Healthchecks

```yaml
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 5s      # run the check every 5s
      timeout: 3s       # each check must answer within 3s
      retries: 5        # 5 failures in a row = "unhealthy"

  web:
    depends_on:
      db:
        condition: service_healthy   # wait for the healthcheck to PASS
```

**Test:**
```bash
docker compose down && docker compose up -d
docker compose logs web
# web does NOT log connection errors — it waited for the DB to be ready
```

**What I learned — started vs ready:**
- Plain `depends_on: [db]` only guarantees the DB container has **started** — not that Postgres is accepting connections.
- `condition: service_healthy` makes Compose wait until the **healthcheck passes**, so the app connects on the first try.
- This is the fix for the classic "app crashes on boot because the DB isn't up yet" race.

| condition | Meaning |
|-----------|---------|
| `service_started` | Dependency container has started (default behaviour) |
| `service_healthy` | Dependency has passed its healthcheck |
| `service_completed_successfully` | Dependency ran and exited 0 (for one-shot init jobs) |

---

## Task 3 — Restart Policies

> ⚠️ **Gotcha I hit and tested:** `restart: always` does **not** bring a container
> back after `docker kill` or `docker stop`. Docker records an explicit CLI stop/kill
> as an *intentional* stop, so the policy stands down (otherwise you could never take
> an `always` container down). The policy fires on **unexpected** exits — the process
> crashing on its own, an OOM kill, or the Docker daemon / host restarting.

```bash
# This does NOT restart the db — docker kill is treated as an intentional stop:
docker kill day-34-stack-db-1
docker compose ps              # db is gone; RestartCount stays 0

# Reliable ways to SEE self-healing:
# A) the real scenario — restart Docker Desktop / reboot → every `restart: always`
#    container comes back automatically.
# B) a container that exits ON ITS OWN (a true crash):
docker run -d --restart always --name crashloop alpine sh -c "sleep 3; exit 1"
docker inspect crashloop --format '{{.RestartCount}}'   # climbs — the policy restarts it
docker rm -f crashloop
```

### Answer — when to use each restart policy

| Policy | Behaviour | Use when |
|--------|-----------|----------|
| `no` (default) | Never restart automatically | One-off / throwaway containers |
| `on-failure` | Restart only on a **non-zero** exit (a crash); add `:N` to cap retries | Batch jobs, tasks that may crash but a clean exit means "done" |
| `always` | Restart on an **unexpected** exit (crash/OOM) or a daemon/host restart — **not** on an explicit `docker stop`/`kill` | Long-running services (databases, web servers) |
| `unless-stopped` | Like `always`, but stays stopped if **you** stopped it manually | Services you want resilient but also want to be able to take down |

**What I saw (tested):** `docker kill`/`docker stop` did **not** trigger a restart — Docker treats them as intentional stops (RestartCount stayed 0). A container whose process exits on its own, or a host reboot, *does* get restarted by `always`. `on-failure` restarts only on a non-zero exit.

---

## Task 4 — Custom Dockerfiles in Compose

```yaml
  web:
    build: ./app        # build from app/Dockerfile instead of a prebuilt image
```

```bash
# Change code in app/server.js, then:
docker compose up -d --build     # rebuild the image AND restart, one command
# or just rebuild one service:
docker compose build web
```

| Flag | What it does |
|------|-------------|
| `build: ./app` | Build the image from the Dockerfile in `./app` (the build context). |
| `up -d --build` | Rebuild images, then (re)start the stack detached. |
| `build web` | Rebuild only the `web` service's image. |

> The edit → rebuild → run loop is now a single command. No separate `docker build` + `docker run`.

---

## Task 5 — Named Networks, Volumes & Labels

```yaml
networks:
  appnet:            # explicit network instead of the implicit default
    driver: bridge

volumes:
  db_data:           # named volume for the database

services:
  db:
    networks: [appnet]
    volumes:
      - db_data:/var/lib/postgresql/data
    labels:          # metadata for organization/filtering
      app: "day34-stack"
      tier: "database"
```

**Why each matters:**
- **Explicit network** — clearer intent than the auto default, and lets you control driver/options and connect multiple compose projects deliberately.
- **Named volume** — DB data persists across `down`/`up` (removed only with `down -v`).
- **Labels** — key/value metadata you can filter on: `docker ps --filter "label=app=day34-stack"`. Essential once you run many containers.

---

## Task 6 — Scaling (Bonus)

```bash
docker compose up -d --scale web=3
# ERROR: only one container can bind host port 8000
```

### Answer — Why doesn't simple scaling work with port mapping?

Because the `web` service publishes a **fixed host port** (`8000:3000`). A host port can be owned by **only one container at a time**, so the 2nd and 3rd replicas have nowhere to bind and fail.

**How real scaling solves it:**
- **Remove the host port mapping** and put a **reverse proxy / load balancer** (nginx, Traefik) in front, distributing traffic across the replicas on the internal network.
- Or use an **orchestrator** (Kubernetes, Docker Swarm) that gives each replica its own networking and load-balances via a Service.

> This is the exact wall that makes orchestration necessary — and a concrete reason Kubernetes exists.

---

## Command Reference — Advanced Compose

| Command | What It Does |
|---------|-------------|
| `docker compose up -d --build` | Rebuild images + start detached |
| `docker compose ps` | List services + health status |
| `docker compose logs -f web` | Follow one service's logs |
| `docker compose up --scale web=3` | Run 3 replicas of a service |
| `docker compose config` | Render the resolved config (verify `.env`) |
| `docker compose down -v` | Remove everything incl. named volumes |
| `docker ps --filter "label=app=day34-stack"` | Filter containers by label |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| `depends_on` + healthcheck | Wait for **ready**, not just **started** |
| `condition: service_healthy` | The fix for the startup race |
| `restart: always` | Self-healing long-running services |
| `restart: on-failure` | Restart only on crash, not clean exit |
| `build:` in Compose | One command to rebuild + run |
| Explicit network/volume/labels | Clear intent + organization |
| Scaling + fixed ports | Breaks — needs a load balancer / orchestrator |

---

*#90DaysOfDevOps 2026*
