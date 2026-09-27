#!/bin/bash

# Set default shell to zsh
zsh_path="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$zsh_path" ]]; then
  sudo chsh -s "$zsh_path" "$USER"
  print_normal "Default shell changed to zsh."
fi
