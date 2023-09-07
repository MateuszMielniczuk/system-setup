#!/bin/bash

# script is copying all configuration files to git repository
# if files are changed

# define table list with directories to check

dir_list=(
.bashrc
.config/kitty/
.config/nvim/
.config/starship.toml
)

# printf "%s\n" "${dir_list[@]}"

for el in "${dir_list[@]}"
do
# need to check if folder exists otherwise error
# try: `find ./ -depth -print | cpio -pvd newdirpathname`
	cp -vir ~/${el} dotfiles/${el}
done
