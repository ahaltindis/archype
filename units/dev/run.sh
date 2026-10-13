#!/bin/bash

# Go: keep its files out of the home folder (the default is ~/go) and send no telemetry. Both are
# stored in ~/.config/go, so every program sees them, not only the shell.
go env -w GOPATH="$HOME/.local/share/go"
go telemetry off
