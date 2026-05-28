# Linux Volume Management (LVM)
*#90DaysOfDevOps 2026*

---

## What is LVM and Why It Exists

**LVM** stands for **Logical Volume Manager**.

Traditional disk partitioning is rigid. A 100GB partition `/dev/sda1` is exactly 100GB. If it fills up, your only options are to add a new disk (and manage two separate mount points) or repartition (risky, usually requires downtime and data migration).

LVM solves this by adding an abstraction layer between physical disks and the filesystem:

```
Physical Disks         LVM Layer              Filesystem
─────────────    →    ────────────    →    ─────────────────
/dev/sda              Physical Volume       ext4, xfs, etc.
/dev/sdb         →    Volume Group     →    /mnt/app-data
/dev/loop0            Logical Volume        /var/lib/docker
```

**With LVM:**
- Grow a volume while it is mounted and in use
- Combine multiple physical disks into one logical pool
- Take point-in-time snapshots without stopping the system
- Move data between physical disks transparently

---

## The Three Layers of LVM

### Layer 1 — Physical Volume (PV)

A physical volume is any block device registered with LVM — a real disk, a partition, or a virtual disk. `pvcreate` initializes it and writes LVM metadata to it.

```
/dev/sda  ──────────────────────────────►  Physical Volume
/dev/loop0  (virtual disk from dd)  ────►  Physical Volume
```

### Layer 2 — Volume Group (VG)

A volume group pools one or more physical volumes into a single storage resource. Think of it as a storage bank — you deposit disks into it and withdraw logical volumes from it.

```
PV: /dev/loop0 (1GB)
         │
         ▼
VG: devops-vg  (1GB available to allocate)
```

### Layer 3 — Logical Volume (LV)

A logical volume is what you actually format and mount as a filesystem. It is carved from the volume group's available space. Multiple logical volumes can exist in one VG.

```
VG: devops-vg (1GB)
       │
       ├──► LV: app-data (500MB) → /mnt/app-data
       └──► LV: logs-data (300MB) → /mnt/logs  (future)
```

---

## Task 1 — Check Current Storage

```bash
# See all block devices and their relationships
lsblk
```

**What `lsblk` stands for:** List Block devices.

**Expected output on Hyper-V VM:**
```
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   23G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0   23G  0 lvm  /
```

**Reading this output:**
- `sda` = the physical disk (25GB total)
- `sda2` = boot partition (2GB)
- `sda3` = LVM partition (23GB) — the raw block device given to LVM
- `ubuntu--vg-ubuntu--lv` = the logical volume carved from sda3 — this is where `/` is mounted

The double dashes (`--`) in the device name are how LVM escapes single dashes in names. `ubuntu-vg` becomes `ubuntu--vg` in the device path.

```bash
# Check existing physical volumes
sudo pvs
# Shows: PV name, VG it belongs to, size, free space

# Check existing volume groups
sudo vgs
# Shows: VG name, number of PVs, number of LVs, total size, free size

# Check existing logical volumes
sudo lvs
# Shows: LV name, VG name, size

# Check mounted filesystems
df -h
# Shows: filesystem device, size, used, available, mount point
```

**Observing the live LVM setup:**
```
PV: /dev/sda3    VG: ubuntu-vg    Size: 23GB
VG: ubuntu-vg    LV: ubuntu-lv    Size: 23GB
LV: ubuntu-lv    Mount: /         Used: ~7.4GB (34%)
```

---

## Task 2 — Create a Virtual Disk

Since I am not adding a physical disk to the VM, I create a virtual disk file using `dd` and attach it as a loop device.

```bash
# Create a 1GB empty file — this becomes our virtual disk
sudo dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
```

**`dd` command breakdown — every part:**
- `dd` = data duplicator — copies data from one source to another
- `if=/dev/zero` = **input file** — read from `/dev/zero` which produces infinite zero bytes
- `of=/tmp/disk1.img` = **output file** — write to this file (creates it)
- `bs=1M` = **block size** = 1 Megabyte per write operation
- `count=1024` = write 1024 blocks — so 1024 × 1MB = 1GB total

**Without `bs` and `count`:** `dd` would copy forever from `/dev/zero`. Always specify both.

```bash
# Verify the file was created
ls -lh /tmp/disk1.img
# -rw-r--r-- 1 root root 1.0G /tmp/disk1.img

# Attach the file as a loop device (makes it behave like a real disk)
sudo losetup -fP /tmp/disk1.img
```

**`losetup` breakdown:**
- `losetup` = loop device setup — attaches a file as a block device
- `-f` = find the first available free loop device automatically
- `-P` = scan for partitions after setup

```bash
# Find out which loop device was assigned
sudo losetup -a
# Output: /dev/loop0: []: (/tmp/disk1.img)
# /dev/loop0 is now a 1GB virtual disk

# Confirm lsblk shows it
lsblk | grep loop0
# loop0   7:0    0    1G  0 loop
```

---

## Task 3 — Create Physical Volume

```bash
# Initialize the loop device as an LVM physical volume
sudo pvcreate /dev/loop0
```

**What `pvcreate` does:** Writes LVM metadata (a header called the PV label) to the beginning of the device. This marks it as an LVM-managed disk. The device is now registered in the LVM system.

```bash
# Verify
sudo pvs
```

**Expected output:**
```
  PV          VG        Fmt  Attr PSize   PFree
  /dev/loop0            lvm2 ---  1020.00m 1020.00m
  /dev/sda3   ubuntu-vg lvm2 a--   <23.00g    0
```

`/dev/loop0` is now a PV with no VG assigned yet (blank VG column) and full free space.

---

## Task 4 — Create Volume Group

```bash
# Create a volume group named devops-vg using /dev/loop0
sudo vgcreate devops-vg /dev/loop0
```

**`vgcreate` breakdown:**
- `vgcreate` = volume group create
- `devops-vg` = name of the new volume group
- `/dev/loop0` = physical volume(s) to include — can list multiple PVs here

```bash
# Verify
sudo vgs
```

**Expected output:**
```
  VG        #PV #LV #SN Attr   VSize    VFree
  devops-vg   1   0   0 wz--n- 1016.00m 1016.00m
  ubuntu-vg   1   1   0 wz--n-  <23.00g       0
```

`devops-vg` has 1 PV, 0 LVs yet, ~1016MB free.

---

## Task 5 — Create Logical Volume

```bash
# Create a 500MB logical volume named app-data inside devops-vg
sudo lvcreate -L 500M -n app-data devops-vg
```

**`lvcreate` breakdown:**
- `lvcreate` = logical volume create
- `-L 500M` = **size** — allocate exactly 500 Megabytes
- `-n app-data` = **name** — call this logical volume `app-data`
- `devops-vg` = which volume group to carve it from

**Other size options:**
```bash
-L 2G          # exactly 2 Gigabytes
-l 50%FREE     # 50% of remaining free space in VG
-l 100%FREE    # use all remaining free space
```

```bash
# Verify
sudo lvs
```

**Expected output:**
```
  LV        VG        Attr       LSize
  app-data  devops-vg -wi-a----- 500.00m
  ubuntu-lv ubuntu-vg -wi-ao---- <23.00g
```

---

## Task 6 — Format and Mount

```bash
# Format the logical volume with ext4 filesystem
sudo mkfs.ext4 /dev/devops-vg/app-data
```

**What `mkfs.ext4` does:**
- `mkfs` = make filesystem
- `.ext4` = the filesystem type — ext4 is the standard Linux filesystem
- `/dev/devops-vg/app-data` = the logical volume device path

**Without formatting:** The LV is just raw empty blocks. The OS cannot store files on it until a filesystem structure is written.

```bash
# Create the mount point directory
sudo mkdir -p /mnt/app-data

# Mount the logical volume
sudo mount /dev/devops-vg/app-data /mnt/app-data

# Verify it is mounted and available
df -h /mnt/app-data
```

**Expected output:**
```
Filesystem                        Size  Used Avail Use% Mounted on
/dev/mapper/devops--vg-app--data  472M   28K  435M   1% /mnt/app-data
```

The `devops--vg-app--data` path is the device mapper name — same double-dash convention as the existing LVM setup.

```bash
# Write a test file to confirm it works
echo "LVM app-data volume working" | sudo tee /mnt/app-data/test.txt
cat /mnt/app-data/test.txt
```

---

## Task 7 — Extend the Volume

```bash
# Extend the logical volume by 200MB more
sudo lvextend -L +200M /dev/devops-vg/app-data
```

**`lvextend` breakdown:**
- `-L +200M` = add 200MB to the current size (the `+` means add, not set to 200M)
- Without `+`: `-L 200M` would try to set total size to 200M — smaller than current — and fail

```bash
# Check the LV size increased
sudo lvs /dev/devops-vg/app-data
# LSize should now show 700.00m

# But the filesystem does not know yet
df -h /mnt/app-data
# Still shows 472M — filesystem has not been resized
```

```bash
# Resize the filesystem to use the new space
sudo resize2fs /dev/devops-vg/app-data
```

**What `resize2fs` does:** Tells the ext4 filesystem to expand to fill the full size of the logical volume. This is the step that makes the space actually usable.

```bash
# Verify filesystem now shows the larger size
df -h /mnt/app-data
# Should now show ~681M available
```

---

## Cleanup After Practice

```bash
# Unmount
sudo umount /mnt/app-data

# Remove logical volume
sudo lvremove /dev/devops-vg/app-data
# Confirms: Do you really want to remove? Type y

# Remove volume group
sudo vgremove devops-vg

# Remove physical volume
sudo pvremove /dev/loop0

# Detach loop device
sudo losetup -d /dev/loop0

# Delete the virtual disk file
sudo rm /tmp/disk1.img

# Verify everything cleaned up
sudo pvs
sudo vgs
sudo lvs
lsblk | grep loop
```

---

## LVM Command Reference

| Command | Purpose |
|---------|---------|
| `lsblk` | List all block devices and relationships |
| `pvs` | List physical volumes |
| `vgs` | List volume groups |
| `lvs` | List logical volumes |
| `pvcreate /dev/sdX` | Initialize disk as LVM physical volume |
| `vgcreate vgname /dev/sdX` | Create volume group |
| `lvcreate -L size -n name vgname` | Create logical volume |
| `mkfs.ext4 /dev/vgname/lvname` | Format logical volume |
| `mount /dev/vgname/lvname /mnt/point` | Mount logical volume |
| `lvextend -L +size /dev/vgname/lvname` | Extend logical volume |
| `resize2fs /dev/vgname/lvname` | Resize filesystem after extend |
| `lvremove /dev/vgname/lvname` | Delete logical volume |
| `vgremove vgname` | Delete volume group |
| `pvremove /dev/sdX` | Remove physical volume |
| `losetup -fP file.img` | Attach file as loop device |
| `losetup -d /dev/loop0` | Detach loop device |

---

*#90DaysOfDevOps 2026*
