#!/bin/bash

# Gnome/GTK apps read settings from here
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
# gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

# Set initial theme and background; keep the user's choice on re-runs
mkdir -p ~/.config/archype/current
[[ -e ~/.config/archype/current/theme ]] ||
  ln -snf ~/.config/archype/themes/archype ~/.config/archype/current/theme
[[ -e ~/.config/archype/current/background ]] ||
  ln -snf "$(find ~/.config/archype/current/theme/backgrounds/ -maxdepth 1 -type f | sort | head -1)" ~/.config/archype/current/background

# Vicinae: use the current Archype theme, skip its first-start screen
mkdir -p ~/.local/share/vicinae/themes ~/.local/state/vicinae
ln -snf ~/.config/archype/current/theme/vicinae.toml ~/.local/share/vicinae/themes/archype.toml
[[ -f ~/.local/state/vicinae/onboarding.json ]] ||
  echo '{"version":1,"completedAt":"archype-install"}' >~/.local/state/vicinae/onboarding.json

# A running vicinae doesn't see newly installed or upgraded extensions until it restarts
if pgrep -x vicinae-server >/dev/null; then
  setsid uwsm app -- vicinae server --replace >/dev/null 2>&1 &
fi

# Brave as the default browser, unless one was already chosen
if [[ -z "$(xdg-settings get default-web-browser 2>/dev/null)" ]]; then
  xdg-settings set default-web-browser brave-browser.desktop
fi

# Brave: frame colors from the current theme, applied as a managed browser policy
chromium_theme=~/.config/archype/current/theme/chromium.theme
if [[ -f $chromium_theme ]]; then
  IFS=, read -r red green blue <"$chromium_theme"
  policy=$(printf '{"BrowserThemeColor": "#%02x%02x%02x"}' "$red" "$green" "$blue")
  if [[ "$(cat /etc/brave/policies/managed/color.json 2>/dev/null)" != "$policy" ]]; then
    sudo mkdir -p /etc/brave/policies/managed
    echo "$policy" | sudo tee /etc/brave/policies/managed/color.json >/dev/null
  fi
fi

# Default apps for file types, and foot as the terminal for launchers (xdg-terminal-exec, vicinae).
# System-wide files: ~/.config/mimeapps.list and ~/.config/xdg-terminals.list still win over them.
install_system_file() {
  if ! cmp -s "$1" "$2"; then
    sudo install -Dm644 "$1" "$2"
  fi
}
install_system_file "$UNIT_PATH/xdg/mimeapps.list" /etc/xdg/mimeapps.list
install_system_file "$UNIT_PATH/xdg/xdg-terminals.list" /etc/xdg/xdg-terminals.list
for entry in "$UNIT_PATH"/xdg/applications/*.desktop; do
  install_system_file "$entry" "/usr/local/share/applications/$(basename "$entry")"
done
