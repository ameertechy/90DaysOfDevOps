# Day 14 – Networking Fundamentals and Hands-On Checks

## Overview

Day 14 is networking — the layer I work with most in production.

CCNA certified. Managing Huawei L2/L3 campus switching via Agile Controller, eSight, and iMaster NCE. Configuring VLANs, ACLs, QoS, FortiGate firewall rules, and Cloudflare DNS daily. Networking is not new territory.

What is new: running Linux networking commands systematically and mapping them precisely to the OSI model layer by layer. Today I ran every connectivity command against a live EC2 instance, documented what each output tells me, and built a reusable network check sequence I can reach for during any incident.

---

## What I Produced

- [`day-14-networking.md`](./day-14-networking.md)

---

## Commands Ran and Target

**Target:** `google.com` and `localhost` (Nginx on EC2)

| Command | Layer | Finding |
|---------|-------|---------|
| `hostname -I` / `ip addr show` | L3 Network | Private IP `172.31.x.x`, interface `ens5` |
| `ping google.com` | L3 Network | 0% packet loss, low RTT |
| `traceroute google.com` | L3 Network | Path through AWS backbone |
| `ss -tulpn` | L4 Transport | Port 22 (sshd), Port 80 (nginx) |
| `dig google.com` | L7 Application | DNS resolved correctly |
| `curl -I https://google.com` | L7 Application | HTTP 301 redirect response |
| `netstat -an \| head` | L4 Transport | ESTABLISHED SSH session visible |
| `nc -zv localhost 80` | L4 Transport | Port 80 reachable, Nginx confirmed |

---

## Key Observations

**Every command maps to a specific OSI layer — troubleshooting is top-down or bottom-up.**
If `ping` fails, the problem is at L3 or below — no point running `curl`. If `ping` works but `curl` fails, the problem is L4–L7. Understanding layers means I know which command to run next without guessing.

**`ss` replaced `netstat` — but both are still in production.**
`netstat` is deprecated on modern Linux. `ss` is faster and uses kernel APIs directly. In production environments running older OS versions, `netstat` is still present. Knowing both matters.

**`dig` vs `nslookup` — `dig` is the production tool.**
`nslookup` is interactive and harder to script. `dig` returns structured output that can be piped and parsed. `dig +short` gives just the IP — clean for scripting and automation.

**`traceroute` on EC2 shows AWS backbone hops.**
The first few hops inside AWS are the VPC routing fabric responding with very low latency. External hops show normal internet latency. This is expected on AWS — not a sign of a problem.

---

## Reflection

**Fastest signal when something is broken:** `ping` — two seconds to confirm L3 connectivity. If it fails, everything above it fails too.

**If DNS fails:** Check `/etc/resolv.conf` for nameserver config, test with `dig @8.8.8.8 domain.com` to bypass local resolver and isolate whether the issue is local config or upstream DNS.

**If HTTP 500 appears:** Stay at L7 — check application logs, confirm the app port is bound with `ss -tulpn`. A 500 means L3/L4 is healthy but the application itself failed.

---

## Real-World Tie-in

- `ping` + `traceroute` before escalating to the Huawei switch team — confirm L3 reachability first, rule out routing before touching switch configs
- `ss -tulpn` after every service deployment — confirm the service bound to the expected port
- `dig @8.8.8.8` after Cloudflare DNS updates — bypasses local cache, queries external resolver directly
- `curl -I` is the HTTP equivalent of `ping` — fast health check for any web service

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Networking` `#Linux` `#DevOps`
