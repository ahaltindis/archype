#!/bin/bash

# Add fun and color and verbosity to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf
fi

# Install yay for AUR
if ! command -v yay &>/dev/null; then
  CUR_DIR=$(pwd)
  TMP_DIR=$(mktemp -d)
  cd ${TMP_DIR}
  print_normal "Cloning aur/yay-bin from Github mirror."
  git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git
  cd aur
  # Build only: makepkg installs with `sudo -k`, which ignores the installer's cached sudo
  makepkg -s --noconfirm
  sudo pacman -U --noconfirm ./yay-bin-[0-9]*.pkg.tar.zst
  cd ${CUR_DIR}
  rm -rf ${TMP_DIR}
fi

