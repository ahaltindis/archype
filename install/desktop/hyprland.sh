#!/bin/bash

packages=(
  hyprland
  hyprshot                      # screenshot utility
  hyprpicker                    # color picker
  hyprlock                      # screen lock
  hypridle                      # track idleness
  hyprsunset                    # screen color filter
  polkit-gnome                  # gnome auth agent for elevated access in GUI apps.
  # hyprpolkitagent             # hypr replacement for gnome polkit? TODO test this
  hyprland-qtutils              # useful utility apps - dialogs, popups.
  waybar                        # statusbar
  mako                          # notification daemon
  swaybg                        # wallpaper tool
  swayosd                       # osd for volume etc
  xdg-desktop-portal-hyprland   # communication through D-Bus (screenshare, file picker)
  xdg-desktop-portal-gtk        # for file picker alonside above
  fcitx5                        # Input text/method framework
  fcitx5-gtk
  fcitx5-qt
  wl-clip-persist               # keep clipboard after programs close
  wl-clipboard                  # copy/paste tools for wayland
  uwsm                          # Wayland session manager
)
sudo pacman -S --noconfirm --needed "${packages[@]}"
yay -S --noconfirm --needed walker-bin

# Configure Hyprland
mkdir -p ~/.config
cp -R ~/.local/share/omarchy/config/desktop/hypr ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/environment.d ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/fcitx5 ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/swayosd ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/walker ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/waybar ~/.config/
cp -R ~/.local/share/omarchy/config/desktop/uwsm ~/.config/

# Use default hypr configs
cp -R ~/.local/share/omarchy/default/hypr ~/.local/share/
cp -R ~/.local/share/omarchy/default/walker ~/.local/share/


## Overrides

# Copy over the keyboard layout that's been set in Arch during install to Hyprland
conf="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.conf"

layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"' || true)

if [[ -n "$layout" ]]; then
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_layout = $layout" "$hyprconf"
fi

if [[ -n "$variant" ]]; then
  sed -i "/^[[:space:]]*kb_options *=/i\  kb_variant = $variant" "$hyprconf"
fi
