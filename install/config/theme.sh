#!/bin/bash

packages=(
  kvantum-qt5         # Use dark mode for QT apps too (like kdenlive)
  gnome-themes-extra  # Prefer dark everything, adds Adwaita-dark theme
)
sudo pacman -S --noconfirm --needed "${packages[@]}"

# TODO: Is this really needed?
# yay -S --noconfirm --needed yaru-icon-theme     # Allow icons to match the theme

# Gnome/GTK apps read settings from here
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
# gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

# Sync themes
rsync -ah --progress ~/.local/share/omarchy/themes/ ~/.config/omarchy/themes/

# Set initial theme
mkdir -p ~/.config/omarchy/current
ln -snf ~/.config/omarchy/themes/tokyo-night ~/.config/omarchy/current/theme
ln -snf ~/.config/omarchy/current/theme/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ~/.config/omarchy/current/background

# Set specific app links for current theme
mkdir -p ~/.config/nvim/lua/plugins
ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua

mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config
