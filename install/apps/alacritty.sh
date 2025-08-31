#!/bin/bash

sudo pacman -S --noconfirm --needed alacritty

cp -R ~/.local/share/omarchy/config/apps/alacritty ~/.config/
cp -R ~/.local/share/omarchy/default/alacritty ~/.local/share/
