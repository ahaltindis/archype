#!/bin/bash

# Add fun and color and verbosity to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf
fi

# Install yay for AUR
if ! command -v yay &>/dev/null; then
  mkdir -p /tmp/archype
  cd /tmp/archype
  rm -rf aur
  rm -rf yay-bin
  print_normal "Cloning yay-bin from Github mirror."
  git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
  cd ~
fi

