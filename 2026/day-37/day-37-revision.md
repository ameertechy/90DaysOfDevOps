# Day 37 – Docker Revision (Self-Check Answers)
*#90DaysOfDevOps 2026 — consolidating Days 29–36*

A self-run exam: marked the checklist honestly, answered the quick-fire questions **from memory first**, then verified against my own Day 29–36 notes, and redid the two topics I was shaky on.

---

## Self-Assessment Checklist

Honest marks — ✅ can do · 🟡 shaky · ⬜ haven't done.

| Skill | Mark | Note to self |
|-------|:----:|--------------|
| Run a container from Docker Hub (interactive + detached) | ✅ | `-it` for a shell, `-d` for background — Day 29 |
| List, stop, remove containers and images | ✅ | `ps -a`, `stop`, `rm`, `rmi` — stopped ≠ removed |
| Explain image layers and how caching works | ✅ | One layer per instruction; cache invalidates downward |
| Write a Dockerfile from scratch (FROM, RUN, COPY, WORKDIR, CMD) | ✅ | Did it cold on Day 31 |
| Explain CMD vs ENTRYPOINT | 🟡 | **Weak spot #1** — redone below |
| Build and tag a custom image | ✅ | `docker build -t name:tag .` |
| Create and use named volumes | ✅ | `-v pgdata:/var/lib/postgresql/data` — Day 32 |
| Use bind mounts | ✅ | `-v /host:/path:ro` for live dev |
| Create custom networks and connect containers | ✅ | Custom net → name-based DNS |
| Write a docker-compose.yml for a multi-container app | ✅ | Days 33–34, 3-service stack |
| Use environment variables and .env files in Compose | ✅ | `${VAR}` substitution from `.env` |
| Write a multi-stage Dockerfile | ✅ | ~1.27GB → ~15MB on Day 35 |
| Push an image to Docker Hub | ✅ | `login → tag → push` — Day 35 |
| Use healthchecks and depends_on | 🟡 | **Weak spot #2** — redone below |

**Verdict:** the core is solid. Two genuinely subtle items left fuzzy — both redone in the *Revisit Weak Spots* section.

---

## Quick-Fire Answers (from memory, then verified)

**1. Difference between an image and a container?**
An image is a read-only **blueprint** (app + dependencies + instructions); a container is a **running instance** of that image. Image = class, container = object. One image → many containers.

**2. What happens to data inside a container when you remove it?**
It's **gone**. A container's writable layer is part of the container, so `docker rm` deletes it with the container. Containers are ephemeral by design — that's exactly why **volumes** exist (data lives in the volume, outlives the container).

**3. How do two containers on the same custom network communicate?**
**By container name.** Docker runs an embedded DNS server for user-defined networks and auto-registers each container's name, so `app` can reach `db` by name. (The legacy default `bridge` does *not* do this — there you'd need raw IPs.)

**4. How is `docker compose down -v` different from `docker compose down`?**
`down` stops and removes containers + networks but **keeps named volumes** (data survives). `down -v` does all that **and removes the named volumes** too — so it wipes the data. Use `-v` only when you genuinely want a clean slate.

**5. Why are multi-stage builds useful?**
They let you **ship the artifact, not the toolchain**. A `builder` stage compiles the app; the final stage starts from a tiny base and uses `COPY --from=builder` to bring across only the built binary/bundle. Result: dramatically smaller images, faster pulls, smaller attack surface (my Go demo went ~1.27GB → ~15MB).

**6. Difference between `COPY` and `ADD`?**
Both copy files from the build context into the image. `ADD` *also* can fetch remote URLs and auto-extract local tar archives. That extra magic makes builds less predictable, so the guidance is **prefer `COPY`** and only use `ADD` when you specifically need tar auto-extraction.

**7. What does `-p 8080:80` mean?**
**Publish** a port: map **host 8080 → container 80** (`host:container`). Traffic hitting `localhost:8080` is forwarded into the container's port 80. Note `EXPOSE` only *documents* a port — you still need `-p` to actually publish it.

**8. How do you check how much disk space Docker is using?**
`docker system df` — it breaks down disk usage across images, containers, local volumes, and build cache (and shows what's reclaimable). Follow up with `docker system prune` to reclaim it.

*All eight checked out against my Day 29–36 notes. ✅*

---

## Revisit Weak Spots

### Weak spot #1 — CMD vs ENTRYPOINT (redone)

```dockerfile
# CMD = default, overridable
FROM ubuntu
CMD ["echo", "hello"]
```
```bash
docker run cmd-demo               # -> hello            (uses the default)
docker run cmd-demo echo goodbye  # -> goodbye          (extra args REPLACE the CMD)
```

```dockerfile
# ENTRYPOINT = fixed command
FROM ubuntu
ENTRYPOINT ["echo"]
```
```bash
docker run entry-demo hello       # -> hello            (extra args are ARGUMENTS to echo)
docker run entry-demo hi there    # -> hi there
```

**What finally stuck:**
- `CMD` → a sensible **default** the user can swap out entirely at `docker run`.
- `ENTRYPOINT` → the image **is** that command; run-time args get appended as its arguments.
- **Common combo** — `ENTRYPOINT` sets the executable, `CMD` supplies overridable default args:
  ```dockerfile
  ENTRYPOINT ["echo"]
  CMD ["hello"]      # default arg; `docker run img world` -> world
  ```

### Weak spot #2 — restart / healthcheck / depends_on (redone)

**`restart: always` does NOT restart a manual stop** — this was the real surprise on Day 34, so I re-tested it:

```bash
# Manual stop/kill = INTENTIONAL → policy stands down, RestartCount stays 0
docker run -d --restart always --name r1 nginx
docker kill r1
docker inspect r1 --format '{{.RestartCount}}'   # 0

# A real crash (process exits on its own) → policy DOES restart it
docker run -d --restart always --name crashloop alpine sh -c "sleep 3; exit 1"
docker inspect crashloop --format '{{.RestartCount}}'   # climbs
docker rm -f crashloop r1
```

| Policy | Fires on |
|--------|----------|
| `no` (default) | never |
| `on-failure[:N]` | non-zero exit (crash); optional retry cap |
| `always` | unexpected exit / OOM / daemon-host reboot — **not** a manual `stop`/`kill` |
| `unless-stopped` | like `always`, but stays down if **I** stopped it |

**healthcheck + `depends_on` — wait for READY, not just STARTED:**

```yaml
db:
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
    interval: 5s
    timeout: 3s
    retries: 5
web:
  depends_on:
    db:
      condition: service_healthy   # wait for the healthcheck to PASS
```

- Plain `depends_on: [db]` only guarantees the DB **container started** — not that Postgres is accepting connections.
- `condition: service_healthy` waits for the **healthcheck to pass** → fixes the classic "app crashes on boot because the DB isn't up yet" race.

---

## One-Line Recap

| Topic | The point that sticks |
|-------|-----------------------|
| Image vs container | Blueprint vs running instance |
| Data on `rm` | Gone — that's why volumes exist |
| Custom network | Name-based DNS between containers |
| `down -v` | Also deletes named volumes (data) |
| Multi-stage | Ship the artifact, not the toolchain |
| COPY vs ADD | Prefer COPY; ADD adds URL/tar magic |
| `-p host:container` | Publish a port; EXPOSE only documents |
| `docker system df` | See Docker's disk usage |
| CMD vs ENTRYPOINT | Overridable default vs fixed command |
| `restart: always` | Self-heals crashes, ignores manual stops |

---

*#90DaysOfDevOps 2026 — TrainWithShubham*
