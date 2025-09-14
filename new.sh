#!/bin/bash

set -eE

export ARCHYPE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO_FILE="${ARCHYPE_PATH}/logo-archype.txt"
BIN_DIR="${ARCHYPE_PATH}/bin"
LIB_DIR="${ARCHYPE_PATH}/lib"
INSTALL_STATE_DIR="$HOME/.local/state/archype/install"
USER_BIN_DIR="$HOME/.local/bin"

source $LIB_DIR/print.sh

UNITS=("preflight" "identity")

catch_errors() {
  print_error "\nArchype installation failed!"
  print_error "\nThis command halted with exit code $?:"
  print_error "$BASH_COMMAND"
  print_active "\nYou can retry by running: bash $ARCHYPE_PATH/install.sh"
}

trap catch_errors ERR

mkdir -p ${INSTALL_STATE_DIR}
mkdir -p ${USER_BIN_DIR}

declare -a to_install
declare -A installed

check_already_installed() {
  print_title "Checking already installed units.."
  local starting_unit
  local unit
  for unit in "${UNITS[@]}"; do
    if [[ -z "$starting_unit" && ! -f "$INSTALL_STATE_DIR/$unit.done" ]]; then
      starting_unit=$unit
    fi
    if [[ -n "$starting_unit" ]]; then
      to_install+=("$unit")
      rm -f "$INSTALL_STATE_DIR/$unit.done"
      continue
    fi
    print_inactive "=> $unit [already installed]"
  done
  if [[ -z "$starting_unit" ]]; then
    print_active "\nNothing left to install"
    return 0
  elif [[ "$starting_unit" == "${UNITS[0]}" ]]; then
    print_active "\nUnit installation will start with '$starting_unit' unit."
  else
    print_active "\nUnit installation will continue with '$starting_unit' unit."
  fi
  echo ""
  read -p "Press [Enter] to continue or Ctrl+C to cancel..."
}

print_status() {
  clear
  print_logo
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

main() {
  clear
  print_logo
  print_title "Starting installation.."

  copy_unit_install_bin

  check_already_installed

  local unit
  for unit in "${to_install[@]}"; do
    print_status
    archype-unit-install "$unit"
    installed["$unit"]=1
  done

  print_success "\nInstallation completed. Restart the computer!"
}

main
