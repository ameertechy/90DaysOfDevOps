# Day 32 – Docker Volumes & Networking

## Overview

Day 32 tackles the two problems that turn "I ran a container" into "I ran a real system": **data that survives** and **containers that can talk to each other**. By default Docker gives you neither — a container is ephemeral (delete it and its data is gone), and containers can't reliably find each other. Today fixes both.

I'd met volumes and networking in the weekend live session, so today was about proving each one to myself with my own hands instead of taking it on faith. And the best part: I deliberately destroyed a database to *watch* the data vanish, then did it again with a volume attached and watched it survive. That "aha" is real — you don't truly believe persistence until you've lost data once.

I worked through six things: the ephemerality problem first-hand, **named volumes**, **bind mounts**, **default vs custom networks**, why name-based communication only works on custom networks, and finally wiring a database + app container together on one network with a volume — the exact pattern behind any real multi-container app.

---

## What I Produced

- [`day-32-volumes-networking.md`](./day-32-volumes-networking.md) — every experiment, the commands, and the answers to each task
- Screenshots of the data-loss "aha", the volume surviving, and the ping tests in [`screenshots/`](./screenshots/)

---

## Tasks Completed

| Task | What I Did |
|------|-----------|
| 1 | Ran Postgres, added data, removed the container — **data gone**. Saw the problem first-hand |
| 2 | Attached a **named volume**, repeated it — data **survived** a full container removal |
| 3 | **Bind-mounted** a host folder into Nginx; edited the file on the host and saw it live in the browser |
| 4 | Listed/inspected networks; tested ping by **name** vs **IP** on the default bridge |
| 5 | Created a **custom bridge**; confirmed containers ping each other **by name** there |
| 6 | Put it together — db (with volume) + app container on one network, app reached db **by name** |

---

## Key Observations

**A container without a volume is a whiteboard — wipe it and the data's gone.**
Removing the database container without a volume deleted everything inside it. That's not a bug; it's the model. Containers are meant to be disposable. The fix isn't "be careful" — it's "put the data somewhere that outlives the container."

**Named volume vs bind mount: Docker-managed storage vs a window to a host folder.**
A **named volume** is managed by Docker (lives under Docker's area, survives container removal) — best for databases and app data. A **bind mount** maps a specific host folder into the container — best for development, because editing a file on the host instantly shows up inside the container. I saw it live: edit `index.html`, refresh, done.

**The default bridge doesn't do name resolution — custom networks do.**
On the default `bridge`, two containers could reach each other by **IP** but not by **name**. The moment I put them on a **custom** bridge, name-based ping worked. Custom networks give you an embedded DNS that resolves container names; the default bridge doesn't. This is *the* reason real apps always use custom networks.

**Name-based networking is what makes multi-container apps maintainable.**
Hardcoding container IPs is fragile — they change. Reaching a database as `db` instead of `172.18.0.3` means the app config never has to know the IP. That single fact is why every Compose file and Kubernetes service relies on names.

---

## Real-World Tie-in

- **This is exactly the pattern in any production stack** — a database with a volume so data persists, an app on the same network reaching it by name. It's the spine of the three-tier app I built for practice, and of every real deployment.
- **Volumes are how stateful services live in containers** — databases, file stores, anything that must not lose data. Without them, containers would be useless for anything that remembers something.
- **Bind mounts are a developer's best friend** — mount your source code in and edit live without rebuilding the image; that tight loop is how people actually develop in containers.
- **Datacenter parallel** — running campus infrastructure, persistent storage and network segmentation are daily concerns. Volumes are the container version of "where does the data actually live," and custom networks are the container version of putting the right systems on the right segment so they can talk.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Docker` `#Networking` `#DevOps`
