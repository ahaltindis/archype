#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title VPN
# @vicinae.description Connect or disconnect a VPN from ~/.config/vpn
# @vicinae.mode silent
# @vicinae.icon 🔒
# @vicinae.keywords ["wireguard", "vpn"]

# Linked into ~/.local/share/vicinae/scripts by the network unit. The menu is a vicinae dmenu, which
# can only open once this command's window has closed, so it runs on its own.
setsid -f archype-vpn menu >/dev/null 2>&1
