# Day 06 – Linux Fundamentals: Read and Write Text Files

## Overview

Day 6 is deliberately simple — and that is the point.

In DevOps, the ability to read, write, and manipulate text files quickly is not optional. Every log file, every config, every deployment script, every environment variable file is a text file. Before automating anything, I need to handle files with precision using only the terminal.

Today I practiced the complete file I/O workflow: create, write, append, read full, read partial, and write-and-display simultaneously using `tee`.

---

## What I Produced

- [`file-io-practice.md`](./file-io-practice.md)

---

## Key Observations

**`touch` does not just create files — it also updates timestamps.**
Running `touch` on an existing file does not change its content. It updates the `atime` (access time) and `mtime` (modification time). This is useful in scripting when a process checks whether a file was recently accessed.

**`>` and `>>` are not the same — and confusing them in production destroys data.**
`>` overwrites the entire file. `>>` appends. I practiced both deliberately. In production, log redirection scripts that accidentally use `>` instead of `>>` will silently wipe historical log data. This distinction is critical.

**`tee` is the bridge between display and file writing.**
`echo "text" | tee file.txt` writes to the file AND displays on screen simultaneously. Without `tee`, I have to choose one or the other. With `tee -a`, it appends instead of overwriting. Used extensively in deployment scripts where you want both terminal output and a log file simultaneously.

**`head` and `tail` are production tools, not just file readers.**
`tail -f` is real-time log streaming — the same command I use when monitoring Nginx access logs or Docker container output during a deployment. `head -n 1` is how you extract a file's header line in a script without reading the entire file into memory.

---

## Real-World Tie-in

- Every Nginx config edit starts with `cat /etc/nginx/nginx.conf` to read current state before touching anything
- `tail -f /var/log/nginx/access.log` is my live monitoring command during any web service change
- `tee` is used in CI/CD pipelines to write build logs to a file while also streaming to console
- `echo "key=value" >> /etc/environment` is how environment variables are appended to system config — one wrong `>` and the entire file is gone

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
