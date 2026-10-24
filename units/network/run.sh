#!/bin/bash

# The "VPN" launcher command. vicinae finds scripts in this folder.
mkdir -p ~/.local/share/vicinae/scripts
ln -sfn ~/.config/archype/network/vicinae/vpn.sh ~/.local/share/vicinae/scripts/archype-vpn.sh

# Not created here: ~/.config/vpn may be a link to a folder kept elsewhere, and an empty real folder
# would be in its way. `archype-vpn menu` -> "Open VPN folder" creates it when needed.
