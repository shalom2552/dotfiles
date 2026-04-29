# Dotfiles

Personal configuration files for Linux. Managed with [GNU Stow](https://www.gnu.org/software/stow/) — symlinked from a single directory into `$HOME`.

> Hyprland desktop configuration lives in a [separate repository](https://github.com/shalom2552/hyprconf).

## Install

```bash
bash <(curl -fSsL shalom2552.github.io/dotfiles/install.sh)
```

> Installs packages (Arch + Debian/Ubuntu), sets up Oh My Zsh, fonts, fnm, and symlinks all configs via Stow.

---

| Screenshots |
| :---: |
| <img alt="home" src="https://github.com/user-attachments/assets/6827a573-9d31-46a8-b247-d7b902fbc7c9" /> | 
| <img alt="Tools" src="https://github.com/user-attachments/assets/d886f535-ad41-44fa-a00b-1e869a417f2d" /> |

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
    * `pulsemixer` (Audio Mixer)
    * `bat` & `eza` (Modern `cat` and `ls`)
    * `zoxide` (Smarter cd)
    * `lazygit` (Git TUI)

## Neovim

My Neovim config is included as a git submodule at `.config/nvim/`. It's a customized version of [LazyVim](https://github.com/LazyVim/LazyVim).

* **Standalone repo:** [github.com/shalom2552/nvim](https://github.com/shalom2552/nvim)
* **Start Fresh:** If you prefer to build your own, check out the [LazyVim Starter Documentation](https://www.lazyvim.org/).
