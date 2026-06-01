# Networking Concepts: DNS, IP, Subnets and Ports
*#90DaysOfDevOps 2026*

---

## Task 1 — DNS: How Names Become IPs

### What happens when I type `google.com` in a browser?

1. Browser checks its own DNS cache — if found, uses it
2. OS checks its local DNS cache (`/etc/hosts` and systemd-resolve cache)
3. If not cached, query goes to the configured resolver (`127.0.0.53` on this EC2 — systemd-resolved)
4. systemd-resolved forwards to AWS's VPC DNS server (`169.254.169.253`)
5. VPC DNS queries the root nameservers → `.com` TLD nameservers → Google's authoritative nameservers
6. Answer returned with a TTL — cached at each layer for that duration
7. Browser connects to the resolved IP

The whole process takes milliseconds. The TTL (Time To Live) value controls how long each layer caches the result before asking again.

---

### DNS Record Types

| Record | Purpose | Example |
|--------|---------|---------|
| `A` | Maps hostname to IPv4 address | `google.com → 142.250.187.78` |
| `AAAA` | Maps hostname to IPv6 address | `google.com → 2607:f8b0::200e` |
| `CNAME` | Alias — points one hostname to another | `www.example.com → example.com` |
| `MX` | Mail server for the domain | `google.com → smtp.google.com` |
| `NS` | Nameservers authoritative for the domain | `google.com → ns1.google.com` |
| `TXT` | Text data — used for SPF, DKIM, domain verification | `v=spf1 include:_spf.google.com ~all` |

---

### `dig google.com` Output

```bash
dig google.com
```

```
;; ANSWER SECTION:
google.com.     300    IN  A    142.250.187.78

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53
```

**Identified:**
- **A record:** `142.250.187.78` — the IPv4 address for google.com
- **TTL:** `300` seconds — this answer is cached for 5 minutes before a fresh query is needed

---

## Task 2 — IP Addressing

### What is an IPv4 Address?

An IPv4 address is a 32-bit number written as four octets separated by dots — each octet is 0–255.

```
192  .  168  .   1  .  10
 │        │       │     │
 └────────┴───────┴─────┴── Four 8-bit octets = 32 bits total
```

**Total possible IPv4 addresses:** 2^32 = 4,294,967,296 (~4.3 billion)

IPv4 exhaustion is real — this is why IPv6 (128-bit addresses) exists and why NAT was invented to share public IPs across many private devices.

---

### Public vs Private IPs

| Type | Range | Routable on Internet? | Example |
|------|-------|----------------------|---------|
| Private | `10.0.0.0/8` | No | `10.0.1.50` |
| Private | `172.16.0.0/12` | No | `172.31.33.75` |
| Private | `192.168.0.0/16` | No | `192.168.1.1` |
| Public | Everything else | Yes | `52.32.123.205` |

**Why private IPs exist (RFC 1918):**
When the internet was designed, 4.3 billion IPs seemed like enough. As devices exploded in number, private address ranges were defined — ranges that are free to use inside any network but are never forwarded by internet routers. NAT (Network Address Translation) allows many private IPs to share one public IP.

---

### `ip addr show` on EC2

```bash
ip addr show ens5
```

```
inet 172.31.33.75/20 brd 172.31.47.255 scope global dynamic ens5
```

**`172.31.33.75`** is in the `172.16.0.0/12` private range — confirmed private. The public IP (`52.32.x.x`) lives on the AWS Internet Gateway, not on the instance interface itself.

---

## Task 3 — CIDR and Subnetting

### What does `/24` mean in `192.168.1.0/24`?

CIDR (Classless Inter-Domain Routing) notation uses a slash followed by a number to indicate how many bits of the address are the **network portion** — the rest are the **host portion**.

```
192.168.1.0/24

11000000.10101000.00000001.00000000
│────────────────────────│─────────│
        24 network bits     8 host bits
```

`/24` = 24 bits locked for network = 8 bits free for hosts = 2^8 = 256 addresses (254 usable).

---

### CIDR Reference Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts | Use Case |
|------|-------------|-----------|--------------|---------|
| `/24` | `255.255.255.0` | 256 | 254 | Standard LAN subnet |
| `/16` | `255.255.0.0` | 65,536 | 65,534 | Large network / VPC |
| `/28` | `255.255.255.240` | 16 | 14 | Small subnet — DMZ, management |
| `/20` | `255.255.240.0` | 4,096 | 4,094 | EC2 VPC subnet (my instance) |
| `/32` | `255.255.255.255` | 1 | 1 host only | Single host route |

**Usable hosts = Total IPs − 2**
Always subtract 2: one for the network address (first IP) and one for the broadcast address (last IP).

**Why do we subnet?**
- **Security:** Separate networks for different trust zones (servers, users, management, IoT)
- **Performance:** Smaller broadcast domains reduce unnecessary traffic
- **Organisation:** Logical grouping of devices by function or location
- **IP efficiency:** Allocate only the address space needed for each segment

In my university data centre, I use VLANs with dedicated subnets per segment — servers, staff, students, management, IoT devices. Each VLAN maps to a subnet. Same concept.

---

## Task 4 — Ports

### What is a Port?

A port is a 16-bit number (0–65535) that identifies a specific service or process on a host. IP gets the packet to the right machine. Port gets it to the right service on that machine.

**Without ports:** A server receiving a packet on IP `52.32.123.205` would not know whether it is SSH traffic, HTTP traffic, or database traffic — everything would go to the same process.

**With ports:** Port 22 = SSH. Port 80 = HTTP. Port 443 = HTTPS. Each service listens on its own port.

---

### Common Ports Reference

| Port | Protocol | Service | Notes |
|------|----------|---------|-------|
| 22 | TCP | SSH | Remote terminal — always secured, key auth only |
| 80 | TCP | HTTP | Unencrypted web traffic |
| 443 | TCP | HTTPS | Encrypted web traffic (TLS) |
| 53 | UDP/TCP | DNS | Name resolution — UDP for queries, TCP for large responses |
| 3306 | TCP | MySQL | Default MySQL/MariaDB port |
| 5432 | TCP | PostgreSQL | Default PostgreSQL port |
| 6379 | TCP | Redis | In-memory cache and message broker |
| 27017 | TCP | MongoDB | Default MongoDB port |
| 8080 | TCP | HTTP Alt | Common alternate HTTP port for apps and proxies |
| 2376 | TCP | Docker | Docker daemon API (TLS) |
| 6443 | TCP | Kubernetes | Kubernetes API server |

**Well-known ports:** 0–1023 — reserved for standard services, require root to bind
**Registered ports:** 1024–49151 — registered but not reserved
**Dynamic ports:** 49152–65535 — ephemeral, assigned temporarily for outbound connections

---

### `ss -tulpn` on EC2

```bash
sudo ss -tulpn
```

**Output matching ports to services:**

| Port | Process | Service |
|------|---------|---------|
| `:22` | `sshd` | SSH — my active terminal session |
| `:80` | `nginx` | HTTP — Nginx web server |
| `:53` | `systemd-resolve` | DNS — local resolver |

---

## Task 5 — Putting It Together

### `curl http://myapp.com:8080` — what networking concepts are involved?

1. **DNS (L7):** `myapp.com` is resolved to an IP address via the DNS chain
2. **IP (L3):** The resolved IP is used to route the packet across the internet to the target host
3. **Port (L4):** `:8080` tells the TCP stack to connect to port 8080 — where the application is listening
4. **TCP (L4):** A 3-way handshake establishes the connection before any HTTP data flows
5. **HTTP (L7):** The `curl` client sends an HTTP GET request and receives a response

All five concepts from today — DNS, IP, subnetting (routing uses subnet masks), ports, TCP — are active in a single `curl` command.

---

### App cannot reach database at `10.0.1.50:3306` — what to check first?

```bash
# Step 1 — Can I reach the IP at all? (L3 check)
ping -c 3 10.0.1.50
# Fail → routing or firewall issue between subnets

# Step 2 — Is the port open? (L4 check)
nc -zv 10.0.1.50 3306
# Fail → MySQL not running, or Security Group / firewall blocking 3306

# Step 3 — Is MySQL running on the target?
# SSH to 10.0.1.50 then:
systemctl status mysql
sudo ss -tulpn | grep :3306

# Step 4 — Is MySQL bound to 0.0.0.0 or only 127.0.0.1?
sudo ss -tulpn | grep 3306
# If 127.0.0.1:3306 → MySQL only accepts local connections
# Fix: edit /etc/mysql/mysql.conf.d/mysqld.cnf → bind-address = 0.0.0.0
```

---

## 3 Key Learnings

**1. DNS resolution is layered caching — TTL controls freshness.**
When I change a DNS record, it takes time to propagate because every cache layer must expire. `dig +trace` shows exactly which layer is serving the stale answer.

**2. My EC2 instance never sees its own public IP.**
The public IP lives on the AWS Internet Gateway. Inside the OS, only `172.31.x.x` is visible. This explains why `curl ifconfig.me` returns a different IP than `hostname -I`.

**3. CIDR `/20` on my VPC subnet = 4094 possible hosts.**
Understanding subnet size matters when designing VPC architecture — choose `/20` for flexibility, `/28` for tight isolation.

---

*#90DaysOfDevOps 2026*
