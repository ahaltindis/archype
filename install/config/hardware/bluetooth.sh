#!/bin/bash

# Install bluetooth controls
sudo pacman -S --noconfirm --needed blueberry

# Turn on bluetooth by default
sudo systemctl enable --now bluetooth.service
