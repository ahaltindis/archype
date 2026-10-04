#!/bin/bash

# Npm is needed for nvim lspconfig plugin
mise use --global node@latest

# Yazi: the current Archype theme as the "archype" flavor (picked in ~/.config/yazi/theme.toml)
mkdir -p ~/.config/yazi/flavors/archype.yazi
ln -snf ~/.config/archype/current/theme/yazi.toml ~/.config/yazi/flavors/archype.yazi/flavor.toml
