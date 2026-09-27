#!/bin/bash

rebuild_initramfs=""

# Set nice plain spinner with Arch Linux logo
if [[ "$(plymouth-set-default-theme)" != "spinner" ]]; then
  sudo plymouth-set-default-theme spinner
  rebuild_initramfs=1
fi

# Find config location (/boot is root-only when it's the ESP, so check with sudo)
limine_config=""
for candidate in \
  /boot/EFI/arch-limine/limine.conf \
  /boot/EFI/BOOT/limine.conf \
  /boot/EFI/limine/limine.conf \
  /boot/limine/limine.conf \
  /boot/limine.conf; do
  if sudo test -f "$candidate"; then
    limine_config="$candidate"
    break
  fi
done

if [[ -z "$limine_config" ]]; then
  echo "Error: /boot limine config not found" >&2
  exit 1
fi

# Update Limine bootloader config
sudo sed -i '/^\/Arch Linux (linux)$/,/^$/ {
  /^[[:space:]]*cmdline:/ {
    /quiet/! { /splash/! s/rw/rw quiet splash/ }
  }
}' "$limine_config"

# Add plymouth splash hook to initramfs
if ! grep -Eq '^HOOKS=.*plymouth' /etc/mkinitcpio.conf; then
  # Backup original mkinitcpio.conf just in case
  backup_timestamp=$(date +"%Y%m%d%H%M%S")
  sudo cp /etc/mkinitcpio.conf "/etc/mkinitcpio.conf.bak.${backup_timestamp}"

  # Add plymouth to HOOKS array after 'base udev' or 'base systemd'
  if grep "^HOOKS=" /etc/mkinitcpio.conf | grep -q "base systemd"; then
    sudo sed -i '/^HOOKS=/s/base systemd/base systemd plymouth/' /etc/mkinitcpio.conf
  elif grep "^HOOKS=" /etc/mkinitcpio.conf | grep -q "base udev"; then
    sudo sed -i '/^HOOKS=/s/base udev/base udev plymouth/' /etc/mkinitcpio.conf
  else
    echo "Couldn't add the Plymouth hook to mkinitcpio.conf"
    exit 1
  fi
  rebuild_initramfs=1
fi

# Autologin into Hyprland for the installing user
autologin="[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=archlinux-simplyblack"
if [[ "$(cat /etc/sddm.conf.d/autologin.conf 2>/dev/null)" != "$autologin" ]]; then
  sudo mkdir -p /etc/sddm.conf.d
  echo "$autologin" | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null
fi

# Enable sddm login service
sudo systemctl enable sddm.service

# Regenerate initramfs only when the theme or hooks changed
if [[ -n "$rebuild_initramfs" ]]; then
  sudo mkinitcpio -P
fi
