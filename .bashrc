# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt — simple, visually distinct from zsh
PS1='\[\033[1;33m\][bash]\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] \$ '

# Paths
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# FNM
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env --use-on-cd)"
fi

# Editor
export EDITOR=nvim

# zoxide cd
eval "$(zoxide init bash --cmd cd)"

# Aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
