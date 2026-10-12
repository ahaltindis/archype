# Archype

Fork of Omarchy ([omarchy.org](https://omarchy.org)) for my own taste.

## Installing Arch

Archype installs on top of a fresh, vanilla Arch Linux made with `archinstall`.

Before you start:

- The firmware must boot in **UEFI** mode with **Secure Boot off** (Limine isn't signed).
- Keeping Windows on the machine? Read [Next to Windows](#next-to-windows) first.
- Boot the [Arch ISO](https://archlinux.org/download/). For wifi, connect with `iwctl`.
- Run `archinstall` and go through its menu as below.

| # | Setting | Choose |
|---|---------|--------|
| 1 | Archinstall language | English |
| 2 | Locales | `us`, `en_US`, `UTF-8`. **Pick your own keyboard layout**: Archype uses it in Hyprland too. |
| 3 | Mirrors and repositories | Leave as is, or pick your country. No extra repositories needed (enable `multilib` only if you want Steam or Wine). |
| 4 | Disk configuration | Best-effort default layout, **btrfs** with the default subvolumes and compression. **Encryption (LUKS)** is recommended on laptops. Archype expects `/boot` to be the EFI partition, which the default layout does. |
| 5 | Swap | zram (default) |
| 6 | Bootloader | **Limine**. No unified kernel image (UKI). Removable location is optional. Don't set a Plymouth theme; Archype sets up the boot screen. |
| 7 | Kernels | `linux`. *Optional:* also select `linux-lts` (Space, then Enter) as a fallback kernel in the boot menu. Its entry boots with text messages instead of the spinner. |
| 8 | Hostname | Your choice |
| 9 | Authentication | One user **with sudo** (superuser: yes). Root password is optional. Skip U2F. |
| 10 | Profile | **Minimal**. Archype installs the desktop itself. Intel and AMD graphics work as is; NVIDIA isn't supported yet. |
| 11 | Applications | Audio: **pipewire**. Bluetooth: not needed (Archype sets it up). Power management: leave unset or `power-profiles-daemon`, **not `tuned`**. Print service, firewall and `noto-fonts-cjk` are optional. |
| 12 | Network configuration | **Use Network Manager (default backend)** |
| 13 | Pacman | 5 parallel downloads |
| 14 | Additional packages | None needed. Add your own if you like, e.g. `openssh` to SSH into the machine. |
| 15 | Timezone | Yours |
| 16 | Automatic time sync (NTP) | On |

Then choose **Install**, reboot, and log in as your user on the text console.

> **Autologin:** Archype logs your user in automatically after boot. With disk encryption, the disk
> password is effectively your login. Without encryption, the machine starts straight to the desktop
> with no password. The lock screen (Super+Ctrl+L, and after 5 minutes idle) uses your user password.

### Next to Windows

To keep an existing Windows, prepare it first, in an administrator terminal:

- Back up what you can't lose.
- `manage-bde -status` shows whether BitLocker is on. Turn it off or save the recovery key: Windows asks
  for it once Secure Boot is off.
- `powercfg /h off` turns off Fast Startup, which leaves the Windows disk in a hibernated state.
- Keep the hardware clock in UTC like Arch does, or the time jumps on every switch:
  ```
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
  ```
- For Arch on the Windows disk, shrink `C:` in Disk Management and leave the freed space unallocated.

Turn Secure Boot off and check that Windows still starts (some anti-cheat games need Secure Boot).

In archinstall, only the disk configuration (step 4) differs:

- **Arch on its own disk:** the best-effort default layout on that disk only. It wipes the whole disk.
- **Arch on the Windows disk:** manual partitioning, creating two partitions in the free space and
  leaving the existing ones alone:
  - 1 GiB, fat32, mounted at `/boot`, flagged as ESP/boot. Don't reuse the Windows EFI partition: it's
    too small for the kernels.
  - The rest as btrfs with compression, mounted at `/`, with subvolumes `@` → `/`, `@home` → `/home`,
    `@log` → `/var/log` and `@pkg` → `/var/cache/pacman/pkg`.

  For encryption, go back to the disk configuration menu, open **Disk encryption**, choose `LUKS`, set
  a password and select only the btrfs partition.

For the bootloader, leave the removable location off, so the firmware gets a Limine entry next to
Windows Boot Manager. If Windows still starts first, move Limine to the top of the firmware's boot
order (a big Windows update can undo this).

Limine doesn't detect other systems, so add Windows to its menu by hand once Arch runs. Find the
`PARTUUID` of the Windows EFI partition (the small `vfat` one, usually 100 MB):

```
lsblk -o NAME,SIZE,FSTYPE,PARTTYPENAME,PARTUUID
```

Then add this to the end of the Limine config (`sudo find /boot -name limine.conf` shows where it is):

```
/Windows
    protocol: efi
    path: guid(<PARTUUID>):/EFI/Microsoft/Boot/bootmgfw.efi
```

## Installing Archype

On the freshly installed Arch, log in as your user. On wifi, connect first with `nmtui` (the `iwctl`
connection from the Arch ISO isn't carried over). Then run:

```
curl -fsSL https://raw.githubusercontent.com/ahaltindis/archype/refs/heads/main/boot.sh | bash
```

It asks for your sudo password once, then installs without further questions. The log is saved to
`~/.local/log/archype/`. Reboot when it's done.

On the first login, a notification shows how to set your git identity, if it isn't set yet.

The command above is only for the first install. To update later, run the installer from the existing
copy; it checks every part for updates, keeps your config edits, and is safe while the desktop is open:

```
git -C ~/.local/share/archype pull
bash ~/.local/share/archype/install.sh
```

## License

Archype is released under the [MIT License](https://opensource.org/licenses/MIT).
