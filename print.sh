#!/bin/bash
# print.sh - Simple Bash library for colored output

# Reset
COLOR_RESET="\033[0m"

# Regular Colors
COLOR_BLACK="\033[0;30m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;34m"
COLOR_MAGENTA="\033[0;35m"
COLOR_CYAN="\033[0;36m"
COLOR_WHITE="\033[0;37m"

# Bold
COLOR_BOLD_BLACK="\033[1;30m"
COLOR_BOLD_RED="\033[1;31m"
COLOR_BOLD_GREEN="\033[1;32m"
COLOR_BOLD_YELLOW="\033[1;33m"
COLOR_BOLD_BLUE="\033[1;34m"
COLOR_BOLD_MAGENTA="\033[1;35m"
COLOR_BOLD_CYAN="\033[1;36m"
COLOR_BOLD_WHITE="\033[1;37m"

print_logo()   {
  if [[ -n "$LOGO_FILE" ]]; then
    echo -e "${COLOR_CYAN}";
    cat "$LOGO_FILE"
    echo -e "${COLOR_RESET}";
  fi
}
print_title()     { echo -e "${COLOR_BOLD_CYAN}$*${COLOR_RESET}\n"; }
print_inactive()  { echo -e "${COLOR_BOLD_BLACK}$*${COLOR_RESET}"; }
print_active()    { echo -e "${COLOR_YELLOW}$*${COLOR_RESET}"; }
print_success()   { echo -e "${COLOR_GREEN}$*${COLOR_RESET}"; }
print_error()     { echo -e "${COLOR_RED}$*${COLOR_RESET}"; }
print_normal()    { echo -e "${COLOR_WHITE}$*${COLOR_RESET}"; }
