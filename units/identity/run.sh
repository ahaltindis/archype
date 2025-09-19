#!/bin/bash

USER_NAME=$(gum input --placeholder "Enter full name" --prompt "Name> ")
if [[ -n "$USER_NAME" ]]; then
  archype-state set identity.user_name "$USER_NAME"
fi
USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
if [[ -n "$USER_EMAIL" ]]; then
  archype-state set identity.user_email "$USER_EMAIL"
fi

gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
