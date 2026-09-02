# Dotfiles

Personal configuration files for Linux. Managed with [GNU Stow](https://www.gnu.org/software/stow/), symlinked from a single directory into `$HOME`.

> Hyprland desktop configuration lives in a [separate repository](https://github.com/shalom2552/hyprconf).

## Install

```bash
bash <(curl -fSsL shalom2552.github.io/dotfiles/install)
```

> Installs dependencies and symlinks configs via Stow.

| |
| :---: |
| <img alt="home" src="https://github.com/user-attachments/assets/6827a573-9d31-46a8-b247-d7b902fbc7c9" /> | 
| <img alt="Tools" src="https://github.com/user-attachments/assets/d886f535-ad41-44fa-a00b-1e869a417f2d" /> |

## Tracked Configurations

* **Shell:** Zsh + Oh My Zsh + Starship
* **Terminal:** Kitty (Tokyo Night Theme)
* **Editor:** Neovim ([LazyVim](https://www.lazyvim.org/)) (as a [submodule](.config/nvim))
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
    * `fd` (File Finder)
    * `hunk` (Diff Viewer)

## Scripts

Custom utilities in `.local/bin/`, symlinked onto `$PATH`.

| Script | Description |
| :--- | :--- |
| `track` | Move a config into `~/dotfiles` and stow it back |
| `conf` | Fuzzy pick a config file and open it in the editor |
| `tmux-dev` | Start or attach a `Dev` tmux session (nvim, terminal, lazygit) |
| `nb` | Fuzzy notes browser: edit, create, rename, delete |
| `launch` | Fuzzy application launcher over `.desktop` entries |
| `clip` | Fuzzy clipboard history picker (cliphist + fzf) |
| `power` | Power menu (shutdown, reboot, lock, ...) |
| `pkgf` | Fuzzy browse installed packages with info preview |
| `psf` | Fuzzy pick a running process and print its PID |
| `n` | Open a directory in the graphical file manager, detached |

## Neovim

A customized [LazyVim](https://github.com/LazyVim/LazyVim) config, included as a git submodule at `.config/nvim/`.

* **Standalone repo:** [github.com/shalom2552/nvim](https://github.com/shalom2552/nvim)
* **Start fresh:** [LazyVim Starter](https://www.lazyvim.org/)
