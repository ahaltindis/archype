#!/bin/bash

# Npm is needed for nvim lspconfig plugin
mise use --global node@latest

# Yazi: the current Archype theme as the "archype" flavor (picked in ~/.config/yazi/theme.toml)
mkdir -p ~/.config/yazi/flavors/archype.yazi
ln -snf ~/.config/archype/current/theme/yazi.toml ~/.config/yazi/flavors/archype.yazi/flavor.toml

# wipsync: its service starts at login, and is restarted (or started, if it isn't running) so that an
# update takes effect. Until `wipsync init` is run by hand, it only logs that the repository is not set.
systemctl --user daemon-reload
systemctl --user enable wipsync.service
systemctl --user restart wipsync.service
