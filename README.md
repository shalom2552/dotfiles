# 🔧 Dotfiles

My personal configuration files for Linux, managed using a **bare git repository**. This setup keeps the home directory clean without symlinks or moving files.

## 📦 Tracked Configurations
* **Shell:** Zsh + Oh My Zsh + Powerlevel10k
* **Terminal:** Kitty (Tokyo Night Theme)
* **Editor:** Neovim (LazyVim)
* **Version Manager:** fnm (Node.js)
* **Tools:**
    * `fzf` (Fuzzy Finder)
    * `yazi` (Terminal File Manager)
    * `btop` (Resource Monitor)
    * `fastfetch` (System Info)
    * `bat` & `eza` (Modern `cat` and `ls`)

## 🚀 Installation on a New Machine

### 1. Prerequisites
Ensure `git` and `zsh` are installed.
```bash
sudo apt install git zsh
chsh -s $(which zsh)
```

###  2. Clone the Repository
This command clones the bare repo and handles potential file conflicts by backing up existing configs.
```bash
# 1. Clone bare repo
git clone --bare git@github.com:shalom2552/dotfiles.git $HOME/.dotfiles

# 2. Define temporary alias
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 3. Checkout (with backup if needed)
if config checkout; then
  echo "Checked out config.";
else
  echo "Backing up pre-existing dotfiles.";
  mkdir -p .config-backup
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
  config checkout
fi

# 4. Hide untracked files
config config --local status.showUntrackedFiles no
```

### 3. Post-Install
Install fnm: curl -fsSL https://fnm.vercel.app/install | bash

Install Fonts: JetBrainsMono Nerd Font.

Install Tools: sudo apt install fd-find bat eza btop fzf

## 🛠 Usage
I use the config alias (defined in .zshrc) to manage these files.

1. Adding New Configs
Always run this from the Home Directory (~).

```Bash
config add .zshrc
config add .config/kitty/
config commit -m "Update kitty theme"
config push
2. Checking Status
Bash
config status
```
Note: Untracked files are hidden by default to keep the output clean.
