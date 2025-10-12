#!/bin/bash

# Gnome/GTK apps read settings from here
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
# gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

mkdir -p ~/.config/archype/current
ln -snf ~/.config/archype/themes/tokyo-night ~/.config/archype/current/theme
ln -snf $(find ~/.config/archype/current/theme/backgrounds/ -maxdepth 1 -type f | head -1) ~/.config/archype/current/background
ln -snf ~/.config/archype/hyprland/default-screensaver.txt ~/.config/archype/current/screensaver

# Copy over the keyboard layout that's been set in Arch during install to Hyprland
#FIXME: this needs to handle input.conf override safely.

# conf="/etc/vconsole.conf"
# hyprconf="$HOME/.config/hypr/input.conf"
#
# layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
# variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"' || true)
#
# if [[ -n "$layout" ]]; then
#   sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
# fi
#
# if [[ -n "$variant" ]]; then
#   sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
# fi

