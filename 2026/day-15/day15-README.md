# Day 15 – Networking Concepts: DNS, IP, Subnets and Ports

## Overview

Day 15 builds on the hands-on networking commands from Day 14 with the conceptual layer underneath — DNS resolution, IP addressing, CIDR subnetting, and port assignments.

This is concept-focused documentation written in my own words, backed by command output from the EC2 instance.

---

## What I Produced

- [`day-15-networking-concepts.md`](./day-15-networking-concepts.md)

---

## Key Observations

**DNS is a distributed database — not one server.**
The resolution chain goes: browser cache → OS cache → local resolver → root nameserver → TLD nameserver → authoritative nameserver. Understanding this chain is what makes DNS propagation delays make sense — each layer has its own TTL cache.

**Private IPs are not routable on the internet — by design.**
The three private ranges (10.x.x.x, 172.16–31.x.x, 192.168.x.x) are reserved by RFC 1918. On EC2, my instance has a private IP in the 172.31.x.x range — the VPC range. AWS NAT Gateway translates this to a public IP at the edge.

**CIDR `/20` means my EC2 subnet has 4094 usable hosts.**
My EC2 interface shows `172.31.33.75/20`. That `/20` gives 2^12 = 4096 addresses, minus 2 (network and broadcast) = 4094 usable. This is the size of my VPC subnet — plenty of room for instances.

**Ports are the doors — IP is the building.**
IP gets the packet to the right machine. Port gets it to the right service on that machine. Without ports, a server could only run one service per IP address.

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Networking` `#Linux` `#DevOps`
