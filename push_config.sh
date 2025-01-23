#!/bin/bash

# add symbolic links to to packages from this directory to home folder
# requires `stow` package to be installed on the system

mkdir ~/backups_stow
mv ~/.bashrc ~/backups_stow
mv ~/.config/kitty/kitty.conf ~/backups_stow
mv ~/.config/nvim ~/backups_stow
mv ~/.config/starship.toml ~/backups_stow

stow -v --defer push_config.sh -t ~/ */
