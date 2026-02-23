# Tips & Tricks

A quick reference for all the keybindings, shortcuts, and workflows in this setup.

---

## Kitty (Terminal Emulator)

### Startup
When kitty launches, you get a **3-pane tall layout**:
- **Left (master):** fastfetch → `vf` file picker → shell
- **Right top:** htop
- **Right bottom:** tty-clock

### Tabs
| Key | Action |
|-----|--------|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+Q` | Close tab |
| `Ctrl+Shift+.` | Move tab forward |
| `Ctrl+Shift+,` | Move tab backward |
| `Ctrl+Shift+Alt+T` | Set tab title |

### Windows (Splits)
| Key | Action |
|-----|--------|
| `Ctrl+Shift+Enter` | New window (split) |
| `Ctrl+Shift+W` | Close window |
| `Ctrl+Shift+]` | Next window |
| `Ctrl+Shift+[` | Previous window |
| `Ctrl+Shift+F` | Move window forward |
| `Ctrl+Shift+B` | Move window backward |
| `Ctrl+Shift+R` | Resize window mode (then use `h/j/k/l` or arrows) |

### Layouts
Configured layouts: **tall** (default), grid, fat, splits, vertical, stack

| Key | Action |
|-----|--------|
| `Ctrl+Shift+L` | Cycle through layouts |

> **Tall layout** gives you one large master pane on the left and stacked panes on the right — great for editing + terminals.

### Font & Appearance
| Key | Action |
|-----|--------|
| `Ctrl+Shift+Equal` | Increase font size |
| `Ctrl+Shift+Minus` | Decrease font size |
| `Ctrl+Shift+Backspace` | Reset font size |

- Font: **JetBrainsMono Nerd Font** at 11pt
- Theme: **Tokyo Night** with 80% background opacity
- Tab style: Colored bubble tabs (green = active, blue = inactive)

### Scrollback & Clipboard
| Key | Action |
|-----|--------|
| `Ctrl+Shift+H` | Browse scrollback in pager |
| `Ctrl+Shift+C` | Copy to clipboard |
| `Ctrl+Shift+V` | Paste from clipboard |
| `Ctrl+Shift+G` | Browse last command output |

---

## Tmux (prefix: `Ctrl+A`)

### Sessions
| Key | Action |
|-----|--------|
| `prefix + o` | **SessionX** — fuzzy session picker with zoxide |
| `prefix + S` | Choose session from list |
| `prefix + Ctrl+A` | Toggle to last session |
| `prefix + d` | Detach from session |

> **Tip:** SessionX (`prefix + o`) is the fastest way to switch sessions — it integrates with zoxide so you can jump to project dirs directly.

### Windows
| Key | Action |
|-----|--------|
| `prefix + Ctrl+C` | New window (opens at `$HOME`) |
| `prefix + H` | Previous window |
| `prefix + L` | Next window |
| `prefix + r` | Rename window |
| `prefix + "` | Choose window from list |
| `prefix + w` | List windows |

### Panes
| Key | Action |
|-----|--------|
| `prefix + v` | Split horizontal (side by side) |
| `prefix + s` | Split vertical (top/bottom) |
| `prefix + \|` | Split vertical (inherits path) |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + ,/.` | Resize pane left/right (20 cells) |
| `prefix + -/=` | Resize pane down/up (7 cells) |
| `prefix + z` | Zoom/unzoom pane (fullscreen toggle) |
| `prefix + c` | Kill pane |
| `prefix + x` | Swap pane down |
| `prefix + *` | Sync panes (type in all at once) |

### Copy Mode (vi keys)
| Key | Action |
|-----|--------|
| `prefix + [` | Enter copy mode |
| `v` | Start selection |
| `y` | Yank to clipboard |
| `q` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |

> **Tip:** tmux-yank makes `y` copy directly to your system clipboard. No need for `xclip` workarounds.

### Plugins
| Key | Action |
|-----|--------|
| `prefix + p` | **Floax** — floating terminal overlay (80x80%) |
| `prefix + Space` | **Thumbs** — highlight and quick-copy visible text (URLs, paths, hashes) |
| `prefix + I` | TPM — install new plugins |
| `prefix + U` | TPM — update plugins |

> **Tip:** Thumbs (`prefix + Space`) is incredibly useful — it highlights all copyable patterns on screen (IPs, file paths, git hashes, URLs) and lets you pick one with a single keystroke.

### Session Persistence
| Feature | Details |
|---------|---------|
| **tmux-resurrect** | Saves/restores sessions across tmux server restarts |
| **tmux-continuum** | Auto-saves every 15 min, auto-restores on tmux start |

> Your sessions survive reboots. Resurrect saves pane layouts, working directories, and running programs. Continuum does it automatically.

### Misc
| Key | Action |
|-----|--------|
| `prefix + R` | Reload tmux config |
| `prefix + P` | Toggle pane border labels |
| `prefix + K` | Clear screen |

### Status Bar
- **Left:** Session name
- **Right:** Current directory, session, time (`HH:MM`)
- Theme: **Catppuccin** with custom icons

---

## Zsh / Shell

### Core Aliases
| Alias | Expands To |
|-------|------------|
| `v` | `nvim` |
| `fm` | `yazi` (file manager) |
| `q` | `exit` |
| `n` | Open current dir in GUI file manager |
| `lock` | Lock screen |
| `shortcuts` | Fuzzy search all your aliases |

### Modern CLI Replacements
| Alias | Replaces | Extra |
|-------|----------|-------|
| `ls` | `ls` → `eza` | Icons, git status, grouped dirs |
| `la` | `ls -a` → `eza -a` | Same but shows hidden files |
| `ll` | `ls -l` → `eza -l` | Long format with git status |
| `tree` | `tree` → `eza -T` | Tree view with icons |
| `bat` | `cat` → `batcat` | Syntax highlighting, line numbers |

### Git Aliases
| Alias | Command |
|-------|---------|
| `ga` | `git add` |
| `gaa` | `git add --all --verbose` |
| `gap` | `git add --patch` (stage hunks interactively) |
| `gau` | `git add --update` |
| `gst` | `git status -u` |
| `gdf` | `git diff` |
| `gcm` | `git commit -m` |
| `gco` | `git checkout` |
| `gsw` | `git switch` |
| `lgt` | `lazygit` |

### Dotfiles Management
| Alias | Action |
|-------|--------|
| `dot` | Git commands for the bare dotfiles repo |
| `dotlgt` | Lazygit for dotfiles |

```bash
dot status          # see changed tracked files
dot add .zshrc      # stage a file
dot commit -m "..."  # commit
dot push            # push to GitHub
```

### Custom Functions
| Command | What It Does |
|---------|-------------|
| `vf` | Fuzzy find files with bat preview → open in nvim |

> **Tip:** `vf` supports multi-select — press `Tab` to mark multiple files, then `Enter` to open them all in nvim.

### Zsh Plugins
- **zsh-autosuggestions** — suggests commands as you type (press `→` to accept)
- **zsh-syntax-highlighting** — colors valid/invalid commands as you type
- **Powerlevel10k** — fast, customizable prompt (run `p10k configure` to restyle)

---

## FZF (Fuzzy Finder)

### Shell Keybindings
| Key | Action |
|-----|--------|
| `Ctrl+T` | Find files and paste path into command line |
| `Ctrl+R` | Search command history |
| `Alt+C` | Fuzzy cd into a directory |

### Inside FZF
| Key | Action |
|-----|--------|
| `Ctrl+U` | Scroll preview up |
| `Ctrl+D` | Scroll preview down |
| `?` | Toggle preview (in `vf`) |
| `Tab` | Mark/unmark item |
| `Shift+Tab` | Unmark item |
| `Enter` | Confirm selection |
| `Esc` | Cancel |

> FZF uses `fd` under the hood (faster than `find`), respects `.gitignore`, and searches hidden files by default.

---

## Zoxide (Smart cd)

| Command | Action |
|---------|--------|
| `cd foo` | Jump to best match for "foo" |
| `cd foo bar` | Jump to best match containing both words |
| `cdi` / `zz` | Interactive directory picker with fzf |

> Zoxide ranks directories by **frecency** (frequency + recency). The more you visit a directory, the fewer characters you need to type. After a week of use, `cd proj` will jump straight to `~/projects/my-project`.

---

## Yazi (File Manager)

Open with `fm` or `yazi`.

### Navigation
| Key | Action |
|-----|--------|
| `h` | Go to parent directory |
| `l` / `Enter` | Open file / enter directory |
| `j/k` | Move down/up |
| `G` | Jump to bottom |
| `gg` | Jump to top |
| `~` | Go to home |
| `/` | Search |
| `z` | Jump with zoxide |

### File Operations
| Key | Action |
|-----|--------|
| `Space` | Toggle select |
| `V` | Visual select mode |
| `y` | Yank (copy) |
| `x` | Cut |
| `p` | Paste |
| `d` | Trash |
| `D` | Permanent delete |
| `r` | Rename |
| `a` | Create file |
| `A` | Create directory |
| `.` | Toggle hidden files (shown by default) |

### Preview
| Key | Action |
|-----|--------|
| `Tab` | Toggle preview pane |

> **Tip:** Yazi previews images, PDFs, code (with syntax highlighting), and archives inline. It's one of the fastest terminal file managers available.

---

## Lazygit

Open with `lgt` (or `dotlgt` for dotfiles).

### Files Panel
| Key | Action |
|-----|--------|
| `Space` | Stage/unstage file |
| `a` | Stage all files |
| `d` | View diff / discard changes |
| `e` | Edit file in `$EDITOR` |

### Commits
| Key | Action |
|-----|--------|
| `c` | Commit staged changes |
| `A` | Amend last commit |
| `s` | Squash commit into previous |
| `r` | Reword commit message |

### Branches
| Key | Action |
|-----|--------|
| `n` | New branch |
| `Space` | Checkout branch |
| `M` | Merge into current |
| `R` | Rebase onto current |

### Navigation
| Key | Action |
|-----|--------|
| `[/]` | Switch panels |
| `{/}` | Scroll diff up/down |
| `Enter` | Expand / drill down |
| `?` | Open help menu |
| `p` | Push |
| `P` | Pull |
| `q` | Quit |

> **Tip:** Lazygit makes interactive rebasing, cherry-picking, and conflict resolution visual and fast. Press `?` in any panel to see all available actions.

---

## Fastfetch

Runs on kitty startup. Shows system info with a color-coded layout:
- **Blue:** CPU, GPU, RAM, Disk, Display
- **Magenta:** OS, Kernel, Packages, Shell, Terminal, DE
- **Yellow/Green:** Uptime, Local IP

Run manually: `fastfetch --config ~/.config/fastfetch/amazing.jsonc`

---

## Btop (Resource Monitor)

| Key | Action |
|-----|--------|
| `h` | Help |
| `Esc` | Back / close menu |
| `q` | Quit |
| `m` | Cycle sort order |
| `f` | Filter processes |
| `t` | Toggle tree view |
| `k` | Kill selected process |
| `1-4` | Cycle layout presets |

- Update rate: **100ms** (real-time monitoring)
- Sorted by: memory usage
- Shows: CPU, memory, network, and processes
