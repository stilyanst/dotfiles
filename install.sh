#!/usr/bin/env sh

set -eu

# ============================================================
# CONFIG
# ============================================================

# Resolve the dotfiles directory from the script's own location so the
# script works regardless of the current working directory.
DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

FZF_VERSION="v0.70.0"
FZF_VERSION_NUM="${FZF_VERSION#v}"
NVIM_VERSION="v0.12.2"

FONT_DIR="$HOME/.local/share/fonts"

# One entry per line. powerlevel10k is just another plugin here.
ZSH_PLUGINS="
https://github.com/romkatv/powerlevel10k.git
https://github.com/marlonrichert/zsh-autocomplete.git
https://github.com/zsh-users/zsh-syntax-highlighting.git
"

# Scratch space for downloads; cleaned up automatically on exit.
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ============================================================
# HELPERS
# ============================================================

have() { command -v "$1" >/dev/null 2>&1; }
log()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Ask a yes/no question. Honours ASSUME_YES=1 for non-interactive runs.
confirm() {
    if [ "${ASSUME_YES:-}" = "1" ]; then
        return 0
    fi
    printf '%s (y/N): ' "$1"
    read -r reply
    [ "$reply" = "y" ] || [ "$reply" = "Y" ]
}

# Symlink src -> dst, backing up any existing real file/dir first.
# -n prevents nesting the link inside an existing directory symlink.
link() {
    src=$1
    dst=$2
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
}

# ============================================================
# SYSTEM DEPENDENCIES
# ============================================================

install_packages() {
    if have apt; then
        sudo apt update
        sudo apt install -y zsh git curl fd-find fontconfig build-essential

        # On Debian/Ubuntu the binary is installed as `fdfind`, not `fd`.
        # Symlink it into ~/.local/bin (already on PATH via .zshrc) so that
        # `fd` and FZF_DEFAULT_COMMAND work.
        if have fdfind && ! have fd; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        fi

    elif have pacman; then
        sudo pacman -Syu --needed --noconfirm zsh git curl fd fontconfig base-devel

    elif have brew; then
        brew install zsh git curl fd fontconfig gcc

    else
        die "No supported package manager found. Install manually: zsh git curl fzf fd fontconfig and a C compiler (for nvim-treesitter)"
    fi
}

install_packages_if_needed() {
    log "Checking required packages"
    for cmd in zsh git curl fd; do
        if ! have "$cmd"; then
            install_packages
            return
        fi
    done
    log "Required packages already present"
}

# ============================================================
# NVM
# ============================================================

install_nvm() {
    [ -d "$HOME/.nvm" ] && return

    log "Installing NVM"
    git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
    ( cd "$HOME/.nvm" && git checkout "$(git describe --abbrev=0 --tags)" )
}

# ============================================================
# SDKMAN
# ============================================================

install_sdkman() {
    [ -d "$HOME/.sdkman" ] && return

    log "Installing SDKMAN"
    curl -s "https://get.sdkman.io" | bash
}

# ============================================================
# NERD FONT
# ============================================================

install_font() {
    if ! have fc-list; then
        warn "fontconfig not installed. Install it before installing fonts."
        return
    fi

    if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        log "JetBrainsMono Nerd Font already installed."
        return
    fi

    log "Installing JetBrainsMono Nerd Font"
    mkdir -p "$FONT_DIR"

    curl -L -o "$TMP/JetBrainsMono.tar.xz" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    tar -xf "$TMP/JetBrainsMono.tar.xz" -C "$FONT_DIR"

    fc-cache -fv
    log "JetBrainsMono Nerd Font installed."
}

# ============================================================
# FZF
# ============================================================

install_fzf() {
    if have fzf && [ "$(fzf --version | awk '{print $1}')" = "$FZF_VERSION_NUM" ]; then
        log "fzf $FZF_VERSION_NUM already installed"
        return
    fi

    log "Installing fzf $FZF_VERSION"
    rm -rf "$HOME/.fzf"

    git clone --depth=1 --branch "$FZF_VERSION" \
        https://github.com/junegunn/fzf.git "$HOME/.fzf"

    # Keep the checkout in ~/.fzf so the shell integration scripts
    # (~/.fzf/shell/key-bindings.zsh, completion.zsh) sourced by .zshrc
    # remain available after install.
    ( cd "$HOME/.fzf" && ./install --bin --key-bindings --completion --no-update-rc )

    sudo install -m 755 "$HOME/.fzf/bin/fzf" /usr/local/bin/fzf
}

# ============================================================
# ZSH SETUP
# ============================================================

setup_zsh() {
    log "Checking zsh"
    have zsh || die "zsh is not installed. Install zsh using your package manager first."

    ZSH_PATH=$(command -v zsh)
    CURRENT_USER=$(id -un)
    CURRENT_SHELL=$(getent passwd "$CURRENT_USER" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")

    if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
        if confirm "zsh is not your default shell. Change it?"; then
            chsh -s "$ZSH_PATH"
            log "Default shell changed to zsh. Log out and back in for it to take effect."
        fi
    else
        log "zsh is already your default shell."
    fi

    log "Setting up zsh plugins"
    mkdir -p "$HOME/zsh_plugins"

    for plugin in $ZSH_PLUGINS; do
        plugin_name=$(basename "$plugin" .git)
        if [ ! -d "$HOME/zsh_plugins/$plugin_name" ]; then
            git clone --depth=1 "$plugin" "$HOME/zsh_plugins/$plugin_name"
        fi
    done

    log "Creating zshrc symlink"
    link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
}

# ============================================================
# NVIM
# ============================================================

install_nvim() {
    log "Setting up Neovim"

    if ! confirm "Install Neovim $NVIM_VERSION?"; then
        log "Skipping Neovim installation."
        return
    fi

    OS=$(uname -s)
    ARCH=$(uname -m)

    case "$OS" in
        Linux)
            case "$ARCH" in
                x86_64)        NVIM_ARCH="x86_64" ;;
                aarch64|arm64) NVIM_ARCH="arm64" ;;
                *)             die "Unsupported Linux architecture: $ARCH" ;;
            esac
            NVIM_FILE="nvim-linux-${NVIM_ARCH}.tar.gz"
            ;;
        Darwin)
            case "$ARCH" in
                x86_64) NVIM_ARCH="x86_64" ;;
                arm64)  NVIM_ARCH="arm64" ;;
                *)      die "Unsupported macOS architecture: $ARCH" ;;
            esac
            NVIM_FILE="nvim-macos-${NVIM_ARCH}.tar.gz"
            ;;
        *)
            die "Unsupported operating system: $OS"
            ;;
    esac

    NVIM_DIR="${NVIM_FILE%.tar.gz}"

    log "Downloading Neovim $NVIM_VERSION for $OS $ARCH"
    curl -L -o "$TMP/$NVIM_FILE" \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_FILE}"
    tar xzf "$TMP/$NVIM_FILE" -C "$TMP"

    sudo rm -rf /opt/nvim
    sudo mkdir -p /opt
    sudo mv "$TMP/$NVIM_DIR" /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

    log "Neovim installed."
}

setup_nvim() {
    install_nvim

    log "Symlinking Neovim config"
    mkdir -p "$HOME/.config"
    link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
}

# ============================================================
# MAIN
# ============================================================

main() {
    install_packages_if_needed
    install_nvm
    install_sdkman
    install_font
    install_fzf
    setup_zsh
    setup_nvim
    log "Setup complete."
}

main "$@"
