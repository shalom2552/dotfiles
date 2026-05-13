#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
VERSION="2.4.3"

# Ensure ~/.local/bin is on PATH so command -v checks find tools installed there
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------
# Helpers
# ---------------------------------------------------
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

on_error() {
    echo -e "\n${RED}[ERROR]${NC} Setup failed at line $LINENO.\n"
    echo -e "  Try run setup manually:\n"
    echo -e "    cd ~/dotfiles && ./install.sh\n"
    exit 1
}
trap on_error ERR

# ---------------------------------------------------
# Detect distro
# ---------------------------------------------------
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt &>/dev/null; then
    DISTRO="debian"
else
    DISTRO="Unknown"
fi

# ---------------------------------------------------
# 0. Welcome
# ---------------------------------------------------
if [ "${DOT_REEXECED:-0}" != "1" ] && [ "${SKIP_WELCOME:-0}" != "1" ]; then
echo -e "${CYAN}"
echo "     ███████╗██╗██╗     ███████╗███████╗"
echo "     ██╔════╝██║██║     ██╔════╝██╔════╝"
echo "     █████╗  ██║██║     █████╗  ███████╗"
echo "     ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██╗██║     ██║███████╗███████╗███████║"
echo "  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo -e "${NC}"
echo -e "  ${BOLD}Shalom's Dotfiles${NC}  ${CYAN}v${VERSION}${NC}"
echo -e "  ${CYAN}github.com/shalom2552/dotfiles${NC}"
echo ""
echo -e "  Installing to: ${GREEN}$HOME${NC}"
echo -e "  Detected:      ${GREEN}$DISTRO${NC}"
echo -e "  Est. time:     ${GREEN}~5-10 min${NC}"
echo ""
echo -e "  ${BOLD}── What's included ──${NC}"
echo "    • Zsh + Oh My Zsh + Powerlevel10k"
echo "    • Neovim (LazyVim), tmux, kitty"
echo "    • CLI tools: yazi, btop, lazygit, fzf, zoxide, pulsemixer, ..."
echo "    • fnm (Node), JetBrainsMono Nerd Font"
echo "    • Configs symlinked via Stow"
echo ""
read -r -p "  Proceed? [n/Y] " confirm
echo ""
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "  Aborted."
    exit 0
fi
fi

# ---------------------------------------------------
# 1. Install prerequisites
# ---------------------------------------------------
log_info "Starting installation..."
if ! command -v git &>/dev/null; then
    log_info "Installing git..."
    if [ "$DISTRO" = "arch" ]; then
        sudo pacman -S --noconfirm git
    elif [ "$DISTRO" = "debian" ]; then
        sudo apt update && sudo apt install -y git
    else
        log_error "Unsupported distro."
    fi
else
    log_info "git already installed, skipping."
fi

# ---------------------------------------------------
# 2. Clone dotfiles
# ---------------------------------------------------
IS_UPDATE=false
if [ "${DOT_REEXECED:-0}" = "1" ]; then
    IS_UPDATE=true
elif [ -d "$DOTFILES_DIR/.git" ]; then
    log_info "~/dotfiles already cloned, checking for updates..."
    cd "$DOTFILES_DIR"
    pull_out=$(git pull --rebase 2>&1) || log_error "Pull failed."
    if echo "$pull_out" | grep -q "Already up to date\|Current branch.*is up to date"; then
        log_info "Dotfiles already up to date."
    else
        log_info "Dotfiles updated."
    fi
    log_info "Re-launching updated script..."
    exec env DOT_REEXECED=1 bash "$DOTFILES_DIR/install.sh"
else
    if [ -d "$DOTFILES_DIR" ]; then
        log_warn "~/dotfiles exists. Backing up to ~/dotfiles.bak..."
        mv "$DOTFILES_DIR" "$HOME/dotfiles.bak"
    fi
    log_info "Cloning dotfiles repository..."
    git clone --recurse-submodules https://github.com/shalom2552/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# ---------------------------------------------------
# 3. Install system packages
# ---------------------------------------------------
install_arch() {
    log_info "Installing packages (pacman)..."

    packages=(
        git zsh stow curl wget unzip
        fd bat eza btop ripgrep zoxide
        tmux fzf yazi fastfetch lazygit cliphist
        kitty neovim chromium pulsemixer
        imagemagick ffmpeg
        python jq duf
    )

    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            log_info "Installing $pkg..."
            sudo pacman -S --needed --noconfirm "$pkg" || log_warn "Failed to install $pkg, skipping..."
        else
            log_info "$pkg already installed, skipping."
        fi
    done
}

install_debian() {
    log_info "Installing packages (apt)..."
    if [ "$IS_UPDATE" = false ]; then
        sudo add-apt-repository -y universe 2>/dev/null || true
    fi
    sudo apt update

    packages=(
        git zsh stow curl wget unzip gnupg
        software-properties-common locales
        fd-find bat btop ripgrep
        tmux fzf kitty chromium-browser cliphist pulsemixer
        imagemagick ffmpeg fontconfig
        python3 jq
        libgtk-3-bin
    )

    for pkg in "${packages[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
            log_info "Installing $pkg..."
            sudo apt install -y "$pkg" || log_warn "Failed to install $pkg, skipping..."
        else
            log_info "$pkg already installed, skipping."
        fi
    done

    # Generate locales
    if command -v locale-gen &>/dev/null; then
        if ! locale -a 2>/dev/null | grep -qi "en_US.utf8\|en_US.UTF-8"; then
            sudo locale-gen en_US.UTF-8
        fi
    else
        log_warn "locale-gen not found, skipping locale generation"
    fi

    # fd-find and bat install with different binary names on Debian/Ubuntu
    # Create symlinks so configs and aliases work the same way
    if [ ! -L "$HOME/.local/bin/fd" ] && command -v fdfind &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        log_info "Symlinked fdfind → fd"
    fi
    if [ ! -L "$HOME/.local/bin/bat" ] && command -v batcat &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        log_info "Symlinked batcat → bat"
    fi

    # Tools not in default Ubuntu repos — install from external sources
    install_debian_extras
}

install_debian_extras() {
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    # neovim — tarball (Ubuntu repos have outdated version; no FUSE needed, works everywhere)
    if ! command -v nvim &>/dev/null; then
        log_info "Installing Neovim..."
        curl -fLo "$TMP_DIR/nvim-linux-x86_64.tar.gz" \
            https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo tar xzf "$TMP_DIR/nvim-linux-x86_64.tar.gz" -C /usr/local --strip-components=1
    fi

    # eza
    if ! command -v eza &>/dev/null; then
        log_info "Installing eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # zoxide
    if ! command -v zoxide &>/dev/null; then
        log_info "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # fastfetch
    if ! command -v fastfetch &>/dev/null; then
        log_info "Installing fastfetch..."
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
        sudo apt update
        sudo apt install -y fastfetch
    fi

    # yazi — binary from GitHub releases
    if ! command -v yazi &>/dev/null; then
        log_info "Installing yazi..."
        YAZI_VERSION=$(curl -sS https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r '.tag_name')
        curl -fLo "$TMP_DIR/yazi.zip" \
            "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
        unzip -o "$TMP_DIR/yazi.zip" -d "$TMP_DIR"
        sudo mv "$TMP_DIR/yazi-x86_64-unknown-linux-gnu/yazi" /usr/local/bin/
        sudo mv "$TMP_DIR/yazi-x86_64-unknown-linux-gnu/ya" /usr/local/bin/
    fi

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        log_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -sS https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        curl -fLo "$TMP_DIR/lazygit.tar.gz" \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR" lazygit
        sudo mv "$TMP_DIR/lazygit" /usr/local/bin/
    fi

    if ! command -v duf &>/dev/null; then
        log_info "Installing duf..."
        DUF_VERSION=$(curl -sS https://api.github.com/repos/muesli/duf/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        curl -fLo "$TMP_DIR/duf.tar.gz" \
            "https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_x86_64.tar.gz"
        tar xf "$TMP_DIR/duf.tar.gz" -C "$TMP_DIR" duf
        sudo mv "$TMP_DIR/duf" /usr/local/bin/
    fi

}

if [ "$DISTRO" = "arch" ]; then
    install_arch
elif [ "$DISTRO" = "debian" ]; then
    install_debian
else
    log_error "Unsupported distro."
fi

# ---------------------------------------------------
# 4. Shell environment (Oh My Zsh + Plugins)
# ---------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing Oh My Zsh..."
    # RUNZSH=no  — don't switch to zsh mid-script
    # CHSH=no    — we handle chsh ourselves at the end
    # KEEP_ZSHRC=yes — don't overwrite .zshrc (we stow ours later)
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log_info "Oh My Zsh already installed, skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    log_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
else
    log_info "Powerlevel10k already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    log_info "zsh-autosuggestions already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    log_info "zsh-syntax-highlighting already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    log_info "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab \
        "$ZSH_CUSTOM/plugins/fzf-tab"
else
    log_info "fzf-tab already installed, skipping."
fi

# ---------------------------------------------------
# 5. Tmux Plugin Manager (TPM)
# ---------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    log_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

    if command -v tmux &>/dev/null; then
        log_info "Installing tmux plugins..."
        tmux new-session -d -s _setup \
            "sleep 3 \
            && ~/.config/tmux/plugins/tpm/bin/install_plugins \
            && tmux kill-session -t _setup" || log_warn "tmux plugin install failed, run manually: <prefix>+I"
    else
        log_warn "tmux not found in PATH, skipping plugin install. Run <prefix>+I inside tmux later."
    fi
else
    log_info "TPM already installed, skipping."
fi

# ---------------------------------------------------
# 6. Fonts
# ---------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -qi "JetBrainsMono"; then
    log_info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm -f JetBrainsMono.zip
    fc-cache -fv
    cd "$DOTFILES_DIR"
else
    log_info "JetBrainsMono Nerd Font already installed, skipping."
fi

# ---------------------------------------------------
# 7. Node Version Manager (fnm)
# ---------------------------------------------------
if ! command -v fnm &>/dev/null && [ ! -x "$HOME/.local/share/fnm/fnm" ]; then
    log_info "Installing fnm..."
    # --skip-shell: fnm init already in dotfiles .zshrc and .bashrc
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

    # Source fnm for current session (installer adds it to shell rc for future sessions)
    FNM_PATH="$HOME/.local/share/fnm"
    if [ ! -d "$FNM_PATH" ]; then
        FNM_PATH="$HOME/.fnm"
    fi
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env)"

    fnm install --lts
else
    log_info "fnm already installed, skipping."
fi

# ---------------------------------------------------
# 8. Initialize submodules (Neovim config)
# ---------------------------------------------------
log_info "Initializing git submodules..."
git submodule update --init --recursive

# ---------------------------------------------------
# 9. Symlink configs with Stow
# ---------------------------------------------------
log_info "Symlinking configs with Stow..."

# Skip backup if stow was already run (symlinks already exist)
if [ -L "$HOME/.zshrc" ] && [ "$(readlink -f "$HOME/.zshrc")" = "$DOTFILES_DIR/.zshrc" ]; then
    log_info "Stow already configured, re-stowing..."
    stow --adopt -R --no-folding .
    git checkout . 2>/dev/null
else
    # Back up any existing files that would conflict
    backup_needed=false
    while IFS= read -r file; do
        target="$HOME/$file"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            backup_needed=true
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv "$target" "$BACKUP_DIR/$file"
            log_warn "Backed up $target → $BACKUP_DIR/$file"
        fi
    done < <(find . -not -path './.git/*' -not -name '.git' \
                  -not -name 'README.md' \
                  -not -name 'LICENSE' -not -name '.gitignore' \
                  -not -name '.gitmodules' -not -name '.stowrc' \
                  -type f | sed 's|^\./||')

    if [ "$backup_needed" = true ]; then
        log_info "Existing configs backed up to $BACKUP_DIR"
    fi

    # Oh My Zsh installer may have created a default .zshrc — remove it before stowing
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        log_warn "Removing default .zshrc (ours will be symlinked)"
        mkdir -p "$BACKUP_DIR"
        mv "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" 2>/dev/null || rm "$HOME/.zshrc"
    fi

    # Stow all files
    stow --adopt --no-folding .
    git checkout . 2>/dev/null
fi

log_info "All configs symlinked!"

# ---------------------------------------------------
# 9a. Install Yazi plugins
# ---------------------------------------------------
if command -v ya &>/dev/null; then
    log_info "Installing Yazi plugins..."
    ya pkg install &>/dev/null || true
fi

# ---------------------------------------------------
# 10. Set Zsh as default shell
# ---------------------------------------------------
ZSH_PATH=$(which zsh)

# Ensure zsh is in /etc/shells
if ! grep -qF "$ZSH_PATH" /etc/shells; then
    log_info "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Try chsh first
if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
    log_info "Setting zsh as default shell..."
    if chsh -s "$ZSH_PATH"; then
        export SHELL="$ZSH_PATH"
        log_info "Default shell changed. Log out and back in to take effect."
    else
        log_warn "chsh failed. Set manually: chsh -s \$(which zsh)"
    fi
fi

# On Debian/Ubuntu: set GNOME Terminal default shell to zsh if installed
if [ "$DISTRO" = "debian" ] && command -v gsettings &>/dev/null && gsettings get org.gnome.Terminal.ProfilesList default &>/dev/null; then
    log_info "Setting GNOME Terminal default shell to zsh..."
    PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/" use-custom-command true
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/" custom-command "$ZSH_PATH"
fi

# ---------------------------------------------------
# Done
# ---------------------------------------------------
if [ "$IS_UPDATE" = true ]; then
    log_info "Dotfiles update complete!"
else
    log_info "Dotfiles setup complete!"
    echo -e "  ${CYAN}→${NC} Run ${BOLD}${GREEN}exec zsh${NC} to start"
    echo -e "  ${CYAN}→${NC} Run ${BOLD}${GREEN}p10k configure${NC} to change the prompt"
fi
echo ""
