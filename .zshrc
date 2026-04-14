# =============================================================================
# 0. STARTUP
# =============================================================================
fastfetch


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
# 4. TOOL CONFIGURATIONS
# =============================================================================

# --- FZF ---
# Source fzf bindings (path differs per distro)
for f in /usr/share/fzf/key-bindings.zsh \
         /usr/share/doc/fzf/examples/key-bindings.zsh \
         /usr/share/fzf/shell/key-bindings.zsh; do
    [[ -f "$f" ]] && source "$f" && break
done
for f in /usr/share/fzf/completion.zsh \
         /usr/share/doc/fzf/examples/completion.zsh \
         /usr/share/fzf/shell/completion.zsh; do
    [[ -f "$f" ]] && source "$f" && break
done

FD_EXCLUDES='--exclude .git --exclude node_modules --exclude .cache'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $FD_EXCLUDES"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $FD_EXCLUDES"

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
eval "$(zoxide init zsh --cmd cd)"

# --- Kitty Opacity ---
kitty-opacity() {
  sed -i "s/^background_opacity .*/background_opacity $1/" ~/.config/kitty/kitty.conf
  kill -SIGUSR1 $(pidof kitty)
}


# =============================================================================
# 5. FUNCTIONS
# =============================================================================
# Visual find and open in editor
vf() {
  local out
  out=$(fd --type f --hidden ${=FD_EXCLUDES} \
    --exclude .local --exclude .npm --exclude .cargo \
    --exclude .mozilla --exclude .rustup |
    fzf --multi --preview='bat --style=numbers --color=always --line-range :500 {}' \
        --bind='?:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down')

  [[ -n "$out" ]] && ${EDITOR:-nvim} "${(f)out}"
}


# =============================================================================
# 6. HOOKS
# =============================================================================
# pwd and ls on cd
chpwd() {
    print -P "%F{blue} ▶  %~%f"
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


