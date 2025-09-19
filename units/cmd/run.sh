#!/bin/bash

# Set default shell to zsh
if command -v zsh >/dev/null 2>&1; then
    echo "Setting default shell to zsh.."
    USER_NAME=$(whoami)
    chsh -s "$(command -v zsh)" "$USER_NAME"

    if [ $? -eq 0 ]; then
        echo "Default shell changed to zsh for user $USER_NAME."
    else
        echo "Failed to change default shell. You might need to run this script with sudo."
        exit 1
    fi
else
    echo "zsh is not installed."
    exit 1
fi

