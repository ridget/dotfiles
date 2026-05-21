#!/usr/bin/env bash
set -euo pipefail

# ─── DOTFILES SETUP ──────────────────────────────────────────────────────────
# Portable setup script for a new machine.
# Run: ./scripts/setup.sh
# ──────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Dotfiles dir: $DOTFILES_DIR"

# ─── HOMEBREW ─────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ─── OH-MY-ZSH ───────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ZSH plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Powerlevel10k
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ─── FZF-GIT ─────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/fzf-git.sh" ]]; then
  echo "==> Installing fzf-git.sh..."
  git clone https://github.com/junegunn/fzf-git.sh "$HOME/fzf-git.sh"
fi

# ─── SYMLINKS ────────────────────────────────────────────────────────────────
echo "==> Creating symlinks..."

link_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "    Backing up existing $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "    $dst -> $src"
}

link_file "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/gemrc" "$HOME/.gemrc"

# ─── NEOVIM ──────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.config/nvim" ]]; then
  echo "==> Neovim config not found at ~/.config/nvim"
  echo "    Clone your nvim config manually or symlink it."
fi

# ─── DOOM EMACS ──────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.emacs.d" ]]; then
  echo "==> Installing Doom Emacs..."
  git clone https://github.com/hlissner/doom-emacs "$HOME/.emacs.d"
  "$HOME/.emacs.d/bin/doom" install
else
  echo "==> Doom Emacs already installed, syncing..."
  "$HOME/.emacs.d/bin/doom" sync
fi

# Symlink doom config if we have it
if [[ -d "$DOTFILES_DIR/doom" ]]; then
  link_file "$DOTFILES_DIR/doom" "$HOME/.config/doom"
  if [[ ! -f "$DOTFILES_DIR/doom/config.local.el" ]]; then
    cp "$DOTFILES_DIR/doom/config.local.el.example" "$DOTFILES_DIR/doom/config.local.el"
    echo "    Created doom/config.local.el from template (edit for this machine)"
  fi
fi

# ─── MISE (runtime versions) ─────────────────────────────────────────────────
if command -v mise &>/dev/null; then
  echo "==> Activating mise..."
  eval "$(mise activate bash)"
  mise install
fi

# ─── DIRENV ──────────────────────────────────────────────────────────────────
if command -v direnv &>/dev/null; then
  echo "==> direnv is installed"
fi

# ─── SUMMARY ─────────────────────────────────────────────────────────────────
echo ""
echo "==> Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal (or: source ~/.zshrc)"
echo "  2. Create ~/.secrets with your API tokens"
echo "  3. Create ~/.zshrc.local for work-specific config"
echo "  4. Open Emacs: e (starts daemon + connects)"
echo "  5. In Emacs: SPC a s (start ECA), /login (connect Copilot)"
echo "  6. Edit doom/config.local.el for machine-specific settings"
echo "  7. To sync later: ./scripts/sync-emacs.sh"
echo ""
