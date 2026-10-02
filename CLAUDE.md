# Archype

My own minimal Arch + Hyprland setup. Started as an Omarchy fork, now its own thing: Omarchy
(https://github.com/omacom/omarchy) is only a reference for problems it already solved. Never rebase onto it.

The v1 plan, decisions and the "Later" list are in `docs/v1.md`. Gotchas learned along the way are in
`docs/notes.md`; read it before touching Hyprland config, the installer, sudo handling or the test VM.

## Working with me

- **Never commit without asking.** Finish a change, show what changed, propose a message, wait for a yes.
- Commit messages: one short line, no body, no co-author/attribution trailer.
- **When a test turns up a bug, don't pick a fix.** Explain the cause and the options (with a
  recommendation) and let me choose. Diagnosing is fine without asking.
- The installer must not ask questions during setup. Anything that needs my input goes after the
  first login (e.g. the git identity notification).
- I like to run full installs myself; offer the command rather than running long installs unasked.

## Layout

- `boot.sh`: first install only (`curl ... | bash`). Clones to `~/.local/share/archype`, runs `install.sh`.
- `install.sh`: runs the units in order (`UNITS=(...)`). Re-running applies all units again, which is how
  updates work. Asks for sudo once and keeps it alive.
- `bin/archype-unit-install <unit>`: installs one unit.
- `units/<name>/`:
  - `packages.pacman`, `packages.aur`: installed with `pacman -Syu --needed` / `yay -S --needed`
  - `bin/`: linked into `~/.local/bin`
  - `default/`: linked as `~/.config/archype/<name>` (Archype defaults, never edited by the user)
  - `config/` + `unit.json` `"config"`: copied to `$HOME` once; later runs keep user edits (pristine-copy
    3-way compare, conflicts written as `.new`). Flag `"s"` = seed once, never update.
  - `run.sh`: runs as a separate process; must be safe to run twice
  - `default/hypr.lua`: any unit can add Hyprland settings this way
  - `themes/`: linked into `~/.config/archype/themes`; `~/.config/archype/current/theme` picks one
- Units: `preflight`, `system`, `cmd`, `hyprland`, `boot`, `cmd-essentials`.
- Hyprland config is Lua: `~/.config/hypr/hyprland.lua` (user) loads
  `~/.config/archype/hyprland/archype.lua` (defaults, theme, units' `hypr.lua`), then the user's overrides.

## Testing

QEMU/KVM test VM, see `test/vm` (no args prints usage). Base image made with archinstall from
`test/archinstall.json`; `ARCHYPE_VM_CONFIG=btrfs-luks` uses the btrfs + LUKS variant
(`ARCHYPE_VM_DISK_PASSWORD=archype` types the disk password at boot). Test user/password: `archype`.

- `test/vm reset; test/vm up` then `test/vm install` (full install of the working tree) or
  `test/vm unit <name>` (one unit; `ARCHYPE_VM_SUDO_PASSWORD=archype` makes it unattended).
- `test/vm ssh '<cmd>'` for checks. Inside the session use `export XDG_RUNTIME_DIR=/run/user/1000` and
  `hyprctl -i 0 ...`; `hyprctl -i 0 configerrors` and `hyprctl -i 0 binds -j | jq length` are quick checks.
- Screenshots: `hyprctl -i 0 dispatch 'hl.dsp.exec_cmd("grim /tmp/s.png")'`, then copy it out over ssh.
- The VM can't test wifi, Bluetooth, battery, brightness, lid or a real GPU.
