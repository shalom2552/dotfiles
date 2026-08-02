# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt
PS1='\[\033[0;33m\][bash]\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] \$ '

# Editor
export EDITOR=nvim

# Multi unicode
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Paths
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# FNM
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# zoxide as cd
eval "$(zoxide init bash --cmd cd)"

# sources
_load() { [ -f "$1" ] && source "$1"; }

_load "$HOME/.zshenv"           # zsh env
_load "$ZDOTDIR/.aliases"       # aliases
_load "$ZDOTDIR/.localconf"     # local config

unset -f _load

