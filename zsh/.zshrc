# ============================================================
# ~/.zshrc
# ============================================================

# ============================================================
# 1. POWERLEVEL10K — INSTANT PROMPT
#    Must stay at the very top. Nothing that writes to stdout
#    or reads a password should appear before this block.
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/zsh_plugins/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


PATH="$PATH:$HOME/.local/bin"

# ============================================================
# 2. VI MODE & KEYBINDINGS
# ============================================================
# bindkey -v
# KEYTIMEOUT=10   # 100 ms delay for multi-key sequences (e.g. ESC)


# ============================================================
# 3. SHELL OPTIONS
# ============================================================
setopt interactivecomments   # allow # comments at the prompt


# ============================================================
# 4. HISTORY
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt hist_ignore_all_dups  # deduplicate on write
setopt hist_save_no_dups     # deduplicate on save
setopt hist_ignore_dups      # deduplicate consecutive entries
setopt hist_find_no_dups     # skip duplicates when searching
setopt hist_ignore_space     # don't record commands prefixed with a space


# ============================================================
# 5. COMPLETION SYSTEM
#    compinit must come before plugins that hook into it.
#    To rebuild a stale cache: rm -f ~/.zcompdump* && exec zsh
# ============================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"


# ============================================================
# 6. PLUGINS
#    Load after compinit so they can register completions.
# ============================================================
source ~/zsh_plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ~/zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# ============================================================
# 7. ENVIRONMENT VARIABLES
# ============================================================

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]          && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# --- fzf ---
# Default command: include hidden files/dirs, skip noise folders
export FZF_DEFAULT_COMMAND='fd \
  --no-ignore --hidden \
  --type f --type d --type l \
  --strip-cwd-prefix \
  --exclude node_modules \
  --exclude .git \
  --exclude .cache \
  --exclude .steam \
  --exclude ".local/share/JetBrains/Toolbox/scripts/clion"'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"


# ============================================================
# 8. ALIASES & FUNCTIONS
#    One alias per line. Group by topic.
# ============================================================

# --- Shell ---
alias c="clear"

# --- File listing ---
alias ls="ls --color=auto"

# --- Applications ---
# Run pokerth at 1.6× UI scale (HiDPI workaround)
alias pokerth-hres="QT_SCALE_FACTOR=1.6 pokerth"

# Uncomment if okular tab-completion does nothing:
# compdef _files okular


# ============================================================
# 9. TOOL INITIALISERS
#    Slow-to-source tools go last so instant-prompt stays fast.
# ============================================================

# --- fzf key bindings & fuzzy completion ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh
[ -f ~/.fzf/shell/completion.zsh ]   && source ~/.fzf/shell/completion.zsh


# ============================================================
# TIPS (remove when no longer needed)
# ============================================================
# Remap Caps Lock → Escape (normal):
#   gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
#
# Remap Caps Lock → Escape / Shift+Caps Lock → Caps Lock:
#   gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape_shifted_capslock']"
#

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
