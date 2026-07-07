# dotfiles

My personal setup for a terminal-based dev environment: zsh (with Powerlevel10k)
and Neovim, plus the tools they use.

## What's in here

- `zsh/` - my `.zshrc`: prompt, history, completion, plugins, and fzf/fd integration.
- `nvim/` - my Neovim config (LSP via Mason, treesitter, telescope, and friends).
- `install.sh` - sets everything up on a fresh machine.

## Usage

Clone the repo and run the installer:

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

It figures out its own location, so you can run it from anywhere.

The script installs system packages (zsh, git, curl, fd, a C compiler, a Nerd
Font), NVM, SDKMAN, fzf, and Neovim, then symlinks the zsh and nvim configs into
place. It's safe to re-run: existing pieces are skipped, and any real config files
it would replace get backed up to `*.bak` first.

A couple of steps ask before acting (changing your default shell, installing
Neovim). To run without prompts, set `ASSUME_YES=1`:

```sh
ASSUME_YES=1 ./install.sh
```

Supported package managers: apt, pacman, and brew.

## After installing

The Neovim LSP servers are installed by hand on purpose. Open Neovim and run:

```
:MasonInstall lua-language-server clangd pyright ruff bash-language-server jdtls shfmt shellcheck
```
