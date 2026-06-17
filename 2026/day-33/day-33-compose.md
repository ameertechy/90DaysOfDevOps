# Day 33 – Docker Compose: Multi-Container Basics
*#90DaysOfDevOps 2026*

---

## Task 1 — Install & Verify

```bash
docker compose version
# Docker Compose version v2.x.x
```

**Note:** modern Docker ships Compose as a **plugin** — the command is `docker compose` (a space), not the old standalone `docker-compose` (a hyphen). Both may work, but `docker compose` is current.

---

## Task 2 — My First Compose File (single Nginx)

```bash
mkdir compose-basics && cd compose-basics
```

**`docker-compose.yml`**
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

```bash
docker compose up          # foreground (logs stream; Ctrl+C stops)
# or
docker compose up -d       # detached (background)

# open http://localhost:8080  -> Nginx welcome page

docker compose down        # stop + remove containers and the default network
```

| Key | Meaning |
|-----|---------|
| `services:` | The top-level block — each entry is one container. |
| `web:` | The **service name** (also its DNS name on the Compose network). |
| `image:` | Which image to run. |
| `ports: "8080:80"` | Publish host 8080 → container 80 (same as `-p`). |

> No network or volume declared, yet Compose still created a default network and named everything for me. That's the convenience.

---

## Task 3 — Two-Container Setup (WordPress + MySQL)

**`docker-compose.yml`**
```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db_data:/var/lib/mysql        # named volume → data persists
    networks:
      - wp-net

  wordpress:
    image: wordpress:latest
    depends_on:
      - db
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306      # reaches MySQL by SERVICE NAME "db"
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    networks:
      - wp-net

volumes:
  db_data:

networks:
  wp-net:
```

```bash
docker compose up -d
# open http://localhost:8000  -> WordPress install screen -> set it up
```

**The persistence test:**
```bash
docker compose down        # removes containers + network (NOT the named volume)
docker compose up -d        # bring it back
# refresh http://localhost:8000  -> WordPress site is STILL THERE  ✅
```

**What happened / why:**
- **Same network automatically:** Compose put both services on `wp-net`, so WordPress reached MySQL using the service name `db` — no IPs.
- **Persistence:** the MySQL data lived in the **named volume `db_data`**. `docker compose down` removes containers and networks but **leaves named volumes**, so the site survived a full restart.
- To wipe the data too: `docker compose down -v` (the `-v` removes named volumes).

---

## Task 4 — Compose Commands

```bash
# 1. Start in detached mode
docker compose up -d

# 2. View running services
docker compose ps

# 3. Logs of ALL services
docker compose logs
docker compose logs -f          # -f = follow live

# 4. Logs of a SPECIFIC service
docker compose logs wordpress
docker compose logs -f db

# 5. Stop services WITHOUT removing them
docker compose stop            # containers stop but still exist
docker compose start           # start them again

# 6. Remove everything (containers + network)
docker compose down            # add -v to also remove named volumes

# 7. Rebuild images after a change
docker compose build           # rebuild from Dockerfiles
docker compose up -d --build   # rebuild AND start in one go
```

| Command | What it does |
|---------|-------------|
| `up -d` | Create + start all services in the background |
| `ps` | List this project's services + status + ports |
| `logs` / `logs -f` | Show / follow logs from all services |
| `logs <service>` | Logs from one service only |
| `stop` / `start` | Stop / start without removing |
| `down` | Stop **and remove** containers + networks (`-v` also volumes) |
| `build` / `up --build` | Rebuild images (for services built from a Dockerfile) |

> **`stop` vs `down`:** `stop` just pauses (containers remain); `down` tears everything down. `down -v` also deletes data.

---

## Task 5 — Environment Variables

### Inline (directly in the compose file)
```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
```

### Via a `.env` file (Compose reads it automatically)

**`.env`** (same folder as the compose file)
```
DB_ROOT_PASSWORD=rootpass
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=wppass
WP_PORT=8000
```

**`docker-compose.yml`** — reference with `${VAR}`
```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}

  wordpress:
    image: wordpress:latest
    ports:
      - "${WP_PORT}:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASSWORD}
      WORDPRESS_DB_NAME: ${DB_NAME}
```

**Verify the variables were picked up:**
```bash
docker compose config      # prints the FINAL compose file with all ${VARS} resolved
```

| Concept | The Point |
|---------|-----------|
| Inline `environment:` | Quick, but bakes config (and secrets) into the committed file |
| `.env` file | Compose auto-loads it; reference with `${VAR}` — keeps secrets out of the YAML |
| `docker compose config` | Renders the resolved file — the fastest way to confirm `.env` is working |

> Keep the `.env` file out of git (add it to `.gitignore`) so real credentials are never committed.

---

## Command Reference — Docker Compose

| Command | What It Does |
|---------|-------------|
| `docker compose version` | Confirm Compose is installed |
| `docker compose up` / `up -d` | Start all services (foreground / detached) |
| `docker compose up -d --build` | Rebuild images then start |
| `docker compose ps` | List this project's services |
| `docker compose logs -f [service]` | Follow logs (all or one service) |
| `docker compose stop` / `start` | Stop / start without removing |
| `docker compose down` | Remove containers + networks |
| `docker compose down -v` | Also remove named volumes (wipes data) |
| `docker compose config` | Print the resolved configuration |
| `docker compose exec <service> sh` | Shell into a running service |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Compose = manual commands as a file | One YAML, one `up`, one `down` — repeatable |
| Auto network | Service-name DNS works with zero setup |
| Named volumes | Survive `down`; removed only with `down -v` |
| `depends_on` | Controls start order (db before app) |
| `stop` vs `down` | Pause vs tear down (`-v` also deletes data) |
| `.env` | Config + secrets outside the YAML; `compose config` to verify |

---

*#90DaysOfDevOps 2026*
