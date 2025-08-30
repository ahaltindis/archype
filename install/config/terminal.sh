#!/bin/bash

packages=(
  unzip
  inetutils
  impala         # TUI Wifi
  fd             # better find
  eza            # better ls
  fzf            # fuzzy finder
  ripgrep
  zoxide         # better cd
  bat            # better cat
  dust           # better du
  jq
  fastfetch      # system information display tool
  btop           # system monitor
  man
  tldr
  less
  whois
  plocate        # better locate
  starship       # bash prompt
  bash-completion
  gum            # make interactive terminal tools
  rsync
)

sudo pacman -S --noconfirm --needed "${packages[@]}"

# Configure bash
mkdir -p ~/.config
cp -R ~/.local/share/omarchy/config/terminal/fastfetch ~/.config/
cp -R ~/.local/share/omarchy/config/terminal/btop ~/.config/
cp ~/.local/share/omarchy/config/terminal/starship.toml ~/.config/

# Use default bash configs and bashrc from Omarchy
cp -R ~/.local/share/omarchy/default/bash ~/.local/share/
cp ~/.local/share/omarchy/default/bashrc ~/.bashrc

