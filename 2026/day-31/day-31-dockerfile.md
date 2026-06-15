# Day 31 – Dockerfile: Build Your Own Images
*#90DaysOfDevOps 2026*

---

## Task 1 — My First Dockerfile

```bash
mkdir my-first-image && cd my-first-image
```

**`Dockerfile`**
```dockerfile
# Base image to build on top of
FROM ubuntu

# Install curl during the build
RUN apt-get update && apt-get install -y curl

# Default command when a container starts
CMD ["echo", "Hello from my custom image!"]
```

```bash
# Build and tag the image
docker build -t my-ubuntu:v1 .

# Run a container from it
docker run my-ubuntu:v1
# -> Hello from my custom image!
```

**What happened:**
- `docker build` read the Dockerfile top-to-bottom, creating a layer per instruction.
- `-t my-ubuntu:v1` named the image `my-ubuntu` with tag `v1`.
- The `.` is the **build context** — the folder Docker sends to the daemon and looks in for files.
- On `docker run`, the `CMD` executed and printed the message. ✅

---

## Task 2 — All the Core Instructions

**`Dockerfile`**
```dockerfile
# FROM — the base image every build starts from
FROM ubuntu

# RUN — execute a command at BUILD time (creates a layer)
RUN apt-get update && apt-get install -y curl

# WORKDIR — set the working directory for everything that follows
WORKDIR /app

# COPY — copy files from the host (build context) into the image
COPY index.html .

# EXPOSE — document the port the app uses (informational)
EXPOSE 80

# CMD — the default command at RUN time
CMD ["cat", "index.html"]
```

```bash
echo "<h1>Day 31</h1>" > index.html
docker build -t instructions-demo:v1 .
docker run instructions-demo:v1
# -> <h1>Day 31</h1>
```

### What each instruction does

| Instruction | When it runs | What it does |
|-------------|-------------|--------------|
| `FROM` | build | Sets the base image (the first layer) |
| `RUN` | build | Executes a command and saves the result as a layer |
| `WORKDIR` | build | Sets the current directory for later instructions (creates it if needed) |
| `COPY` | build | Copies files from the build context into the image |
| `EXPOSE` | metadata | Documents a port (does **not** publish it — you still need `-p`) |
| `CMD` | run | The default command when a container starts |

> **RUN vs CMD:** `RUN` happens while **building** the image. `CMD` happens when you **run** a container from it.

---

## Task 3 — CMD vs ENTRYPOINT

### With `CMD`
```dockerfile
FROM ubuntu
CMD ["echo", "hello"]
```
```bash
docker build -t cmd-demo .
docker run cmd-demo                 # -> hello              (uses the default)
docker run cmd-demo echo goodbye    # -> goodbye           (CMD is REPLACED)
```

### With `ENTRYPOINT`
```dockerfile
FROM ubuntu
ENTRYPOINT ["echo"]
```
```bash
docker build -t entry-demo .
docker run entry-demo               # -> (prints empty line)
docker run entry-demo hello         # -> hello             (becomes an ARGUMENT to echo)
docker run entry-demo hi there      # -> hi there
```

### Answer — When to use CMD vs ENTRYPOINT?

| | `CMD` | `ENTRYPOINT` |
|---|-------|--------------|
| Role | Default command | Fixed command that always runs |
| Extra args at `docker run` | **Replace** the whole CMD | Become **arguments** to the ENTRYPOINT |
| Use when | You want a sensible default the user can override | The image is built to *always* do one thing (e.g. a CLI tool) |

- **Use `CMD`** when the container has a default behaviour but the user might want to run something else (e.g. a base image where you sometimes drop into `bash`).
- **Use `ENTRYPOINT`** when the image *is* a command — like a tool that should always run, with the user only supplying arguments.
- **Common combo:** `ENTRYPOINT` sets the executable, `CMD` supplies default arguments:
  ```dockerfile
  ENTRYPOINT ["echo"]
  CMD ["hello"]          # default arg, overridable
  ```

---

## Task 4 — Build a Simple Web App Image

**`index.html`**
```html
<!doctype html>
<html>
  <head><title>Day 31</title></head>
  <body style="font-family:sans-serif;background:#0d1117;color:#fff;text-align:center;padding-top:80px">
    <h1>🐳 My first custom Nginx image</h1>
    <p>Built with a Dockerfile on Day 31 of #90DaysOfDevOps</p>
  </body>
</html>
```

**`Dockerfile`**
```dockerfile
# Lightweight Nginx base
FROM nginx:alpine

# Copy my page into the directory Nginx serves from
COPY index.html /usr/share/nginx/html/index.html

# Document the port Nginx listens on
EXPOSE 80
```

```bash
docker build -t my-website:v1 .
docker run -d -p 8080:80 --name site my-website:v1
# open http://localhost:8080  -> my custom page
```

**What happened:**
- No `CMD` needed — the `nginx:alpine` base already starts Nginx.
- `COPY` replaced Nginx's default page with mine.
- `-p 8080:80` mapped host 8080 → container 80, so the page loaded in the browser. ✅

---

## Task 5 — .dockerignore

**`.dockerignore`**
```
node_modules
.git
*.md
.env
```

```bash
docker build -t ignore-demo .
```

**What happened:**
- `.dockerignore` works like `.gitignore`, but for the **build context**.
- Listed paths are never sent to the daemon, so `COPY . .` can't pull them into the image.
- Result: smaller images, faster builds, and — importantly — `.env` and secrets stay out of the image.

> Without it, a careless `COPY . .` can bloat the image with `node_modules` and leak credentials baked into a layer.

---

## Task 6 — Build Optimization (Layer Cache)

```bash
# Build once
docker build -t cache-demo .

# Change ONE line in a file, rebuild
docker build -t cache-demo .
# -> Docker reuses cached layers for everything BEFORE the change,
#    and only rebuilds from the changed layer onward ("Using cache" lines)
```

### Answer — Why does layer order matter for build speed?

Docker builds layers **top to bottom** and caches each one. When a layer changes, **that layer and every layer after it** are rebuilt — the cache is invalidated downward.

So put the lines that change **least often** at the **top**, and the ones that change **most often** at the **bottom**.

**Bad order** (re-installs deps on every code change):
```dockerfile
FROM node:20
WORKDIR /app
COPY . .                # any code edit invalidates everything below
RUN npm install         # so this re-runs every single time
CMD ["node", "app.js"]
```

**Good order** (deps cached until they actually change):
```dockerfile
FROM node:20
WORKDIR /app
COPY package.json package-lock.json ./   # changes rarely
RUN npm install                          # cached unless package.json changes
COPY . .                                 # code changes often → placed last
CMD ["node", "app.js"]
```

Now editing code skips the slow `npm install` entirely. **Order = build speed.**

---

## Command Reference — Building Images

| Command | What It Does |
|---------|-------------|
| `docker build -t name:tag .` | Build an image from the Dockerfile in `.` (the build context) |
| `docker build -f File -t name .` | Use a specific Dockerfile (`-f`) |
| `docker images` | List local images |
| `docker run name:tag` | Run a container from your image |
| `docker run -d -p H:C name` | Detached + map host port H → container port C |
| `docker history name:tag` | Show the layers your image is built from |
| `docker rmi name:tag` | Remove an image |

---

## Instruction Cheat-Sheet

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image (always first) |
| `RUN` | Run a command at **build** time → new layer |
| `COPY` | Copy files host → image |
| `ADD` | Like COPY, also handles URLs / auto-extracts tar (prefer COPY) |
| `WORKDIR` | Set working directory |
| `EXPOSE` | Document a port (doesn't publish it) |
| `ENV` | Set an environment variable |
| `CMD` | Default command at **run** time (overridable) |
| `ENTRYPOINT` | Fixed command at **run** time (args appended) |

---

## Key Takeaways

| Concept | The Point |
|---------|-----------|
| Dockerfile = ordered instructions | Each line becomes a cached layer |
| `RUN` vs `CMD` | Build time vs run time |
| `CMD` vs `ENTRYPOINT` | Overridable default vs fixed command |
| `EXPOSE` ≠ publish | Documentation only; still need `-p` |
| `.dockerignore` | Keeps junk + secrets out of the build |
| Layer order | Least-changing first → faster rebuilds |

---

*#90DaysOfDevOps 2026*
