#!/bin/bash

# Npm is needed for nvim lspconfig plugin
mise use --global node@latest

if [[ -z "$(git config user.name)" ]]; then
  USER_NAME=$(gum input --placeholder "Enter full name (git)" --prompt "Name> ")
  if [[ -n "$USER_NAME" ]]; then
    archype-state set identity.user_name "$USER_NAME"
    git config --global user.name "$USER_NAME"
  fi
fi

if [[ -z "$(git config user.email)" ]]; then
  USER_EMAIL=$(gum input --placeholder "Enter email address (git)" --prompt "Email> ")
  if [[ -n "$USER_EMAIL" ]]; then
    archype-state set identity.user_email "$USER_EMAIL"
    git config --global user.email "$USER_EMAIL"
  fi
fi

gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
