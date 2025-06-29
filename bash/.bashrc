# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# define colors
blk='\[\033[38;5;235m\]' # Gruvbox Dark0_hard
red='\[\033[38;5;124m\]' # Gruvbox Red
grn='\[\033[38;5;106m\]' # Gruvbox Green
ylw='\[\033[38;5;172m\]' # Gruvbox Yellow
blu='\[\033[38;5;66m\]'  # Gruvbox Blue
pur='\[\033[38;5;132m\]' # Gruvbox Purple
cyn='\[\033[38;5;72m\]'  # Gruvbox Aqua
wht='\[\033[38;5;223m\]' # Gruvbox Light1
clr='\[\033[0m\]'        # Reset

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# enable vi mode in bash
set -o vi

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# add date and time formatting to bash history
HISTTIMEFORMAT="%F %T "

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto --group-directories-first --hyperlink=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Move to the parent folder.
alias ..='cd ..;pwd'
# Move up two parent folders.
alias ...='cd ../..;pwd'
# Move up three parent folders.
alias ....='cd ../../..;pwd'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Press c to clear the terminal screen.
alias c='clear'
alias code="flatpak run com.visualstudio.code"

alias d='docker'
alias dc='docker compose'
de() {
  local IFS=' '
  docker exec -it $* bash
}

# Show disk usage in human-readable format
alias duh='du -h --max-depth=1'

alias g='git'
# Add a file to Git.
alias ga='git add'
# Add all files to Git.
alias gaa='git add --all'
# Create a new Git branch and move to the new branch at the same time.
alias gb='git checkout -b'
# Commit changes to the code.
gc() {
  local IFS=' '
  git commit -m "$*"
}
# View the difference.
alias gd='git diff'
# View the Git log.
alias gl='git log --oneline'
# Restore file
alias gr='git restore'
# View Git status.
alias gs='git status'

# Press h to view the bash history.
alias h='history'

# some more ls aliases
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ll='ls -alF --color=auto'
alias sl='ls -alF --color=auto'

alias m='make'
alias s='source ~/.bashrc'

v() {
  if hash nvim 2>/dev/null; then
    nvim "$@"
  elif hash vim 2>/dev/null; then
    vim "$@"
  elif hash im 2>/dev/null; then
    vi "$@"
  fi
}

vim() {
  if hash nvim 2>/dev/null; then
    nvim "$@"
  fi
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

PATH="$HOME/.local/bin:$PATH"

# display current directory as terminal tab name (eg for kitty)
PROMPT_COMMAND='echo -ne "\033]0;$(basename ${PWD})\007"'

# ================ custom functions ==========================================
# ============================================================================
# show top 20 largest files directories in current folder
function largest() {
  du -h -x -s -- * | sort -r -h | head -20
}

function take() {
  mkdir "$1"
  cd "$1"
}

# run starship prompt styles
eval "$(starship init bash)"
eval "$(uv generate-shell-completion bash)"
EDITOR=nvim
