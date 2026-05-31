# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## Task 1: DNS – How Names Become IPs

### What happens when you type google.com in a browser?
When we type `google.com` in a browser, the system queries DNS servers to find the IP address associated with the domain name. Once the IP address is returned, the browser connects to the web server using that IP and loads the website.

### DNS Record Types

| Record | Purpose |
|----------|----------|
| A | Maps domain to IPv4 address |
| AAAA | Maps domain to IPv6 address |
| CNAME | Alias for another domain |
| MX | Mail server record |
| NS | Nameserver record |

### dig google.com
Example:

```bash
dig google.com
```

Document the A record and TTL from your own system output.

---

## Task 2: IP Addressing

### What is an IPv4 address?
An IPv4 address is a 32-bit numerical address used to identify devices on a network.

Example:

```text
192.168.1.10
```

### Public vs Private IP

Public IP Example:

```text
8.8.8.8
```

Private IP Example:

```text
192.168.1.10
```

### Private IP Ranges

```text
10.0.0.0/8
172.16.0.0 - 172.31.255.255
192.168.0.0/16
```

### Command

```bash
ip addr show
```

Identify which IP addresses on your EC2 instance are private.

---

## Task 3: CIDR & Subnetting

### What does /24 mean?
24 bits are used for the network portion and 8 bits remain for hosts.

### Why do we subnet?

- Better organization
- Improved security
- Reduced broadcast traffic
- Efficient IP utilization

### CIDR Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|------|-------------|-----------|--------------|
| /24 | 255.255.255.0 | 256 | 254 |
| /16 | 255.255.0.0 | 65,536 | 65,534 |
| /28 | 255.255.255.240 | 16 | 14 |

---

## Task 4: Ports – The Doors to Services

### What is a Port?
A port is a logical communication endpoint that allows multiple services to run on the same system and communicate over the network.

### Common Ports

| Port | Service |
|------|----------|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 53 | DNS |
| 3306 | MySQL |
| 6379 | Redis |
| 27017 | MongoDB |

### Command

```bash
ss -tulpn
```

Match at least two listening ports to their services from your system output.

---

## Task 5: Putting It Together

### curl http://myapp.com:8080

This involves:
- DNS resolution
- IP connectivity
- TCP communication
- Port 8080 service access

### App cannot reach database at 10.0.1.50:3306

Check:
- Network connectivity
- Security groups/firewall rules
- Database service status
- Listening ports
- Routing configuration

---

## What I Learned

1. DNS translates domain names into IP addresses.
2. CIDR determines network and host allocation.
3. Ports allow multiple services to communicate on the same server.
