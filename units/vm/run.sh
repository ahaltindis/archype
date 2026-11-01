#!/bin/bash

virsh_system() {
  sudo virsh -c qemu:///system "$@"
}

# Modular libvirt daemons, socket-activated: they only run while something talks to them.
# Enabling virtqemud.socket also enables its -ro/-admin sockets and virtlogd/virtlockd.
sudo systemctl enable --now virtqemud.socket virtnetworkd.socket virtstoraged.socket virtnodedevd.socket \
  virtsecretd.socket

# Clean shutdown of running VMs when the computer shuts down (default/libvirt-guests)
if ! cmp -s "$UNIT_PATH/default/libvirt-guests" /etc/conf.d/libvirt-guests; then
  sudo install -Dm644 "$UNIT_PATH/default/libvirt-guests" /etc/conf.d/libvirt-guests
fi
sudo systemctl enable --now libvirt-guests.service

# The libvirt group manages system VMs without sudo (libvirt's polkit rule); needs a new login
if ! id -nG "$USER" | grep -qw libvirt; then
  sudo usermod -aG libvirt "$USER"
  print_active "Added $USER to the libvirt group: log out and back in before using archype-vm."
fi

# libvirt's NAT network for VMs (it runs its own dnsmasq). Started now too: autostart only applies
# when the network daemon starts, and it may already be running.
network=$(virsh_system net-info default)
if ! grep -q '^Autostart:.*yes' <<<"$network"; then
  virsh_system net-autostart default
fi
if ! grep -q '^Active:.*yes' <<<"$network"; then
  virsh_system net-start default
fi

# VM disks on btrfs: copy-on-write fragments them badly. New files inherit the attribute.
images=/var/lib/libvirt/images
if [[ "$(stat -f -c %T "$images")" == "btrfs" ]] && ! lsattr -d "$images" | awk '{print $1}' | grep -q C; then
  sudo chattr +C "$images"
fi
