#!/bin/bash

# Key for wayvnc's RSA-AES encryption, made once. Clients that connected before ask to trust it again
# if it's ever replaced.
key=~/.config/wayvnc/rsa_key.pem
if [[ ! -f $key ]]; then
  (umask 077 && openssl genrsa -traditional -out "$key" 4096)
fi

# wayvnc starts with the Hyprland session. Restarted now if a session is running, so updates take effect.
systemctl --user link ~/.config/archype/remote-server/archype-remote-server.service
systemctl --user enable archype-remote-server.service
if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user restart archype-remote-server.service
fi
