# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# store cachein hiden dir 
export ZSH_COMPDUMP=$HOME/.cache/zcompdump-$HOST-$ZSH_VERSION 

DISABLE_AUTO_TITLE="true"
source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- FNM  (insetd of nvm) ---
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# system exports
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Initialize fzf keybindings (Ctrl+R, Ctrl+T) and auto-completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Set window title to full path (relative to home), removing user@host
function precmd() {
  print -Pn "\e]0;%~\a"
}

# Set nvim as main editor
export EDITOR=nvim
export VISUAL=nvim

# --- FZF Command Overrides ---
# Use fdfind to respect .gitignore and include hidden files (like .config)
# -E excludes specific folders to keep search clean
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git --exclude node_modules --exclude .cache'
# Set fzf as a popup and alias f to use it and open nvim on output
export FZF_DEFAULT_OPTS="
  --height 100% --layout=reverse --border --margin=5% --padding=2% 
  --prompt='🔍 ' --pointer='▶' --marker='✓' 
  --color=fg:#c0caf5,bg:-1,hl:#bb9af7 
  --color=fg+:#c0caf5,bg+:-1,hl+:#7dcfff 
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"

vf() {
  local out
  # Removed '--follow' (Speed Killer #1)
  # Added exclusions for massive cache folders (Speed Killer #2)
  out=$(fdfind --type f --hidden --exclude .git \
    --exclude node_modules \
    --exclude .cache \
    --exclude .local \
    --exclude .npm \
    --exclude .cargo \
    --exclude .mozilla \
    --exclude .rustup \
    | fzf --multi --preview='batcat --style=numbers --color=always --line-range :500 {}' --bind='?:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down')
  
  [[ -n "$out" ]] && ${EDITOR:-nvim} "${(f)out}"
}

# --- Aliases ---
# List all aliases with color and search
alias shortcuts='batcat --color=always --style=plain ~/.zshrc | grep "alias" | fzf --ansi --border-label=" My Shortcuts "'

# ls as eza
alias ls='eza -G --icons --group-directories-first --git --header'
alias la='eza -G -a --icons --group-directories-first --git --header'
alias ll='eza -l --icons --group-directories-first --git --header'
alias tree='eza -T --icons --git'

# Dotfiles Management
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Git Aliases
alias ga='git add'
alias gaa='git add --all --verbose'
alias gap='git add --patch'
alias gau='git add --update'
alias gst='git status -u'
alias gdf='git diff'
alias gcm='git commit -m'

alias n='xdg-open .'
alias bat='batcat'
alias v='nvim'
alias fm='yazi'
alias lock='xdg-screensaver lock'

alias stresstest='glmark2-es2-wayland'
alias todo='grep -rnw --color=auto TODO'
alias q='exit'

