# Files for quick personal system setup

## Config files:

- bashrc
- kitty terminal
- neovim
- starship

## Dotfiles

1. This require `git` and `stow` to quickly setup all system configurations.
2. Pull this repository.
3. Ensure all existing config is maved or deleted before running script.
4. Run `./push_config.sh` to create symbolic links between repo directory and
   config localization.
5. To modify settings just do this in git repository folder then do `git push`.
   To update config on different machine just run `git pull`.

