#!/bin/bash

# Npm is needed for nvim lspconfig plugin
mise use --global node@latest

if [[ -z "$(git config user.name)" ]]; then
  read -r -p "Full name for git: " USER_NAME
  if [[ -n "$USER_NAME" ]]; then
    archype-state set identity.user_name "$USER_NAME"
    git config --global user.name "$USER_NAME"
  fi
fi

if [[ -z "$(git config user.email)" ]]; then
  read -r -p "Email for git: " USER_EMAIL
  if [[ -n "$USER_EMAIL" ]]; then
    archype-state set identity.user_email "$USER_EMAIL"
    git config --global user.email "$USER_EMAIL"
  fi
fi
