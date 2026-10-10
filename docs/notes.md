# Notes

Things learned the hard way. Each one cost a debugging session.

## Hyprland

- **Config is Lua since 0.55** (hyprlang `.conf` is deprecated and gets dropped). Hyprland picks
  `hyprland.lua` over `hyprland.conf` at **start**; a reload doesn't switch formats.
- **`hyprctl dispatch` takes Lua** with a Lua config: `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`.
  The old `hyprctl dispatch dpms off` fails. Check `hypridle.conf` and scripts when adding commands.
- `hyprctl keyword` doesn't work with a Lua config. Try an option live with
  `hyprctl eval 'hl.config({ input = { follow_mouse = 2 } })'`; a reload resets it.
- `require()` caches modules for Hyprland's lifetime. `archype.lua` clears `archype.*` and `hypr.*` from
  `package.loaded` so `hyprctl reload` sees edits.
- **Hyprland reloads when its config files change.** If a file or the `~/.config/archype/hyprland` link
  is missing at that moment, the reload fails into emergency mode (no keybindings) until the next
  reload. That's why the installer swaps links with `mv -T` and writes copies via a temp file + rename,
  and why `boot.sh` (which deletes and re-clones) is only for the first install.
- Keybindings and waybar clicks run in the session environment, not a shell. `~/.local/bin` is on the
  session `PATH` only through `~/.config/uwsm/env`.
- waybar's workspaces module only draws window icons (`workspace-taskbar`) when `format` contains
  `{windows}`. A module instance name becomes a CSS class: `hyprland/workspaces#hidden` gets `.hidden`,
  which Archype's `style.css` makes invisible. With `ignore-workspaces`, windows opened after waybar
  started never show up when moved to a shown special workspace (waybar 0.15 compares
  `special:hidden` with `hidden`), so the hidden-windows module hides the other workspaces with CSS.
- waybar can lose its connection to Hyprland's event socket and never reconnects: workspaces stop
  updating. `archype-restart-app waybar` fixes it (`SUPER + CTRL + B` only hides/shows the same bar).
- Killing waybar abruptly can leave a blank "ghost" layer on top (`hyprctl layers` shows `pid: -1`).
  Seen only during testing; a reboot clears it.
- QEMU's `screendump` doesn't work with the GL display ("no surface"); take screenshots with `grim`
  inside the session.

## Installer and sudo

- With `curl ... | bash`, stdin is the script itself: a child that reads stdin eats the rest of
  `boot.sh`. `boot.sh` runs `install.sh </dev/tty`.
- gum's TUI crashes when its output goes into a pipe (`boot.sh` tees everything into the log). Avoid
  interactive TUIs in the installer; better yet, don't ask anything during install.
- **makepkg installs with `sudo -k`**, which ignores cached credentials. yay is bootstrapped with
  `makepkg -s` + our own `sudo pacman -U`.
- A background loop's `sleep` keeps the stdout pipe open after the script exits, so `tee` waits for it.
  The sudo keepalive loop sends its output to `/dev/null`.
- sudo's timestamp is per terminal: unattended runs over ssh need a forced pty (`ssh -tt`).
- `/boot` (the EFI partition from archinstall) is root-only; check files there with `sudo test -f`.
- `pacman -Sy` followed by `pacman -S` is a partial upgrade; always `pacman -Syu --needed`.
- `powerprofilesctl` needs `python-gobject` (only an optional dependency of power-profiles-daemon).
  Switching profiles over ssh fails (polkit only allows the active seat session).

## Apps

- **Brave colors** come from the managed policy `/etc/brave/policies/managed/color.json` with
  `BrowserThemeColor` (root-only, so it's written by the installer). Brave ignores
  `BrowserColorScheme`. A blue seed turns the frame light; black gives a dark frame.
- vicinae: config is `~/.config/vicinae/settings.json`; themes are TOML in
  `~/.local/share/vicinae/themes/` (id = file name); the first-start screen is skipped by writing
  `~/.local/state/vicinae/onboarding.json` with `{"version":1}`. Without `=`, the calculator only runs
  when nothing else matches. A running vicinae only watches extension folders that existed when it
  started (`/usr/share/vicinae/extensions/` appears with the first extension package), so the
  hyprland unit (re)starts it with `vicinae server --replace` when the installer runs inside Hyprland.
- foot keeps `TERM=foot` (its terminfo comes with ncurses) for the full feature set locally. Servers
  often lack that entry ("unknown terminal type", broken `clear`/vim/htop), so the `ssh` alias in
  `essentials.zsh` sends `xterm-256color`. To give a host foot's entry:
  `infocmp -x foot | command ssh host -- tic -x -`.
- foot themes use `[colors-dark]` / `[colors-light]` (foot 1.28); light themes set
  `initial-color-theme=light`. `foot -C -c <file>` checks a config.
- **Default apps** come from `/etc/xdg/mimeapps.list` (shipped by the hyprland unit); the user's
  `~/.config/mimeapps.list` wins over it. `XDG_UTILS_DEBUG_LEVEL=3 xdg-mime query default <type>`
  shows the lookup.
- On Hyprland, xdg-open runs in "generic" mode and **ignores `Terminal=true`**: nvim or yazi opened
  from a launcher, Brave or a script starts with no terminal and fails silently. That's why text and
  folders open through `archype-nvim.desktop`/`archype-yazi.desktop`, which call
  `xdg-terminal-exec`.
- xdg-mime and gio skip a default whose `Exec` program isn't installed and fall back to another app.
- foot has three `TerminalEmulator` entries (foot, footclient, foot-server). Without
  `/etc/xdg/xdg-terminals.list` naming `foot.desktop`, xdg-terminal-exec could pick one that needs a
  foot server. vicinae reads the same list for terminal apps.
- `libmupdf` needs a `tesseract-data-*` package; with `--noconfirm` pacman takes the first one
  (Afrikaans) unless `tesseract-data-eng` is in the same install.
- With only Archype's fonts there were no emoji or general-purpose fonts; `noto-fonts` and
  `noto-fonts-emoji` fix web pages.

## archinstall 4.4 (config files in `test/`)

- The sample config in archinstall's repo is outdated; the source (`archinstall/lib/args.py`,
  `models/*.py`) is the reference.
- Partition sizes need `sector_size` as an object (`{"value": 512, "unit": "B"}`), and `dev_path` must
  be present (`null`). There's no `Percent` unit.
- Encryption: `disk_config.disk_encryption = {"encryption_type": "luks", "partitions": ["<obj_id>"]}`
  plus a top-level `encryption_password`.
- archinstall uses the busybox `encrypt` hook; Plymouth must come before it (Archype puts it right
  after `base udev`).
- OVMF tries network boot before the disk unless the disk has a `bootindex`.
