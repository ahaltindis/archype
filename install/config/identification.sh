#!/bin/bash

set -euo pipefail

omarchy-show-logo

STATE_FILE="$HOME/.local/state/omarchy/identification.txt"
mkdir -p "$(dirname "$STATE_FILE")"

# Load state if it exists
if [[ -f "$STATE_FILE" ]]; then
  source "$STATE_FILE"
fi

# Ask for name if not already set
if [[ -z "${OMARCHY_USER_NAME:-}" ]]; then
  OMARCHY_USER_NAME=$(gum input --placeholder "Enter full name" --prompt "Name> ")
fi

# Ask for email if not already set
if [[ -z "${OMARCHY_USER_EMAIL:-}" ]]; then
  OMARCHY_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")
  omarchy-show-done
fi

# Save state back
cat > "$STATE_FILE" <<EOF
OMARCHY_USER_NAME="$OMARCHY_USER_NAME"
OMARCHY_USER_EMAIL="$OMARCHY_USER_EMAIL"
EOF

export OMARCHY_USER_NAME
export OMARCHY_USER_EMAIL

