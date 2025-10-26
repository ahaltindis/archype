#!/bin/bash

# Set nice plain spinner with Arch Linux logo
sudo plymouth-set-default-theme spinner

# Update Limine bootloader config
sudo sed -i '/^\/Arch Linux (linux)$/,/^$/ {
  /^[[:space:]]*cmdline:/ {
    /quiet/! { /splash/! s/rw/rw quiet splash/ }
  }
}' /boot/limine/limine.conf

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
fi

# Enable sddm login service
sudo systemctl enable sddm.service

# Regenerate initramfs
sudo mkinitcpio -P
