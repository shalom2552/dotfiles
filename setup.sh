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
# 0. Detect distro
# ---------------------------------------------------
detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v apt &>/dev/null; then
        DISTRO="debian"
    else
        error "Unsupported distro. This script supports Arch-based and Debian/Ubuntu-based systems."
    fi
    info "Detected distro: $DISTRO"
}

# ---------------------------------------------------
# 1. Check we're in the right place
# ---------------------------------------------------
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    error "Expected dotfiles repo at $DOTFILES_DIR. Clone it first:\n  git clone --recurse-submodules https://github.com/shalom2552/dotfiles.git ~/dotfiles"
fi

cd "$DOTFILES_DIR"
detect_distro

# ---------------------------------------------------
# 2. Install system packages
# ---------------------------------------------------
install_arch() {
    info "Installing packages (pacman)..."
    sudo pacman -S --needed --noconfirm \
        git zsh stow curl wget unzip \
        fd bat eza btop ripgrep zoxide \
        tmux fzf yazi fastfetch lazygit \
        kitty neovim chromium \
        imagemagick ffmpeg \
        python jq
}

install_debian() {
    info "Installing packages (apt)..."
    sudo apt update
    sudo apt install -y \
        git zsh stow curl wget unzip gnupg \
        software-properties-common locales libfuse2 \
        fd-find bat btop ripgrep \
        tmux fzf kitty chromium \
        imagemagick ffmpeg \
        python3 jq fontconfig

    # Generate locales
    sudo locale-gen en_US.UTF-8

    # fd-find and bat install with different binary names on Debian/Ubuntu
    # Create symlinks so configs and aliases work the same way
    if [ ! -L "$HOME/.local/bin/fd" ] && command -v fdfind &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        info "Symlinked fdfind → fd"
    fi
    if [ ! -L "$HOME/.local/bin/bat" ] && command -v batcat &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        info "Symlinked batcat → bat"
    fi

    # Tools not in default Ubuntu repos — install from external sources
    install_debian_extras
}

install_debian_extras() {

    # neovim — AppImage (Ubuntu repos have outdated version)
    if ! command -v nvim &>/dev/null; then
        info "Installing Neovim (AppImage)..."
        curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
        chmod u+x nvim-linux-x86_64.appimage
        sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
    fi

    # eza
    if ! command -v eza &>/dev/null; then
        info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # zoxide
    if ! command -v zoxide &>/dev/null; then
        info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # fastfetch
    if ! command -v fastfetch &>/dev/null; then
        info "Installing fastfetch..."
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
        sudo apt update
        sudo apt install -y fastfetch
    fi

    # yazi — binary from GitHub releases
    if ! command -v yazi &>/dev/null; then
        info "Installing yazi..."
        YAZI_VERSION=$(curl -sS https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r '.tag_name')
        curl -fLO "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
        unzip -o yazi-x86_64-unknown-linux-gnu.zip
        sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
        sudo mv yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
        rm -rf yazi-x86_64-unknown-linux-gnu yazi-x86_64-unknown-linux-gnu.zip
    fi

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -sS https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        curl -fLO "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" lazygit
        sudo mv lazygit /usr/local/bin/
        rm -f "lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    fi
}

if [ "$DISTRO" = "arch" ]; then
    install_arch
else
    install_debian
fi

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
# 3.5 Tmux Plugin Manager (TPM)
# ---------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    info "Installing tmux plugins..."
    tmux new-session -d -s _setup \
        "sleep 3 \
        && ~/.config/tmux/plugins/tpm/bin/install_plugins \
        && tmux kill-session -t _setup"
else
    info "TPM already installed, skipping."
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
# 6. Initialize submodules (Neovim config)
# ---------------------------------------------------
info "Initializing git submodules..."
git submodule update --init --recursive

# ---------------------------------------------------
# 7. Symlink configs with Stow
# ---------------------------------------------------
info "Symlinking configs with Stow..."

# Skip backup if stow was already run (symlinks already exist)
if [ -L "$HOME/.zshrc" ] && [ "$(readlink "$HOME/.zshrc")" = "dotfiles/.zshrc" ]; then
    info "Stow already configured, re-stowing..."
    stow -R .
else
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

    # Stow all files
    stow .
fi

info "All configs symlinked!"

# ---------------------------------------------------
# 8. Set Zsh as default shell
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
