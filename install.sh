#!/bin/bash

set -eE

export ARCHYPE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO_FILE="${ARCHYPE_PATH}/logo-archype.txt"
BIN_DIR="${ARCHYPE_PATH}/bin"
INSTALL_STATE_DIR="$HOME/.local/state/archype/install"
LOGS_DIR="$HOME/.local/log/archype"
LOG_FILE="$LOGS_DIR/install_$(date +%Y%m%d_%H%M%S).log"
USER_BIN_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/archype"

export PATH="$USER_BIN_DIR:$PATH"

source ${ARCHYPE_PATH}/lib/print.sh

UNITS=("preflight" "system" "cmd" "hyprland" "boot" "cmd-essentials")

catch_errors() {
  local code=$?
  rm -rf ${TMP_DIR}
  print_error "\nArchype installation failed!"
  print_error "\nThis command halted with exit code $code:"
  print_error "$BASH_COMMAND"
  print_active "\nYou can retry by running: bash $ARCHYPE_PATH/install.sh"
}

# Everything printed from here on also goes to the log file; the screen keeps showing it
start_logging() {
  mkdir -p "$LOGS_DIR"
  exec 3>&1 4>&2
  exec > >(tee "$LOG_FILE") 2>&1
  TEE_PID=$!
}

# Gives the terminal back and lets tee write the last lines before the script exits
stop_logging() {
  [[ -n "$TEE_PID" ]] || return 0
  exec >&3 2>&4 3>&- 4>&-
  # Not `wait`: a program left running by a unit could hold the pipe open forever
  local i
  for i in {1..20}; do
    kill -0 "$TEE_PID" 2>/dev/null || break
    sleep 0.1
  done
  echo "Log saved to: $LOG_FILE"
}

trap catch_errors ERR

# Ask for the sudo password once, then keep it fresh so a long install never stops to ask again
start_sudo_keepalive() {
  sudo -v
  # Output to /dev/null: its sleep would otherwise hold the log pipe open after the install ends
  while kill -0 $$ 2>/dev/null; do
    sudo -n -v
    sleep 60
  done >/dev/null 2>&1 &
  SUDO_KEEPALIVE_PID=$!
}

stop_sudo_keepalive() {
  [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
  return 0
}

finish() {
  stop_sudo_keepalive
  stop_logging
}

trap finish EXIT

mkdir -p ${INSTALL_STATE_DIR}
mkdir -p ${USER_BIN_DIR}
mkdir -p ${TMP_DIR}

declare -a to_install
declare -A installed

check_already_installed() {
  print_title "Checking already installed units.."
  local starting_unit
  local unit
  for unit in "${UNITS[@]}"; do
    if [[ ! -f "$INSTALL_STATE_DIR/$unit.done" ]]; then
      starting_unit=$unit
      break
    fi
  done

  # Everything installed: re-applying all units is how Archype updates
  if [[ -z "$starting_unit" ]]; then
    to_install=("${UNITS[@]}")
    print_active "\nAll units are installed. Checking each one for updates; your config edits are kept."
    return 0
  fi

  local resuming=""
  for unit in "${UNITS[@]}"; do
    if [[ "$unit" == "$starting_unit" ]]; then
      resuming=1
    fi
    if [[ -n "$resuming" ]]; then
      to_install+=("$unit")
      rm -f "$INSTALL_STATE_DIR/$unit.done"
    else
      print_inactive "=> $unit [already installed]"
    fi
  done

  if [[ "$starting_unit" == "${UNITS[0]}" ]]; then
    print_active "\nUnit installation will start with '$starting_unit' unit."
  else
    print_active "\nUnit installation will continue with '$starting_unit' unit."
  fi
}

print_status() {
  print_title "-----------------------------"
  local unit
  for unit in "${to_install[@]}"; do
    if [[ ${installed[$unit]} ]]; then
      print_success "=> $unit [installed]"
    else
      print_active "=> $unit [installing..]"
      break
    fi
  done
  print_title "-----------------------------"
}

copy_unit_install_bin() {
  local file="archype-unit-install"
  print_title "  -> Linking $BIN_DIR/$file -> $USER_BIN_DIR/"
  ln -sf "$BIN_DIR/$file" "$USER_BIN_DIR/"
}

install_prerequisites() {
  local -a packages
  packages=("jq")

  local pkg
  for pkg in "${packages[@]}"; do
    if ! command -v $pkg &>/dev/null; then
      print_title "  -> Installing prerequisite package '$pkg'"
      sudo pacman -Syu --noconfirm --needed "$pkg"
    fi
  done
}

main() {
  clear
  start_logging
  print_logo
  print_title "Starting installation.."

  start_sudo_keepalive

  copy_unit_install_bin

  install_prerequisites

  check_already_installed

  local unit
  for unit in "${to_install[@]}"; do
    print_status
    archype-unit-install "$unit"
    installed["$unit"]=1
  done

  rm -rf ${TMP_DIR}
  print_success "\nInstallation completed. Restart the computer!"
}

main
