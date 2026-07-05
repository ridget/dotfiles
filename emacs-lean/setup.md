# emacs-lean: setup instructions

## Install (replacing Doom Emacs)

```sh
# 1. Pull latest dotfiles (or clone if not present)
git -C ~/projects/dotfiles pull
# or: git clone git@github.com:ridget/dotfiles.git ~/projects/dotfiles

# 2. Nuke Doom — it typically lives in one or both of these:
rm -rf ~/.emacs.d        # Doom install dir (legacy)
rm -rf ~/.config/emacs   # Doom install dir (XDG)
rm -rf ~/.doom.d          # Doom config dir (legacy)
rm -rf ~/.config/doom     # Doom config dir (XDG)

# 3. Symlink emacs-lean into ~/.config
ln -sf ~/projects/dotfiles/emacs-lean ~/.config/emacs-lean

# 4. Ensure the zshrc aliases are live (dotfiles zshrc must be sourced/symlinked)
ln -sf ~/projects/dotfiles/zshrc ~/.zshrc && source ~/.zshrc

# 5. First launch — installs all packages then loads modules
emacs --init-directory=~/.config/emacs-lean
```

On first launch the batch pre-install runs (~30–60s). Done when the dashboard appears with no errors in `*Messages*`.

## Enable Unity/C# support

```sh
# 1. Install the Roslyn LSP wrapper (requires Rust toolchain)
cargo install roslyn-language-server

# 2. Ensure dotnet tools are on PATH (add to ~/.zshrc if not already)
export PATH="$HOME/.dotnet/tools:$PATH"

# 3. Enable the flag
cp ~/.config/emacs-lean/local.el.example ~/.config/emacs-lean/local.el

# 4. Restart Emacs — unity + shader-mode install automatically on first load
```

**Unity editor setup (one-time):** Preferences → External Tools → External Script Editor → point to the `code` shim that `unity.el` installs. Args: `emacsclient -n +$(Line):$(Column) $(File)`. Run Emacs as a daemon (`emacs --daemon`) so emacsclient round-trips work.

Verify with `M-:`:
```elisp
my/unity-enabled                       ; → t
(memq 'csharp-ts-mode my/eglot-modes)  ; → (csharp-ts-mode)
(package-installed-p 'unity)           ; → t
```

Fallback LSP: if Roslyn's named-pipe handshake is fiddly, swap to `csharp-ls` — see the comment in `lisp/lang-csharp.el`.
