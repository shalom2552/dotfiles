# ~/.zshenv

# ========== XDG BASE DIRS ==========
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ========== ZSH ==========
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# ========== ENVIRONMENT ========== 
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL="kitty"
export XDG_TERMINAL_EXEC="kitty"
export LANG=en_US.UTF-8

# ========== GPG ==========
export GPG_TTY=$(tty)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# ========== PATH ==========
[[ -d "$HOME/.local/bin" ]]  && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/flutter/bin" ]] && export PATH="$HOME/flutter/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]]  && export PATH="$HOME/.cargo/bin:$PATH"

FNM_PATH="$HOME/.local/share/fnm"
[[ -d "$FNM_PATH" ]] && export PATH="$FNM_PATH:$PATH"

# ========== PAGER / MAN ==========
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LESS="--mouse --wheel-lines=3 -R"
export BAT_PAGER="less --mouse --wheel-lines=3 -R"
