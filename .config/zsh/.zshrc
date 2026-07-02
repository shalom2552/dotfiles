# ~/.config/zsh/.zshrc

# =============================================================================
# STARTUP
# =============================================================================
fastfetch

# =============================================================================
# OH-MY-ZSH
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_AUTO_TITLE="true"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zcompdump-$HOST-$ZSH_VERSION"

plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

# =============================================================================
# SHELL
# =============================================================================
zstyle ':completion:*' special-dirs false   # ignore ./ and ../ in cd completion
zstyle ':completion:*' menu select                       # arrow-key menu on tab
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # colored completion lists

setopt NUMERIC_GLOB_SORT                    # sort glob results numerically
setopt EXTENDED_GLOB                        # powerful glob qualifiers (#, ~, ^)
setopt INTERACTIVE_COMMENTS                 # allow # comments when typing interactively
setopt AUTO_PUSHD                           # cd pushes old dir onto stack
setopt PUSHD_IGNORE_DUPS                    # no duplicate stack entries
setopt GLOB_DOTS                            # include hidden files/dirs in tab completion
setopt AUTO_CD
setopt NO_BEEP

# =============================================================================
# HISTORY
# =============================================================================
_ZSH_STATE_DIR="$XDG_STATE_HOME/zsh"
[[ -d $_ZSH_STATE_DIR ]] || mkdir -p "$_ZSH_STATE_DIR"
export HISTFILE="$_ZSH_STATE_DIR/history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt SHARE_HISTORY                    # share history between sessions
setopt EXTENDED_HISTORY                 # save timestamp + duration per command
setopt HIST_IGNORE_DUPS                 # ignore duplicate entries in the history list
setopt HIST_IGNORE_SPACE                # ignore commands that start with a space
setopt HIST_EXPIRE_DUPS_FIRST           # expire duplicates first when trimming history
setopt HIST_FIND_NO_DUPS                # don't find duplicated entries in the history file
setopt HIST_VERIFY                      # verify command before executing it

# =============================================================================
# HOOKS
# =============================================================================
bindkey ' ' magic-space   # immediate !! expansion on space
command -v fnm &>/dev/null && eval "$(fnm env --use-on-cd)"

# pwd and ls on cd
chpwd() { eza -G --icons --group-directories-first --git --header }

# set window title to full path (relative to home), removing user@host
autoload -Uz add-zsh-hook
add-zsh-hook precmd () { print -Pn "\e]0;%~\a" }

# =============================================================================
# TOOLS
# =============================================================================

# --- FZF ---
command -v fzf &>/dev/null && source <(fzf --zsh)
FD_EXCLUDES='--exclude .git --exclude node_modules --exclude .cache'
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow $FD_EXCLUDES"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow $FD_EXCLUDES"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--style full --preview 'bat --style=numbers --color=always {}'"

# --- Zoxide ---
eval "$(zoxide init zsh --cmd cd)"

# =============================================================================
# FILES
# =============================================================================

# aliases
if [ -f "$ZDOTDIR/.aliases" ]; then
    source "$ZDOTDIR/.aliases"
fi

# per-machine local overrides (untracked)
if [ -f "$ZDOTDIR/.localconf" ]; then
    source "$ZDOTDIR/.localconf"
fi
