#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ---------------------------------------------------
# 1. Check we're in the right place
# ---------------------------------------------------
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    error "Expected dotfiles repo at $DOTFILES_DIR. Clone it first:\n  git clone https://github.com/shalom2552/dotfiles-stow.git ~/dotfiles"
fi

cd "$DOTFILES_DIR"

# ---------------------------------------------------
# 2. Install system packages
# ---------------------------------------------------
info "Installing system packages..."
sudo pacman -S --needed --noconfirm \
    git zsh stow curl unzip \
    fd bat eza btop ripgrep zoxide \
    tmux fzf yazi fastfetch \
    kitty \
    imagemagick ffmpeg \
    python jq

# ---------------------------------------------------
# 3. Shell environment (Oh My Zsh + Plugins)
# ---------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    # RUNZSH=no  — don't switch to zsh mid-script
    # CHSH=no    — we handle chsh ourselves at the end
    # KEEP_ZSHRC=yes — don't overwrite .zshrc (we stow ours later)
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed, skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    info "zsh-autosuggestions already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "zsh-syntax-highlighting already installed, skipping."
fi

# ---------------------------------------------------
# 4. Fonts
# ---------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -qi "JetBrainsMono"; then
    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm -f JetBrainsMono.zip
    fc-cache -fv
    cd "$DOTFILES_DIR"
else
    info "JetBrainsMono Nerd Font already installed, skipping."
fi

# ---------------------------------------------------
# 5. Node Version Manager (fnm)
# ---------------------------------------------------
if ! command -v fnm &>/dev/null; then
    info "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash

    # Source fnm for current session (installer adds it to shell rc for future sessions)
    FNM_PATH="$HOME/.local/share/fnm"
    if [ ! -d "$FNM_PATH" ]; then
        FNM_PATH="$HOME/.fnm"
    fi
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env)"

    fnm install --lts
else
    info "fnm already installed, skipping."
fi

# ---------------------------------------------------
# 6. Symlink configs with Stow
# ---------------------------------------------------
info "Symlinking configs with Stow..."

# Back up any existing files that would conflict
backup_needed=false
while IFS= read -r file; do
    target="$HOME/$file"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        backup_needed=true
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        mv "$target" "$BACKUP_DIR/$file"
        warn "Backed up $target → $BACKUP_DIR/$file"
    fi
done < <(find . -not -path './.git/*' -not -name '.git' \
              -not -name 'setup.sh' -not -name 'README.md' \
              -not -name 'LICENSE' -not -name '.gitignore' \
              -not -name 'CHEATSHEET.md' \
              -type f | sed 's|^\./||')

if [ "$backup_needed" = true ]; then
    info "Existing configs backed up to $BACKUP_DIR"
fi

# Oh My Zsh installer may have created a default .zshrc — remove it before stowing
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    warn "Removing default .zshrc (ours will be symlinked)"
    mkdir -p "$BACKUP_DIR"
    mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" 2>/dev/null || rm "$HOME/.zshrc"
fi

stow .

info "All configs symlinked!"

# ---------------------------------------------------
# 7. Set Zsh as default shell
# ---------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
fi

# ---------------------------------------------------
# Done
# ---------------------------------------------------
echo ""
info "Setup complete!"
info "Run 'exec zsh' to start your new shell, then 'p10k configure' to set up the prompt."
echo ""
