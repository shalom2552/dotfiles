# Dotfiles

My personal configuration files for Linux, managed using [**GNU Stow**](https://www.gnu.org/software/stow/). This setup keeps the home directory clean with symlinks managed from a single directory.

> **Hyprland desktop configuration** (Hyprland, Waybar, Hypridle, Hyprlock, SwayOSD, etc.) is maintained in a [separate repository](https://github.com/shalom2552/hyprconf).


## Screenshots

| Main Desktop | Tools (Btop, Yazi, Fastfetch) |
| :---: | :---: |
| <img alt="home" src="https://github.com/user-attachments/assets/6827a573-9d31-46a8-b247-d7b902fbc7c9" /> | <img alt="btop_yazi_fastfetch" src="https://github.com/user-attachments/assets/d886f535-ad41-44fa-a00b-1e869a417f2d" /> |

## Tracked Configurations

* **Shell:** Zsh + Oh My Zsh + Powerlevel10k
* **Terminal:** Kitty (Tokyo Night Theme)
* **Editor:** Neovim ([LazyVim](https://www.lazyvim.org/)) — included as a [git submodule](.config/nvim)
* **Version Manager:** fnm (Node.js)
* **Tools:**
    * `tmux` (terminal multiplexer)
    * `fzf` (Fuzzy Finder)
    * `yazi` (Terminal File Manager)
    * `btop` (Resource Monitor)
    * `fastfetch` (System Info)
    * `bat` & `eza` (Modern `cat` and `ls`)
    * `zoxide` (Smarter cd)
    * `lazygit` (Git TUI)

### Neovim Configuration

My Neovim config is included as a git submodule at `.config/nvim/`. It's a customized version of [LazyVim](https://github.com/LazyVim/LazyVim).
* **Standalone repo:** [github.com/shalom2552/nvim](https://github.com/shalom2552/nvim)
* **Start Fresh:** If you prefer to build your own, check out the [LazyVim Starter Documentation](https://www.lazyvim.org/).

## Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shalom2552/dotfiles/main/install.sh)
```

> `install.sh` installs `git`, clones the repo, and runs `setup.sh` to handle dependencies, shell configuration, and Stow symlinks.

## Manual Installation

> For Debian/Ubuntu use `sudo apt install` instead of `sudo pacman -S`
### 1. Prerequisites

Ensure `git`, `zsh`, `wget` and `stow` are installed.

```bash
sudo pacman -S git zsh wget stow
```

### 2. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/shalom2552/dotfiles.git ~/dotfiles
```

### 3. Post-Install

#### 1. System Tools

Install the core utilities:

```bash
sudo pacman -S --needed \
  fd bat eza btop ripgrep unzip zoxide \
  tmux fzf yazi fastfetch lazygit \
  kitty chromium \
  imagemagick ffmpeg \
  python jq stow duf

# Debian/Ubuntu: some packages have different names (fd-find, python3).
# (eza, yazi, zoxide, fastfetch, lazygit) are not in default repos.
```

#### 2. Shell Environment (Oh My Zsh + Plugins)

```bash
# Install Oh My Zsh (Unattended)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Powerlevel10k Theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Zsh Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### 3. Tmux Plugins

```bash
# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Install plugins
~/.config/tmux/plugins/tpm/bin/install_plugins
```

#### 4. Node Version Manager (fnm)

```bash
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.zshrc
fnm install --lts
```

#### 5. Fonts

Download and install JetBrainsMono Nerd Font (required for icons in Kitty and Powerlevel10k):

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip && rm JetBrainsMono.zip
fc-cache -fv
```

### 4. Symlink Configs

```bash
cd ~/dotfiles
stow .
```

This creates symlinks from `~/dotfiles/` into your home directory for all tracked configs.

### 5. Finalize

```bash
# Set Zsh as default shell
chsh -s $(which zsh)

# Switch to Zsh
exec zsh
```

### 6. Configure Prompt

```bash
p10k configure
```

## Usage

After installation, edit config files directly in `~/dotfiles/` — changes are reflected immediately since they're symlinked.

```bash
# Edit a config
nvim ~/dotfiles/.config/kitty/kitty.conf

# Commit changes
cd ~/dotfiles
git add -A
git commit -m "update kitty config"
git push
```

To re-apply symlinks after adding new files:

```bash
cd ~/dotfiles
stow .
```

## Troubleshooting

**"Command not found" errors?**
My configuration uses many modern CLI replacements (like `bat` instead of `cat`, or `eza` instead of `ls`). If you see an error like `zsh: command not found: yazi`, it means you haven't installed that specific tool yet.

**Solution:** Install the missing package with `pacman` or `apt`, or remove the alias from `.zshrc`.

**Stow conflicts?**
If `stow` reports conflicts, it means existing files are in the way. Back them up and retry:

```bash
# Back up conflicting file
mv ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.bak

# Or use --adopt to pull existing files into the repo
cd ~/dotfiles
stow --adopt .
```
