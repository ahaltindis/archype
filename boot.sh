#!/bin/bash

set -eEo pipefail

ansi_art='
 █████╗ ██████╗  ██████╗██╗  ██╗██╗   ██╗██████╗ ███████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝
███████║██████╔╝██║     ███████║ ╚████╔╝ ██████╔╝█████╗  
██╔══██║██╔══██╗██║     ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  
██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║     ███████╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝'

clear
echo -e "\n$ansi_art\n"
echo -e "\nInstallation starting..."
sleep 1

sudo pacman -Syu --noconfirm --needed git

# Use custom repo if specified, otherwise default to ahaltindis/archype
ARCHYPE_REPO="${ARCHYPE_REPO:-ahaltindis/archype}"

echo -e "\nCloning Archype from: https://github.com/${ARCHYPE_REPO}.git"
rm -rf ~/.local/share/archype/
git clone "https://github.com/${ARCHYPE_REPO}.git" ~/.local/share/archype >/dev/null

# Use custom branch if instructed, otherwise default to main
ARCHYPE_REF="${ARCHYPE_REF:-main}"
if [[ $ARCHYPE_REF != "main" ]]; then
  echo -e "\eUsing branch: $ARCHYPE_REF"
  cd ~/.local/share/archype
  git fetch origin "${ARCHYPE_REF}" && git checkout "${ARCHYPE_REF}"
  cd -
fi

LOGS_DIR=~/.local/log/archype
mkdir -p ${LOGS_DIR}

LOG_FILE=${LOGS_DIR}/install_$(date +%Y%m%d_%H%M%S).log

echo -e "\nInstallation starting..."
~/.local/share/archype/install.sh 2>&1 | tee -a $LOG_FILE

echo "Log saved to: $LOG_FILE"
