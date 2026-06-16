# Day 32 – Docker Volumes & Networking
*#90DaysOfDevOps 2026*

---

## Task 1 — The Problem (no volume = no persistence)

```bash
# Run Postgres
docker run -d --name pg-test -e POSTGRES_PASSWORD=secret postgres:16-alpine

# Create some data
docker exec -it pg-test psql -U postgres -c "CREATE TABLE notes (id SERIAL, body TEXT);"
docker exec -it pg-test psql -U postgres -c "INSERT INTO notes (body) VALUES ('survive me');"
docker exec -it pg-test psql -U postgres -c "SELECT * FROM notes;"
# -> 1 row: survive me

# Stop and remove the container
docker stop pg-test && docker rm pg-test

# Run a brand new one
docker run -d --name pg-test -e POSTGRES_PASSWORD=secret postgres:16-alpine
docker exec -it pg-test psql -U postgres -c "SELECT * FROM notes;"
# -> ERROR: relation "notes" does not exist
```

**What happened and why:**
The table — and all its data — was **gone**. A container's writable layer is part of the container; when the container is removed, that layer is deleted with it. Containers are **ephemeral by design**. Nothing was wrong; this is exactly why volumes exist.

```bash
docker rm -f pg-test   # clean up
```

---

## Task 2 — Named Volumes (persistence)

```bash
# 1. Create a named volume
docker volume create pgdata

# 2. Run Postgres WITH the volume attached
docker run -d --name pg \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine

# 3. Add data
docker exec -it pg psql -U postgres -c "CREATE TABLE notes (id SERIAL, body TEXT);"
docker exec -it pg psql -U postgres -c "INSERT INTO notes (body) VALUES ('I should survive');"

# 4. Remove the container entirely
docker rm -f pg

# 5. Brand NEW container, SAME volume
docker run -d --name pg2 \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine
docker exec -it pg2 psql -U postgres -c "SELECT * FROM notes;"
# -> 1 row: I should survive   ✅
```

**Verify:**
```bash
docker volume ls                 # pgdata is listed
docker volume inspect pgdata     # shows Mountpoint, driver (local), creation time
```

**What happened:** the data lived in the **volume**, not the container. Destroying the container left the volume untouched, so the new container picked the data right back up. `-v pgdata:/var/lib/postgresql/data` = "store this path in the named volume `pgdata`."

```bash
docker rm -f pg2
```

---

## Task 3 — Bind Mounts

```bash
# 1. Host folder with a page
mkdir ~/site && echo "<h1>Version 1 — from my host</h1>" > ~/site/index.html

# 2. Run Nginx, BIND MOUNT the host folder into Nginx's web dir
docker run -d --name web \
  -p 8080:80 \
  -v ~/site:/usr/share/nginx/html:ro \
  nginx:alpine

# 3. Open http://localhost:8080  -> "Version 1 — from my host"

# 4. Edit the file ON THE HOST, then refresh the browser
echo "<h1>Version 2 — edited live</h1>" > ~/site/index.html
# refresh -> "Version 2 — edited live"   (no rebuild, no restart)
```
*(`:ro` mounts it read-only — the container can read the files but not change them.)*

### Answer — Named volume vs bind mount?

| | Named volume | Bind mount |
|---|-------------|-----------|
| Where data lives | A location **Docker manages** (Docker's storage area) | A **specific folder you choose** on the host |
| You reference it by | A name (`pgdata`) | A host path (`/home/me/site`) |
| Best for | **Production data** — databases, app state | **Development** — live-editing source/config |
| Portability | Portable, Docker-managed | Tied to the host's directory layout |
| Syntax | `-v pgdata:/path/in/container` | `-v /host/path:/path/in/container` |

**In one line:** a named volume is Docker-managed storage that outlives containers; a bind mount is a live window into a specific host folder.

```bash
docker rm -f web
```

---

## Task 4 — Docker Networking Basics (the default bridge)

```bash
# 1. List all networks
docker network ls
# NETWORK ID   NAME      DRIVER    SCOPE
#              bridge    bridge    local      <- default
#              host      host      local
#              none      null      local

# 2. Inspect the default bridge
docker network inspect bridge

# 3 & 4. Two containers on the DEFAULT bridge
docker run -d --name c1 alpine sleep 1000
docker run -d --name c2 alpine sleep 1000

# Ping by NAME
docker exec c1 ping -c 2 c2
# -> ping: bad address 'c2'        ❌  (name resolution fails)

# Ping by IP (find c2's IP first)
docker inspect -f '{{ .NetworkSettings.IPAddress }}' c2   # e.g. 172.17.0.3
docker exec c1 ping -c 2 172.17.0.3
# -> 64 bytes from 172.17.0.3 ...  ✅  (IP works)
```

**What happened:** on the **default** bridge, containers can reach each other by **IP** but **not by name**. The default bridge has no automatic DNS for container names.

```bash
docker rm -f c1 c2
```

---

## Task 5 — Custom Networks

```bash
# 1. Create a custom bridge network
docker network create my-app-net

# 2. Two containers ON that network
docker run -d --name c1 --network my-app-net alpine sleep 1000
docker run -d --name c2 --network my-app-net alpine sleep 1000

# 3. Ping by NAME
docker exec c1 ping -c 2 c2
# -> 64 bytes from c2.my-app-net ...   ✅  name resolution works!
```

### Answer — Why does a custom network allow name-based communication but the default bridge doesn't?

Docker runs an **embedded DNS server** for **user-defined networks**. When containers join a custom network, Docker automatically registers each container's **name** in that DNS, so `c1` can resolve `c2` to its current IP. The **default** `bridge` is legacy and deliberately does **not** provide this automatic name resolution — you'd have to use `--link` (deprecated) or raw IPs.

**Why it matters:** IPs change every time a container restarts; names don't. Name-based networking is what lets an app config say `db` instead of a brittle IP — so **always create a custom network for multi-container apps.**

```bash
docker rm -f c1 c2
```

---

## Task 6 — Put It Together (db + app on one network, with a volume)

```bash
# 1. Custom network
docker network create app-net

# 2. Database on the network, WITH a volume for persistence
docker run -d --name db \
  --network app-net \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=appdb \
  -v appdata:/var/lib/postgresql/data \
  postgres:16-alpine

# 3. App container on the SAME network (using postgres image as a psql client)
docker run -d --name app --network app-net alpine sleep 1000

# 4. Verify the app can reach the DB BY NAME
docker exec app sh -c "nc -zv db 5432"
# -> db (172.x.x.x:5432) open        ✅  reached the database by container name

# (full client check)
docker run --rm --network app-net postgres:16-alpine \
  psql "postgresql://postgres:secret@db:5432/appdb" -c "SELECT 1;"
# -> connects to host "db" by name and runs the query
```

**What happened:** the app reached the database using the name **`db`** — no IP anywhere — because both are on the custom `app-net`, and the database's data sits safely in the `appdata` volume. **This is the core pattern of every real multi-container app.**

```bash
# cleanup
docker rm -f db app
docker network rm app-net
docker volume rm appdata
```

---

## Command Reference — Volumes & Networking

| Command | What It Does |
|---------|-------------|
| `docker volume create NAME` | Create a named volume |
| `docker volume ls` / `inspect NAME` | List / inspect volumes |
| `-v name:/path` | Attach a **named volume** to a container path |
| `-v /host/path:/path` | **Bind mount** a host folder |
| `-v /host:/path:ro` | Bind mount **read-only** |
| `docker network ls` | List networks |
| `docker network create NAME` | Create a custom bridge network |
| `docker network inspect NAME` | Inspect a network (subnet, connected containers) |
| `--network NAME` | Attach a container to a network |
| `docker network connect NET CONTAINER` | Attach a running container to another network |
| `docker exec c1 ping c2` | Test connectivity between containers |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Containers are ephemeral | No volume → data dies with the container |
| Named volume | Docker-managed persistence; best for DBs/app data |
| Bind mount | Live window to a host folder; best for dev |
| Default bridge | IP works, **name does not** |
| Custom bridge | Embedded DNS → **name-based** communication |
| The pattern | Custom network + db with a volume + app reaching db by name |

---

*#90DaysOfDevOps 2026*
