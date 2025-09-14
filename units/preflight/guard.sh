#!/bin/bash

abort() {
  print_error "Install requires: $1"
  echo
  exit 1
}

# Must be an Arch distro
[[ -f /etc/arch-release ]] || abort "Vanilla Arch"

# Must not be an Arch derivative distro
for marker in /etc/cachyos-release /etc/eos-release /etc/garuda-release /etc/manjaro-release; do
  [[ -f "$marker" ]] && abort "Vanilla Arch"
done

# Must not be running as root
[ "$EUID" -eq 0 ] && abort "Normal user (not sudo)"

# Must be x86 only to fully work
[ "$(uname -m)" != "x86_64" ] && abort "x86_64 CPU"

# Must not have Gnome or KDE already install
pacman -Qe gnome-shell &>/dev/null && abort "Fresh + Vanilla Arch"
pacman -Qe plasma-desktop &>/dev/null && abort "Fresh + Vanilla Arch"

# Cleared all guards
print_normal "Guards: OK"
