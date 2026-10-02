# Archype

Fork of Omarchy ([omarchy.org](https://omarchy.org)) for my own taste.

## Installing Arch

Archype installs on top of a fresh, vanilla Arch Linux made with `archinstall`.

Before you start:

- The firmware must boot in **UEFI** mode with **Secure Boot off** (Limine isn't signed).
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

## Installing Archype

On the freshly installed Arch, logged in as your user:

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
