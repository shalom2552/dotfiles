#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/dotfiles"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# check if repo already exists
if [ -d "$DOTFILES_DIR" ]; then
    warn "~/dotfiles already exists."
    info "Run setup.sh from inside it."
    echo "          cd ~/dotfiles"
    echo "          chmod +x ./setup.sh"
    echo "          ./setup.sh"
    exit 1
fi

# Install git if it's missing
if ! command -v git &>/dev/null; then
    info "Installing git..."
    if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y git
    else
        error "Unsupported distro. This dotfiles supports Arch-based and Debian/Ubuntu-based systems."
        exit 1
    fi
fi


# Clone and run the setup script
info "Cloning dotfiles repository..."
git clone --recurse-submodules https://github.com/shalom2552/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

chmod +x setup.sh
info "Handing off to setup.sh..."
exec ./setup.sh

