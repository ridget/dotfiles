#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOOM_DIR="$DOTFILES_DIR/doom"
DOOM_BIN="${DOOM_BIN:-$HOME/.emacs.d/bin/doom}"

echo "==> Pulling latest dotfiles..."
git -C "$DOTFILES_DIR" pull --rebase --autostash

echo ""
echo "==> Changes since last sync:"
git -C "$DOTFILES_DIR" log --oneline @{1}..HEAD -- doom/ 2>/dev/null || echo "    (first run)"

if [[ ! -f "$DOOM_DIR/config.local.el" ]]; then
  echo ""
  echo "==> Creating config.local.el from template..."
  cp "$DOOM_DIR/config.local.el.example" "$DOOM_DIR/config.local.el"
  echo "    Edit doom/config.local.el for this machine"
fi

echo ""
echo "==> Running doom sync..."
"$DOOM_BIN" sync

echo ""
echo "==> Done. Restart Emacs to pick up changes."
