# Day 39 – What is CI/CD?
*#90DaysOfDevOps 2026*

A concepts day — no pipelines yet. Get the *why* straight before writing the *how* (that's tomorrow). After a week of Docker and a day of YAML, this is the bridge into automation.

---

## Task 1 — The Problem

Picture 5 developers all pushing to one repo and **manually** deploying to production.

1. **What can go wrong?** Plenty: two people deploy conflicting changes, someone forgets a step in the deploy, an untested commit goes straight to prod, the deploy works on the dev's setup but not the server, and there's no record of *who* deployed *what* *when*. Every manual step is a place a human can slip.
2. **"It works on my machine" — why is it a real problem?** The code ran fine against the developer's exact environment (their OS, their installed versions, their config) but the server's environment is different. The code didn't change — the *environment* did. (This is the exact problem containers solve, which is why Docker came first in this challenge.)
3. **How often can a team safely deploy manually?** Realistically a few times a day at most, and nervously — each deploy is slow, risky, and needs a careful human. Automated pipelines let teams deploy dozens or hundreds of times a day with confidence.

---

## Task 2 — CI vs CD vs CD

**Continuous Integration (CI)** — developers merge their code into the shared branch frequently (several times a day). Every merge automatically triggers a **build + tests**, so integration problems are caught within minutes instead of at the end of a release.
> Example: every push to DevBoard runs the Go backend tests and the frontend build. If a change breaks the build, I know before it ever reaches anyone else.

**Continuous Delivery (CD)** — extends CI so that every change that passes the tests is automatically packaged and made **ready to release**. The final push to production is still a **manual button press** — a human decides *when* to ship.
> Example: a passing DevBoard build produces a Docker image that's ready to deploy; a person clicks "deploy to production" when they're ready.

**Continuous Deployment (CD)** — goes one step further: every change that passes all the checks is **automatically deployed to production**, no human gate. Used by teams with strong test coverage and confidence in their pipeline.
> Example: merge to `main`, tests pass, and the new version is live in minutes with nobody pressing a button.

**The one-line difference:** CI = *integrate + test automatically*; Delivery = *always ready to ship (manual release)*; Deployment = *ships automatically*.

---

## Task 3 — Pipeline Anatomy

| Part | What it does |
|------|-------------|
| **Trigger** | The event that starts the pipeline — e.g. a `push`, a pull request, or a schedule |
| **Stage** | A logical phase of the pipeline — e.g. build, test, deploy |
| **Job** | A unit of work inside the pipeline that runs on one runner (it can have many steps) |
| **Step** | A single command or action inside a job — e.g. "check out the code", "run the tests" |
| **Runner** | The machine that actually executes a job (GitHub provides `ubuntu-latest`, or you bring your own) |
| **Artifact** | An output a job produces and hands on — e.g. a built binary, a Docker image, a test report |

---

## Task 4 — A Pipeline Diagram

Scenario: a developer pushes to GitHub → the app is tested, built into a Docker image, and deployed to staging.

```
   ┌──────────────┐
   │  git push    │  ← TRIGGER (push to GitHub)
   └──────┬───────┘
          ▼
   ┌──────────────┐
   │  STAGE 1     │   run the test suite
   │   TEST       │   (fail here = pipeline stops, nothing ships)
   └──────┬───────┘
          ▼ tests pass
   ┌──────────────┐
   │  STAGE 2     │   docker build -t app:sha .
   │   BUILD      │   → ARTIFACT: a Docker image
   └──────┬───────┘
          ▼ image built
   ┌──────────────┐
   │  STAGE 3     │   deploy the image to the
   │   DEPLOY     │   staging server
   └──────┬───────┘
          ▼
      🟢 staging is live
```

*(A hand-drawn version of this is in `screenshots/`.)*

The key idea: each stage only runs if the one before it **passed**. A failure stops the line — broken code never reaches staging.

---

## Task 5 — Explore in the Wild

I opened **Vite** (`vitejs/vite`) on GitHub — a tool I've actually used (DevBoard's frontend is a Vite + React app) — and looked at its `.github/workflows/` folder.

Opening one workflow file, my reading:
- **What triggers it?** `push` and `pull_request` on the main branches — so it runs on every change and every PR.
- **How many jobs?** Several — separate jobs for linting, type-checking, and running the test suite, plus a matrix that runs the tests across multiple Node versions and operating systems.
- **What does it do (best guess)?** It's the project's CI: on every push/PR it checks out the code, installs dependencies, lints, and runs the full test suite across environments — so a contribution can't be merged unless it passes everywhere. Exactly the "catch problems within minutes" idea from Task 1, running on a real open-source project.

Seeing it in the wild made it click: a workflow file is just YAML (yesterday's lesson) describing triggers, jobs, and steps (today's lesson).

---

## 3 Key Things I Learned

1. **CI/CD is a practice, not a tool.** GitHub Actions is the *tool* I'll use to implement it, but the practice is "integrate small changes often, test automatically, and make releasing boring."
2. **A failing pipeline is a success.** It caught a problem before a human did — that's the whole point, not something to dread.
3. **The anatomy maps straight onto what's next.** Trigger → job → step → runner are the exact words I'll be writing in a workflow file tomorrow. The concepts aren't abstract; they're the keys in the YAML.

---

*#90DaysOfDevOps 2026*
