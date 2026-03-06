# ~/.config/fish/config.fish

# vi key bindings
fish_vi_key_bindings

# PATH
fish_add_path $HOME/.local/bin

# Environment variables
set -x EDITOR nvim

# LS_COLORS via dircolors
if command -q dircolors
    if test -r ~/.dircolors
        set -x LS_COLORS (dircolors -b ~/.dircolors | string match -rg "LS_COLORS='([^']+)'")
    else
        set -x LS_COLORS (dircolors -b | string match -rg "LS_COLORS='([^']+)'")
    end
end

# Navigation
alias .. 'cd ..;pwd'
alias ... 'cd ../..;pwd'
alias .... 'cd ../../..;pwd'

# General
alias c clear
alias code 'flatpak run com.visualstudio.code'
alias h history
alias m make
alias s 'source ~/.config/fish/config.fish'

# ls
alias ls 'ls --color=auto --group-directories-first --hyperlink=auto'
alias la 'ls -A --color=auto'
alias l 'ls -CF --color=auto'
alias ll 'ls -alF --color=auto'
alias sl 'ls -alF --color=auto'

# grep
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'

# Disk usage
alias duh 'du -h --max-depth=1'

# Docker
alias d docker
alias dc 'docker compose'
alias dps 'docker ps'

# Git
alias g git
alias ga 'git add'
alias gaa 'git add --all'
alias gb 'git checkout -b'
alias gd 'git diff'
alias gl 'git log --oneline'
alias gr 'git restore'
alias grs 'git restore --staged'
alias gs 'git status'

# ================ functions =================================================

function de
    docker exec -it $argv bash 2>/dev/null; or docker exec -it $argv sh
end

function gc
    git commit -m (string join ' ' $argv)
end

function v
    if command -q nvim
        nvim $argv
    else if command -q vim
        vim $argv
    else if command -q vi
        vi $argv
    end
end

function vim
    if command -q nvim
        nvim $argv
    end
end

function largest
    du -h -x -s -- * | sort -r -h | head -20
end

function take
    mkdir $argv[1]
    cd $argv[1]
end

# ================ completions / prompt ======================================

starship init fish | source
uv generate-shell-completion fish | source
export GPG_TTY=$(tty)
