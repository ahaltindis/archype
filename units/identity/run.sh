#!/bin/bash

USER_NAME=$(gum input --placeholder "Enter full name" --prompt "Name> ")
archype-state set identity.user_name "$USER_NAME"
USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
archype-state set identity.user_email "$USER_EMAIL"

gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
