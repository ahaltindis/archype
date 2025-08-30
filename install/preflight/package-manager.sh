#!/bin/bash

# Install build tools
sudo pacman -S --needed --noconfirm base-devel

# Add fun and color and verbosity to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf
fi

# Install yay for AUR
if ! command -v yay &>/dev/null; then
  cd /tmp
  if omarchy-pkg-aur-accessible; then
    echo -e "\e[32m\nCloning yay-bin from AUR\e[0m"
    git clone https://aur.archlinux.org/yay-bin.git
  else
    echo -e "\e[31m\nAUR is unavailable, cloning yay-bin from Github mirror.\e[0m"
    git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git
  fi
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
  cd ~
fi

