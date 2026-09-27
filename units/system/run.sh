#!/bin/bash

# Services are enabled only; they start on the next boot.

# Network: NetworkManager owns all interfaces. archinstall may have set up iwd or
# systemd-networkd instead (or as well), and those fight with NetworkManager.
sudo systemctl enable NetworkManager.service
sudo systemctl disable iwd.service 2>/dev/null || true
for unit in systemd-networkd.service systemd-networkd.socket \
  systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket \
  systemd-networkd-resolve-hook.socket; do
  sudo systemctl disable "$unit" 2>/dev/null || true
done

# Don't hold up boot waiting for a connection; nothing in the session needs it
sudo systemctl mask NetworkManager-wait-online.service systemd-networkd-wait-online.service

# archinstall's "copy ISO network config" drops DHCP .network files for systemd-networkd.
# Move the stock ones away so they can't compete with NetworkManager.
for file in /etc/systemd/network/20-ethernet.network /etc/systemd/network/20-wlan.network \
  /etc/systemd/network/20-wwan.network; do
  if sudo test -f "$file" && sudo grep -q '^DHCP=yes' "$file"; then
    backup_dir="/etc/systemd/network/archype-retired"
    sudo mkdir -p "$backup_dir"
    sudo mv "$file" "$backup_dir/"
    print_normal "Retired $file (moved to $backup_dir)"
  fi
done

# Bluetooth
sudo systemctl enable bluetooth.service

# Power
sudo systemctl enable power-profiles-daemon.service

# Low battery warning (the script exits quietly on machines without a battery)
systemctl --user link ~/.config/archype/system/systemd/archype-battery-monitor.service
systemctl --user enable ~/.config/archype/system/systemd/archype-battery-monitor.timer
