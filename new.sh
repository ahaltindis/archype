#!/bin/bash

set -eE

source ./print.sh

ARCHYPE_PATH="."
LOGO_FILE="${ARCHYPE_PATH}/logo-archype.txt"
UNITS_DIR="${ARCHYPE_PATH}/units"
INSTALL_STATE_DIR="$HOME/.local/state/archype/install"
USER_BIN_DIR="$HOME/.local/bin"

UNITS=("preflight")

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
    print_active "\nNothing left to install, bye!"
    exit 0
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

install_packages() {
  local PKG_FILE="$1"
  local PKG_MANAGER="$2"

  if [ -f "$PKG_FILE" ]; then
    print_title "  -> Installing packages from $PKG_FILE..."
    # Read the file line by line and install each package.
    while IFS= read -r package; do
      # Trim leading/trailing whitespace from the package name.
      package=$(echo "$package" | xargs)
      if [ -n "$package" ]; then
        print_title "    -> Installing: $package"
        if [ "$PKG_MANAGER" == "pacman" ]; then
          sudo pacman -S --noconfirm "$package" || print_active "Warning: Failed to install $package."
        elif [ "$PKG_MANAGER" == "aur" ]; then
          yay -S --noconfirm "$package" || print_active "Warning: Failed to install $package."
        fi
      fi
    done < "$PKG_FILE"
  fi
}

install_unit() {
  UNIT="$1"
  UNIT_PATH="$UNITS_DIR/$unit"
  if [ ! -d "$UNIT_PATH" ]; then
    print_error "Error: Unit directory '$UNIT_PATH' not found."
    exit 1
  fi

  # Package Installation
  install_packages "$UNIT_PATH/packages.pacman" "pacman"
  install_packages "$UNIT_PATH/packages.aur" "aur"

  # Copy binary files
  if [[ -d "$UNIT_PATH/bin" ]]; then
    print_title "  -> Copying binary files from $UNIT_PATH/bin"
    while IFS= read -r file; do
      print_normal "Copying: $file -> $USER_BIN_DIR/"
      cp -a "$file" "$USER_BIN_DIR/"
    done < <(find "$UNIT_PATH/bin" -maxdepth 1 -type f -executable)
  fi

  # Run unit scripts
  if [[ -f "$UNIT_PATH/run.sh" ]]; then
    print_title "  -> Executing $UNIT_PATH/run.sh"
    source $UNIT_PATH/run.sh
  fi

  print_success "$unit installed successfully."
  sleep 1
}

main() {
  local unit
  for unit in "${to_install[@]}"; do
    print_status
    install_unit "$unit"
    installed["$unit"]=1
    touch "$INSTALL_STATE_DIR/$unit.done"
  done

  print_status
}

clear
print_logo
print_title "Starting installation.."
check_already_installed
main
print_success "\n Installation completed. Restart the computer!"
