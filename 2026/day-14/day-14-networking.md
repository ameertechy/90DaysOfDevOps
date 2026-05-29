# Networking Fundamentals and Hands-On Checks
*#90DaysOfDevOps 2026*

---

## Part 1 — OSI vs TCP/IP Model

### OSI Model — 7 Layers

The OSI (Open Systems Interconnection) model is a conceptual framework that standardizes how network communication is broken into layers. Each layer has a specific job and only communicates with the layers directly above and below it.

| Layer | Name | What It Does | Example Protocols |
|-------|------|-------------|-------------------|
| L7 | Application | User-facing services — what apps use | HTTP, HTTPS, DNS, SSH, FTP |
| L6 | Presentation | Data formatting, encryption, compression | TLS/SSL, JPEG, ASCII |
| L5 | Session | Manages sessions between applications | NetBIOS, RPC |
| L4 | Transport | End-to-end delivery, port numbers, reliability | TCP, UDP |
| L3 | Network | IP addressing and routing between networks | IP, ICMP, ARP |
| L2 | Data Link | MAC addressing, frame delivery on local network | Ethernet, VLANs, switches |
| L1 | Physical | Cables, signals, electrical/optical transmission | Fibre, copper, Wi-Fi |

**Memory aid:** "Please Do Not Throw Sausage Pizza Away" (L1 → L7)

### TCP/IP Model — 4 Layers

The TCP/IP model is the practical implementation used on the internet. It collapses the OSI 7 layers into 4:

| TCP/IP Layer | Maps to OSI | Protocols |
|-------------|-------------|-----------|
| Application | L5, L6, L7 | HTTP, HTTPS, DNS, SSH |
| Transport | L4 | TCP, UDP |
| Internet | L3 | IP, ICMP |
| Link | L1, L2 | Ethernet, Wi-Fi |

### Where Each Protocol Sits

| Protocol | OSI Layer | TCP/IP Layer | What It Does |
|----------|-----------|--------------|--------------|
| HTTP/HTTPS | L7 | Application | Web content transfer |
| DNS | L7 | Application | Hostname to IP resolution |
| SSH | L7 | Application | Encrypted remote terminal |
| TLS/SSL | L6 | Application | Encryption layer under HTTPS |
| TCP | L4 | Transport | Reliable, ordered delivery with acknowledgements |
| UDP | L4 | Transport | Fast, unreliable delivery — no acknowledgement |
| IP | L3 | Internet | Addressing and routing between networks |
| ICMP | L3 | Internet | Network diagnostics — `ping` uses ICMP |
| Ethernet | L2 | Link | Local network frame delivery using MAC addresses |

### Real Example: What Happens When I Run `curl https://google.com`

```
curl https://google.com

L7 Application:  curl constructs an HTTP GET request
L6 Presentation: TLS handshake encrypts the request
L4 Transport:    TCP establishes a connection to port 443 (3-way handshake)
L3 Network:      IP routes the packet from EC2 to Google's server
L2 Data Link:    Ethernet frames carry it across each network segment
L1 Physical:     Electrical/optical signals on the wire
```

Response travels back up the same stack. Each layer on the receiving end strips its header and passes the payload up to the next layer.

**TCP vs UDP — when to use which:**

| | TCP | UDP |
|-|-----|-----|
| Delivery guarantee | Yes — ACKs confirm receipt | No — fire and forget |
| Order guarantee | Yes — in-sequence delivery | No |
| Speed | Slower (overhead for reliability) | Faster |
| Use cases | HTTP, SSH, databases | DNS queries, video streaming, VoIP |

**Why DNS uses UDP:** A DNS query is tiny — one question, one answer. The overhead of establishing a TCP connection (3-way handshake) would be larger than the actual DNS payload. UDP's speed matters more than reliability for a query that can simply be retried.

---

## Part 2 — Hands-On Network Checks on EC2

**Target:** `google.com` for external checks, `localhost` for local service checks.

---

### Identity — What Is My IP?

```bash
# Show all IP addresses on all interfaces
ip addr show
```

**What `ip addr show` outputs on EC2:**
```
1: lo: <LOOPBACK> ...
    inet 127.0.0.1/8   ← loopback — local only

2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 172.31.33.75/20   ← private IP inside VPC
```

**`ens5`** is the primary network interface on AWS EC2 instances. The naming comes from the predictable network interface naming scheme — `en` = Ethernet, `s5` = slot 5 (PCI slot assigned by the hypervisor).

**Why no public IP in `ip addr show`:**
The public IP (`52.32.x.x`) is not assigned to the instance interface directly. It sits on an Internet Gateway outside the instance and is translated via NAT (Network Address Translation) by AWS. Inside the OS, only the private VPC IP is visible.

```bash
# Fast: just the IP address, no extra output
hostname -I
# 172.31.33.75
```

---

### Reachability — Can I Reach the Target?

```bash
# Send 4 ICMP packets to google.com
ping -c 4 google.com
```

**`ping` breakdown:**
- `ping` = Packet INternet Groper (historical acronym)
- Uses **ICMP Echo Request** (L3) — no TCP/UDP ports involved
- `-c 4` = send exactly 4 packets then stop. Without `-c`, ping runs forever

**Reading ping output:**
```
PING google.com (142.250.187.78): 56 data bytes
64 bytes from 142.250.187.78: icmp_seq=1 ttl=116 time=1.2 ms
64 bytes from 142.250.187.78: icmp_seq=2 ttl=116 time=1.1 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 1.1/1.2/1.3/0.1 ms
```

| Field | Meaning |
|-------|---------|
| `ttl=116` | Time To Live — how many router hops remain before packet is discarded |
| `time=1.2 ms` | Round-trip time — packet to Google and back |
| `0% packet loss` | All packets received — L3 connectivity confirmed |
| `rtt avg` | Average latency — baseline for comparison |

**What ping does NOT tell you:** Whether TCP ports are open, whether a service is running, or whether HTTP works. It only confirms L3 IP reachability.

---

### Path — How Does Traffic Get There?

```bash
# Trace the route to google.com
traceroute google.com
```

**What `traceroute` does:**
Sends packets with increasing TTL values starting at 1. Each router that forwards the packet decrements TTL by 1. When TTL reaches 0, the router discards the packet and sends back an ICMP Time Exceeded message — revealing its IP and latency. Traceroute collects these responses hop by hop to map the path.

**Reading traceroute output on EC2:**
```
traceroute to google.com (142.250.187.78)
 1  *  *  *              ← AWS VPC router — does not respond to ICMP
 2  *  *  *              ← AWS backbone — ICMP filtered
 3  52.93.x.x  0.5ms    ← AWS Transit Gateway
 4  74.125.x.x  1.1ms   ← Google's network
...
```

**Why `* * *` appears:** Some routers are configured to drop ICMP TTL Exceeded messages — either for security or performance. This is normal on AWS backbone routers. It does not mean the path is broken — the next hop still responds.

```bash
# Alternative — tracepath (no sudo required, simpler output)
tracepath google.com
```

---

### Ports — What Is Listening?

```bash
sudo ss -tulpn
```

**Expected output on EC2:**
```
Netid  State   Recv-Q  Send-Q  Local Address:Port  Process
tcp    LISTEN  0       128     0.0.0.0:22           sshd
tcp    LISTEN  0       511     0.0.0.0:80           nginx
tcp    LISTEN  0       4096    127.0.0.53:53        systemd-resolve
```

**Port reference:**

| Port | Protocol | Service |
|------|----------|---------|
| 22 | TCP | SSH — remote terminal access |
| 80 | TCP | HTTP — web traffic |
| 443 | TCP | HTTPS — encrypted web traffic |
| 53 | UDP/TCP | DNS — name resolution |
| 3306 | TCP | MySQL database |
| 5432 | TCP | PostgreSQL database |
| 6443 | TCP | Kubernetes API server |

**`0.0.0.0:22`** = listening on all interfaces — accepts connections from any IP.
**`127.0.0.53:53`** = listening only on loopback — `systemd-resolved` handles local DNS, not exposed externally.

---

### Name Resolution — Does DNS Work?

```bash
# Query DNS for google.com
dig google.com
```

**Reading `dig` output:**
```
;; ANSWER SECTION:
google.com.     300    IN  A    142.250.187.78

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53    ← which DNS server answered
;; MSG SIZE  rcvd: 55
```

| Field | Meaning |
|-------|---------|
| `A` | Record type — A record maps hostname to IPv4 |
| `300` | TTL in seconds — how long this answer can be cached |
| `127.0.0.53` | Answered by local systemd-resolved |

```bash
# Quick — just the IP
dig google.com +short
# 142.250.187.78

# Bypass local DNS — query Google's public resolver directly
dig @8.8.8.8 google.com +short
# Same IP — confirms external DNS also resolves correctly

# Check DNS resolver config
cat /etc/resolv.conf
# nameserver 127.0.0.53  ← points to systemd-resolved
```

---

### HTTP Check — Is the Service Responding?

```bash
# Check HTTP headers only — do not download the full page
curl -I https://google.com
```

**`curl -I` breakdown:**
- `curl` = Client URL — transfers data from/to a server
- `-I` = **HEAD request** — fetches only headers, not the body. Fast health check.

**Reading curl output:**
```
HTTP/2 301
location: https://www.google.com/
content-type: text/html; charset=UTF-8
```

**HTTP status codes:**

| Code | Meaning |
|------|---------|
| `200 OK` | Success — content returned |
| `301 Moved Permanently` | Redirected — new URL in `location` header |
| `302 Found` | Temporary redirect |
| `400 Bad Request` | Client sent malformed request |
| `401 Unauthorized` | Authentication required |
| `403 Forbidden` | Access denied |
| `404 Not Found` | Resource does not exist |
| `500 Internal Server Error` | Application-level failure |
| `502 Bad Gateway` | Upstream service (app server) not responding |
| `503 Service Unavailable` | Service overloaded or down |

```bash
# Check local Nginx
curl -I http://localhost
# HTTP/1.1 200 OK  ← Nginx serving correctly
```

---

### Connections Snapshot

```bash
# All active connections — first 20 lines
netstat -an | head -20
```

**`netstat` breakdown:**
- `netstat` = network statistics
- `-a` = show all sockets (listening + established)
- `-n` = numeric output — show IP addresses and ports as numbers, not names

```bash
# Count ESTABLISHED connections
netstat -an | grep ESTABLISHED | wc -l

# Count LISTEN sockets
netstat -an | grep LISTEN | wc -l
```

**Connection states:**

| State | Meaning |
|-------|---------|
| `LISTEN` | Socket waiting for incoming connections |
| `ESTABLISHED` | Active connection — data flowing |
| `TIME_WAIT` | Connection closed, waiting to ensure last ACK was received |
| `CLOSE_WAIT` | Remote end closed — local end still open |

---

### Port Probe — Is the Port Actually Reachable?

```bash
# Test if port 80 is reachable on localhost
nc -zv localhost 80
```

**`nc` breakdown:**
- `nc` = **netcat** — the Swiss Army knife of networking
- `-z` = **zero I/O mode** — just test connectivity, do not send data
- `-v` = **verbose** — show result explicitly

**Expected output:**
```
Connection to localhost (127.0.0.1) 80 port [tcp/http] succeeded!
```

If this fails but Nginx is running — the firewall (Security Group or UFW) is blocking the port, not the service itself.

```bash
# Test SSH port
nc -zv localhost 22
# Connection to localhost 22 port [tcp/ssh] succeeded!

# Test a closed port
nc -zv localhost 8080
# nc: connect to localhost port 8080 (tcp) failed: Connection refused
# "Connection refused" = port not open, nothing listening there
```

---

## Network Troubleshooting Decision Tree

```
Something is broken
        │
        ▼
Is ping working? ──── No ──► L3 problem
        │                    Check: ip addr, ip route, Security Group
        │ Yes
        ▼
Is DNS resolving? ─── No ──► L7 DNS problem
        │                    Check: /etc/resolv.conf, dig @8.8.8.8
        │ Yes
        ▼
Is port open? ──────── No ──► L4 problem
        │                    Check: ss -tulpn, Security Group, UFW
        │ Yes
        ▼
Is HTTP responding? ── No ──► L7 Application problem
        │                    Check: journalctl -u nginx, nginx -t
        │ Yes
        ▼
System is healthy ✅
```

---

*#90DaysOfDevOps 2026*
