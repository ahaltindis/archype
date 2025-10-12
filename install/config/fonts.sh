#!/bin/bash

packages=(
  woff2-font-awesome
  ttf-cascadia-mono-nerd
  ttf-jetbrains-mono
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
)
sudo pacman -S --noconfirm --needed "${packages[@]}"

# Omarchy logo in a font for Waybar use
# mkdir -p ~/.local/share/fonts
# cp ~/.local/share/omarchy/config/omarchy.ttf ~/.local/share/fonts/
# fc-cache

# TODO: what uses this?
mkdir -p ~/.config
cp -R ~/.local/share/omarchy/config/fontconfig ~/.config/
