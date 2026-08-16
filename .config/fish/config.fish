# ~/.config/fish/config.fish

# =============================================================================
# ENVIRONMENT
# =============================================================================
# .zshenv is bash-parseable, fenv imports it so env stays single-source
type -q fenv && fenv source $HOME/.zshenv

if status is-interactive

    # =========================================================================
    # STARTUP
    # =========================================================================
    set -g fish_greeting
    fastfetch -c ~/.config/fastfetch/minimal.jsonc

    eval "$(starship init fish)"

    # =========================================================================
    # HOOKS
    # =========================================================================
    function __ls_on_cd --on-variable PWD
        eza -G --icons --group-directories-first --git --header
    end

    function fish_title
        prompt_pwd
    end

    # =========================================================================
    # TOOLS
    # =========================================================================
    type -q fzf && fzf --fish | source
    type -q fnm && fnm env --use-on-cd --shell fish | source
    type -q zoxide && zoxide init fish --cmd cd | source

    # =========================================================================
    # SOURCES
    # =========================================================================
    test -f $ZDOTDIR/.aliases && source $ZDOTDIR/.aliases

end
