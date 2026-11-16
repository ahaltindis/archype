#!/bin/bash
# @vicinae.schemaVersion 1
# @vicinae.title Keyboard Layout
# @vicinae.description Switch, add or remove a keyboard layout
# @vicinae.mode silent
# @vicinae.icon ⌨️
# @vicinae.keywords ["locale", "language", "keyboard", "layout", "input"]

# Linked into ~/.local/share/vicinae/scripts by the hyprland unit. The menu is a vicinae dmenu, which
# can only open once this command's window has closed, so it runs on its own.
setsid -f archype-keyboard menu >/dev/null 2>&1
