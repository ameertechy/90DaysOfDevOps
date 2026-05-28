# Day 13 – Linux Volume Management (LVM)

## Overview

Day 13 is storage management — one of the areas I work with daily in production.

Managing Huawei OceanStor SAN, QNAP NAS, LUN provisioning, RAID tuning, and Veeam backup storage are part of my current role. LVM sits one layer below all of that — it is the Linux abstraction that makes flexible disk management possible without repartitioning.

Today I worked on the Hyper-V lab VM where LVM is already running in production (`ubuntu--vg-ubuntu--lv`). I observed the live setup, then created a virtual disk using `dd` and `losetup` to practice the full LVM lifecycle — physical volume, volume group, logical volume, format, mount, and extend — without touching the live system.

---

## What I Produced

- [`day-13-lvm.md`](./day-13-lvm.md)

---

## LVM Setup Created

| Layer | Name | Size |
|-------|------|------|
| Physical Volume | `/dev/loop0` (virtual disk) | 1GB |
| Volume Group | `devops-vg` | 1GB |
| Logical Volume | `app-data` | 500MB → extended to 700MB |
| Filesystem | ext4 | — |
| Mount point | `/mnt/app-data` | — |

---

## Key Observations

**LVM adds a flexible layer between physical disk and filesystem.**
Without LVM: a 100GB partition is a fixed partition. To grow it, you need to repartition — risky, disruptive, often requires downtime. With LVM: logical volumes can be extended live while mounted, snapshotted, and moved across physical disks transparently.

**Three layers — PV → VG → LV — each has a specific job.**
The physical volume (`pvcreate`) registers a disk with LVM. The volume group (`vgcreate`) pools one or more physical volumes into a single storage resource. The logical volume (`lvcreate`) carves out a usable chunk from that pool. Add a new disk to the VG and immediately have more space to allocate to any LV.

**`resize2fs` after `lvextend` is mandatory.**
`lvextend` grows the logical volume block device. But the filesystem sitting on top does not know yet — it still thinks it is the old size. `resize2fs` tells ext4 to expand and claim the newly available space. Miss this step and `df -h` still shows the original size.

**The Hyper-V VM is already running LVM in production.**
`ubuntu--vg` is the volume group. `ubuntu--lv` is the logical volume. The root filesystem is mounted on it. This is the exact setup I observed before building the practice volume — understanding the live system first, then replicating the pattern safely on a virtual disk.

---

## Real-World Tie-in

- `lvextend` + `resize2fs` is the exact sequence for growing a production Linux VM's root disk — zero downtime, live filesystem expansion
- Huawei OceanStor LUN provisioning is the SAN equivalent of `lvcreate` — carving a logical chunk from a physical pool
- LVM snapshots are the Linux equivalent of Hyper-V checkpoints — point-in-time consistent state without stopping the system
- The `dd` virtual disk method is how I safely practice destructive storage operations without risking the live system

---

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Linux` `#DevOps`
