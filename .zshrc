# =============================================================================
# 1. STARTUP
# =============================================================================
fastfetch


# =============================================================================
# 2. OH-MY-ZSH SETUP
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_AUTO_TITLE="true"
export ZSH_COMPDUMP="$HOME/.cache/zcompdump-$HOST-$ZSH_VERSION"

plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

# ignore ./ and ../ in cd completion
zstyle ':completion:*' special-dirs false


# =============================================================================
# 3. ENVIRONMENT & PATHS
# =============================================================================
export EDITOR=nvim
export VISUAL=nvim
export XDG_TERMINAL_EXEC="kitty"
export TERMINAL="kitty"

# History
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
export LANG=en_US.UTF-8

# System Paths
# Only add paths if the directory exists
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/flutter/bin" ]] && export PATH="$HOME/flutter/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]]  && export PATH="$HOME/.cargo/bin:$PATH"

# FNM Configuration
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd)"
fi


# =============================================================================
# 4. Quality of life
# =============================================================================

# Colorize and scrollable man pages and less
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LESS="--mouse --wheel-lines=3 -R"
export BAT_PAGER="less --mouse --wheel-lines=3 -R"

# Include hidden files/dirs in tab completion
setopt GLOB_DOTS

# Immediate !! expansion on space
bindkey ' ' magic-space


# =============================================================================
# 5. TOOL CONFIGURATIONS
# =============================================================================

# --- FZF ---
command -v fzf &>/dev/null && source <(fzf --zsh)

export FZF_DEFAULT_OPTS="--style full"
FD_EXCLUDES='--exclude .git --exclude node_modules --exclude .cache'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $FD_EXCLUDES"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $FD_EXCLUDES"

# --- Zoxide ---
eval "$(zoxide init zsh --cmd cd)"

# --- Kitty Opacity ---
kitty-opacity() {
  sed -i "s/^background_opacity .*/background_opacity $1/" ~/.config/kitty/kitty.conf
  kill -SIGUSR1 $(pidof kitty)
}


# =============================================================================
# 6. HOOKS
# =============================================================================
# pwd and ls on cd
chpwd() {
    eza -G --icons --group-directories-first --git --header
}

# Set window title to full path (relative to home), removing user@host
autoload -Uz add-zsh-hook
add-zsh-hook precmd () { print -Pn "\e]0;%~\a" }


# =============================================================================
# 7. ALIASES
# =============================================================================
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi


# =============================================================================
# LOCAL CONFIGURATIONS
# =============================================================================
if [ -f ~/.localconf ]; then
    source ~/.localconf
fi

