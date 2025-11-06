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
  makepkg -si --noconfirm
  cd ${CUR_DIR}
  rm -rf ${TMP_DIR}
fi

