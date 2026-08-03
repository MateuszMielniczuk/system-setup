# Hibernation (btrfs + LUKS)

For laptops with no S3 (`cat /sys/power/mem_sleep` shows only `[s2idle]`),
hibernation is the fix for sleep battery drain.

## 1. Swapfile

Own subvolume, so snapshots skip it. Size >= RAM.

```bash
sudo btrfs subvolume create /swap
sudo btrfs filesystem mkswapfile --size 32g --uuid clear /swap/swapfile
sudo swapon /swap/swapfile
```

## 2. fstab

```
/swap/swapfile   none   swap   defaults 0 0
```

No mount line needed — `/swap` is nested inside `@`, already mounted as `/`.

## 3. Kernel cmdline

Get the offset:

```bash
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

Add both to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` (UUID is the
same as in `root=`):

```
resume=UUID=<uuid> resume_offset=<offset>
```

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Reboot. `cat /sys/power/resume` must not be `0:0`. Test with
`systemctl hibernate`.

## 4. Suspend-then-hibernate

```bash
sudo mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
```

`/etc/systemd/sleep.conf.d/10-hibernate.conf`:

```ini
[Sleep]
HibernateDelaySec=30min
HibernateOnACPower=no
```

`/etc/systemd/logind.conf.d/10-lid.conf`:

```ini
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
HandleLidSwitchDocked=ignore
```

Reboot to apply.

## Caveats

- Never move, copy, or resize the swapfile — the offset changes and resume
  breaks silently. Redo step 3.
- A snapper rollback of `@` restores an empty `/swap`. Recreate the swapfile and
  redo step 3.
