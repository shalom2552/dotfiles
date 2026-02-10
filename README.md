# Dotfiles

My personal configuration files for Linux, managed using a **bare git repository**. This setup keeps the home directory clean without symlinks or moving files.

## Tracked Configurations
* **Shell:** Zsh + Oh My Zsh + Powerlevel10k
* **Terminal:** Kitty (Tokyo Night Theme)
* **Editor:** Neovim ([LazyVim](https://www.lazyvim.org/))
* **Version Manager:** fnm (Node.js)
* **Tools:**
    * `fzf` (Fuzzy Finder)
    * `yazi` (Terminal File Manager)
    * `btop` (Resource Monitor)
    * `fastfetch` (System Info)
    * `bat` & `eza` (Modern `cat` and `ls`)

### Neovim Configuration

I use a customized version of [LazyVim]([https://www.lazyvim.org/](https://github.com/LazyVim/LazyVim)).
* **My Config:** [github.com/shalom2552/nvim](https://github.com/shalom2552/nvim) (Clone this to `~/.config/nvim` to use my setup).
* **Start Fresh:** If you prefer to build your own, check out the [LazyVim Starter Documentation](https://www.lazyvim.org/).

## Installation on a New Machine

### 1. Prerequisites
Ensure `git` and `zsh` are installed.
```bash
sudo apt install git zsh
chsh -s $(which zsh)
```

### 2. Clone the Repository
This command clones the bare repo and handles potential file conflicts by backing up existing configs automatically.

```bash
# 1. Clone bare repo
git clone --bare https://github.com/shalom2552/dotfiles.git $HOME/.dotfiles


# 2. Define temporary alias
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 3. Checkout (with robust backup)
if config checkout; then
  echo "Checked out config.";
else
  echo "Backing up pre-existing dotfiles.";
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | while read file; do
      mkdir -p .config-backup/$(dirname $file)
      mv $file .config-backup/$file
  done
  config checkout
fi

# 4. Hide untracked files
config config --local status.showUntrackedFiles no
```
### 3. Post-Install

Run these commands to set up the shell environment, dependencies, and tools tracked in this repo.

#### 1. System Tools
Install the core utilities (including `batcat` and `eza`, which are aliased in `.zshrc`).
```bash
sudo apt update
sudo apt install -y fd-find bat eza btop ripgrep unzip
```

Install fzf via Git to get the latest version and keybindings (Ctrl+T, Ctrl+R).

```Bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

#### 2. Shell Environment (Oh My Zsh + Plugins)
This block installs Oh My Zsh, the Powerlevel10k theme, and the required syntax highlighting/autosuggestion plugins.

```Bash
# 1. Install Oh My Zsh (Unattended)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 2. Install Powerlevel10k Theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Set ZSH_THEME="powerlevel10k/powerlevel10k" in .zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# 3. Install Zsh Plugins (Autosuggestions & Syntax Highlighting)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
#### 3. Node Version Manager (fnm)
Install fnm (Fast Node Manager) and the latest Node.js version.

```Bash
curl -fsSL https://fnm.vercel.app/install | bash

# Activate fnm in the current shell
source ~/.bashrc

fnm install --lts
```
#### 4. Fonts
Download and install JetBrainsMono Nerd Font (Required for icons in Kitty and P10k).

Manual: Download from [NerdFonts.com](https://www.nerdfonts.com/)

Command Line (Linux):

```Bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip && rm JetBrainsMono.zip
fc-cache -fv
```

### 5. Finalize
The installation scripts have overwritten `.zshrc` with a default one. 

Run this to force-restore the configurations:
```bash
# 1. Force the repo version of files to overwrite the defaults
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME reset --hard HEAD

# 2. Switch to Zsh
exec zsh
```

### 6. Configure Prompt
Once Zsh starts, you can customize the prompt style by running:

```bash
p10k configure
```

## Usage
I use the config alias (defined in .zshrc) to manage these files.

1. Adding New Configs
Always run this from the Home Directory (~).

```Bash
config add .zshrc
config add .config/kitty/
config commit -m "Update kitty theme"
config push
```
2. Checking Status
```Bash
config status
```
Note: Untracked files are hidden by default to keep the output clean.

3. To view and search all available aliases, run:
```bash
shortcuts
```

## Troubleshooting

**"Command not found" errors?**
My configuration uses many modern CLI replacements (like `bat` instead of `cat`, or `eza` instead of `ls`). If you see an error like `zsh: command not found: tty-clock`, it means you haven't installed that specific tool yet.

**Solution:** Google the package name and install it for your OS, or remove the alias from `.zshrc`.

## Issues & Contributing

If you find a broken link, an incorrect command, or an outdated step, please [open an issue](https://github.com/shalom2552/dotfiles/issues).

Contributions are welcome!

## License

This project is licensed under the MIT License - feel free to use it for your own setup!
