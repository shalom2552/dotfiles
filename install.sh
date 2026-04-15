#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
VERSION="2.4.1"

# ---------------------------------------------------
# Helpers
# ---------------------------------------------------
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ---------------------------------------------------
# Detect distro
# ---------------------------------------------------
if command -v pacman &>/dev/null; then
    DISTRO="Arch-based"
elif command -v apt &>/dev/null; then
    DISTRO="Debian/Ubuntu"
else
    DISTRO="Unknown"
fi

# ---------------------------------------------------
# Welcome
# ---------------------------------------------------
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
echo "    • System packages (git, zsh, nvim, tmux, ...)"
echo "    • Oh My Zsh + Powerlevel10k + plugins"
echo "    • fnm (Node), fonts, and CLI tools"
echo "    • Configs symlinked via Stow"
echo "    • Zsh as default shell"
echo ""
read -r -p "  Proceed? [n/Y] " confirm
echo ""
if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo "  Aborted."
    exit 0
fi

# ---------------------------------------------------
# Pre-install checks
# ---------------------------------------------------
if [ -d "$DOTFILES_DIR" ]; then
    warn "~/dotfiles already exists. Skipping clone."
    info "To run setup manually:"
    echo ""
    echo "    cd ~/dotfiles && chmod +x setup.sh && ./setup.sh"
    echo ""
    exit 1
fi

# ---------------------------------------------------
# Install prerequisites
# ---------------------------------------------------
info "Starting installation..."
echo ""

info "Installing git..."
if ! command -v git &>/dev/null; then
    if [ "$DISTRO" = "Arch-based" ]; then
        sudo pacman -S --noconfirm git
    elif [ "$DISTRO" = "Debian/Ubuntu" ]; then
        sudo apt update && sudo apt install -y git
    else
        error "Unsupported distro. Supports Arch-based and Debian/Ubuntu-based systems."
    fi
fi

# ---------------------------------------------------
# Clone and run setup.sh
# ---------------------------------------------------
info "Cloning dotfiles repository..."
git clone --recurse-submodules https://github.com/shalom2552/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

info "Handing off to setup.sh..."
chmod +x setup.sh
exec ./setup.sh
