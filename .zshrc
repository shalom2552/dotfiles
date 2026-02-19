# =============================================================================
# 1. CORE & PRE-INIT
# =============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =============================================================================
# 2. OH-MY-ZSH SETUP
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
DISABLE_AUTO_TITLE="true"
export ZSH_COMPDUMP="$HOME/.cache/zcompdump-$HOST-$ZSH_VERSION"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# 3. ENVIRONMENT & PATHS
# =============================================================================
export EDITOR=nvim
export VISUAL=nvim

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
# 4. TOOL CONFIGURATIONS
# =============================================================================
# --- FZF ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache'

# FZF visual settings
export FZF_DEFAULT_OPTS="
  --height 100% --layout=reverse --border --margin=5% --padding=2% 
  --prompt='🔍 ' --pointer='▶' --marker='✓' 
  --color=fg:#c0caf5,bg:-1,hl:#bb9af7 
  --color=fg+:#c0caf5,bg+:-1,hl+:#7dcfff 
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"

# --- Zoxide ---
eval "$(zoxide init zsh)"

# =============================================================================
# 5. FUNCTIONS
# =============================================================================
# Set window title to full path (relative to home), removing user@host
function precmd() {
  print -Pn "\e]0;%~\a"
}

# Visual find and open in editor
vf() {
  local out
  out=$(fdfind --type f --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude .cache \
    --exclude .local \
    --exclude .npm \
    --exclude .cargo \
    --exclude .mozilla \
    --exclude .rustup |
    fzf --multi --preview='batcat --style=numbers --color=always --line-range :500 {}' \
        --bind='?:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down')
  
  [[ -n "$out" ]] && ${EDITOR:-nvim} "${(f)out}"
}

# =============================================================================
# 6. ALIASES
# =============================================================================
# Core
alias v='nvim'
alias fm='yazi'
alias q='exit'

# Replacements
alias bat='batcat'
alias ls='eza -G --icons --group-directories-first --git --header'
alias la='eza -G -a --icons --group-directories-first --git --header'
alias ll='eza -l --icons --group-directories-first --git --header'
alias tree='eza -T --icons --git'

# Utilities
alias n='xdg-open .'
alias lock='xdg-screensaver lock'
alias stresstest='glmark2-es2-wayland'
alias todo='grep -rnw --color=auto TODO'
alias shortcuts='batcat --color=always --style=plain ~/.zshrc | grep "alias" | fzf --ansi --border-label=" My Shortcuts "'

# Dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias configlazy='lazygit --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Git
alias ga='git add'
alias gaa='git add --all --verbose'
alias gap='git add --patch'
alias gau='git add --update'
alias gst='git status -u'
alias gdf='git diff'
alias gcm='git commit -m'
alias gco='git checkout'
alias gsw='git switch'
