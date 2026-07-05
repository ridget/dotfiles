# emacs-lean: architecture & design rationale

## 1. Overview & launch

- **Repo:** `~/projects/dotfiles/emacs-lean/`
- **Symlinked to:** `~/.config/emacs-lean`
- **Launch:** `emacs --init-directory=~/.config/emacs-lean`
- **Aliases** (`zshrc:97-98`): `e` and `emacs` both expand to the above
- **Emacs version:** 30

## 2. Bootstrap

`early-init.el` runs before the first frame:
- GC raised to 128 MB / 60% during init; native comp warnings silenced
- Frame chrome stripped (menu/tool bar/scrollbars removed)
- `package-enable-at-startup nil` — package init is done manually in `init.el`

`init.el` sequence:
1. `emacs-startup-hook` restores GC to 16 MB / 10% (`init.el:4-7`)
2. MELPA + nongnu archives added; `package-initialize`
3. **Batch pre-install** (`init.el:24-34`): all packages installed upfront before any `use-package` runs. Guards against cascading `:ensure` failures — if one `use-package` errors mid-stream it can prevent later packages from installing. On first launch this block does the one-time install; thereafter it's a no-op.
4. `custom.el` loaded (`init.el:37-38`)
5. `my/unity-enabled` flag declared + `local.el` loaded (`init.el:41-43`)
6. `my/load` defun (`init.el:46-48`): loads `lisp/<name>.el` relative to `user-emacs-directory`
7. Modules loaded in strict order (`init.el:50`): `core → ui → evil → completion → keys → rest`

## 3. Module map

| File | Purpose |
|------|---------|
| `lisp/core.el` | Sane defaults (GC, file hygiene, UTF-8, `save-place`, `savehist`, `electric-pair`, `which-key`, `winner`, `desktop-save`); `exec-path-from-shell`, `envrc`/devbox, `apheleia` format-on-save, `yasnippet` |
| `lisp/ui.el` | Line numbers, Fira Code 14pt / Ubuntu 16pt, `doom-one` theme, `doom-modeline`, `dashboard` (project.el backend), `hl-todo` |
| `lisp/evil.el` | `evil` + `evil-collection`; `evil-surround` (ys/cs/ds), `evil-nerd-commenter` (gc/gcc), `evil-matchit` (%), `evil-textobj-tree-sitter` (if/af ic/ac ia/aa ig/ag) |
| `lisp/completion.el` | `vertico` (vertical minibuffer), `orderless` (fuzzy), `marginalia`, `consult` (buffer/ripgrep/recent/imenu), `embark`, `corfu` (in-buffer popup), `cape`, nerd-icons for both |
| `lisp/keys.el` | `general.el` SPC leader — all top-level and group bindings (see §5) |
| `lisp/git.el` | `magit`, `diff-hl` (gutter indicators + `]g`/`[g` hunk motions) |
| `lisp/term.el` | `ghostel` terminal; starts in `emacs-state` |
| `lisp/projects.el` | `project.el`: auto-discovers `~/projects/`; `devbox-services-up` opens ghostel at project root |
| `lisp/lsp.el` | `eglot` (built-in), `sideline` + `sideline-flymake` (inline diagnostics); `gd`/`gD`/`gr`/`gi`/`K`/`]d`/`[d` at override priority; deferred eglot starter |
| `lisp/elisp.el` | `helpful` — richer `*Help*` buffers with source links |
| `lisp/treesit.el` | `treesit-auto` (`'prompt`): auto-installs grammars, redirects to `*-ts-mode` variants |
| `lisp/ai.el` | `eca` (ECA chat, GitHub-only via `:vc`); `agent-shell` (GitHub-only via `:vc`) with headroom proxy; `my/pi` (pi TUI via ghostel); SPC a bindings |
| `lisp/lang-typescript.el` | `typescript-ts-mode` + `tsx-ts-mode`; eglot (typescript-language-server); oxfmt via apheleia; `.eta` template mappings |
| `lisp/lang-web.el` | `html-ts-mode`, `css-ts-mode`, `json-ts-mode`; vscode-langservers + tailwindcss-language-server; prettier via apheleia |
| `lisp/lang-ruby.el` | `ruby-ts-mode`; eglot (ruby-lsp auto-detected) |
| `lisp/lang-elixir.el` | `elixir-ts-mode` + `heex-ts-mode`; elixir-ls / expert LSP; mix format via apheleia; emmet in HEEx; `ib`/`ab` do...end text objects |
| `lisp/lang-misc.el` | `markdown-mode` + marksman LSP; `dockerfile-ts-mode` + docker-langserver; `yaml-ts-mode` + yaml-language-server; prettier for markdown/yaml |
| `lisp/lang-csharp.el` | C#/Unity — **loaded only when `my/unity-enabled`** (see §7); `csharp-ts-mode`, Roslyn LSP, `shader-mode`, `unity` editor integration |
| `lisp/obsidian.el` | `obsidian.el` (GitHub via `:vc`); three vaults (second-brain, claude-coworker, archive); `obsidian-switch-vault`; SPC n bindings |
| `lisp/db.el` | `pgmacs` (GitHub via `:vc`); `pgmacs-open-connection` auto-detects port via lsof/`PGPORT`; SPC d binding |

## 4. Key patterns

### Deferred eglot starter (`lsp.el:47-54`)

```elisp
(defvar my/eglot-modes '()        ; lsp.el:47 — lang modules push their mode here
  "Major modes that should start eglot.")

(add-hook 'hack-local-variables-hook  ; lsp.el:50 — fires after envrc applies devbox env
          (lambda ()
            (when (and buffer-file-name
                       (apply #'derived-mode-p my/eglot-modes))
              (eglot-ensure))))
```

Lang modules do **not** hook eglot on `<mode>-hook` directly. They call `(add-to-list 'my/eglot-modes 'the-ts-mode)`. The starter fires on `hack-local-variables-hook` so envrc has already applied the devbox environment and project-local LSP servers are on `exec-path`.

### envrc / devbox + exec-path-from-shell (`core.el`)

`exec-path-from-shell` syncs the shell's `PATH` into GUI Emacs on macOS. `envrc-global-mode` applies per-directory `.envrc` files (devbox), so each project's devbox-installed tools are found by eglot and other commands.

### apheleia format-on-save (`core.el`)

`apheleia-global-mode` is enabled globally. Lang modules add formatter entries via `(with-eval-after-load 'apheleia ...)`. Apheleia runs formatters asynchronously and applies diffs, so cursor position is preserved.

### treesit-auto grammar auto-install (`treesit.el`)

`(treesit-auto-install 'prompt)` — on first visit to a file whose grammar is missing, treesit-auto prompts to install it. It also remaps legacy modes (e.g. `python-mode → python-ts-mode`) automatically.

### `:vc` for GitHub-only packages

Packages not on MELPA use `use-package`'s `:vc` keyword (Emacs 30 built-in):
```elisp
:vc (:url "https://github.com/org/repo" :rev :newest)
```
Examples: `evil-textobj-tree-sitter`, `eca`, `agent-shell`, `obsidian.el`, `pgmacs`, `ghostel`.

## 5. Evil & keybindings

### Evil stack (`evil.el`)

- `evil` — `C-z` = `evil-toggle-key` (toggle evil/emacs state); `evil-undo-system 'undo-redo`
- `evil-collection` — integrates evil with magit, dired, help, etc.
- `evil-surround` — `ys<motion><char>`, `cs<old><new>`, `ds<char>`
- `evil-nerd-commenter` — `gc<motion>` / `gcc` (line comment)
- `evil-matchit` — `%` extended to tree-sitter constructs
- `evil-textobj-tree-sitter` — text objects: `if`/`af` function, `ic`/`ac` class, `ia`/`aa` parameter, `ig`/`ag` call

### Terminal / agent-shell state

`ghostel` (`term.el:8`), `agent-shell` (`ai.el:60`), and agent-shell diff buffers (`ai.el:63-66`) start in `emacs-state`. `C-z` returns to evil-normal. This means widget navigation and input work naturally without fighting evil bindings.

### SPC leader tree (`keys.el`)

| Prefix | Group | Key bindings |
|--------|-------|--------------|
| `SPC SPC` | — | find file in project |
| `SPC .` | — | find-file |
| `SPC ,` | — | consult-buffer |
| `SPC :` | — | M-x |
| `SPC /` | — | consult-ripgrep (project search) |
| `SPC f` | file | `f` find-file, `s` save, `r` recent, `R` rename, `y` yank path, `D` delete |
| `SPC b` | buffers | `b` switch, `n`/`p` next/prev, `k` kill, `l` list, `m`/`j`/`B` bookmarks |
| `SPC p` | project | `p` switch project, `f` find file, `r` ripgrep, `k` kill buffers, `u` devbox services up |
| `SPC s` | search | `s` line, `p` ripgrep, `S` isearch history, `i` imenu |
| `SPC g` | git | `g` magit-status, `b` blame, `l` file log, `r` revert hunk |
| `SPC c` | code/eglot | `r` rename, `a` code actions, `f` format, `d` diagnostics, `x` reconnect LSP |
| `SPC h` | help | `f` callable, `v` variable, `k` key, `o` symbol, `m` mode, `i` info |
| `SPC e` | eval | `e` last sexp, `b` buffer, `r` region, `i` ielm |
| `SPC o` | open | `t` terminal (ghostel), `-`/`d` dired |
| `SPC w` | windows | `v`/`s` split, `d` delete, `o` maximize, `b` balance, `u`/`U` winner undo/redo, `h`/`j`/`k`/`l` move |
| `SPC t` | toggles | `l` line numbers, `w` word wrap, `f` flymake, `t` theme, `b` big font, `i` inlay hints |
| `SPC q` | quit | `q` save+quit, `Q` kill, `f` close frame |
| `SPC a` | ai | `a` agent-shell, `n` new shell, `p` pi agent, `c` chat toggle, `s` start eca, `S` stop eca, `A` switch agent |
| `SPC n` | notes | `s` search, `n` new note, `d` daily note, `o` follow link, `b` backlinks, `l` insert link, `v` switch vault |
| `SPC d` | db | (single) pgmacs-open-connection |

Motion overrides (override keymap, normal state): `gd`/`gD`/`gr`/`gi`/`gO`/`K`/`]d`/`[d` (lsp.el), `]g`/`[g` (git.el).

## 6. Adding a language

1. Create `lisp/lang-X.el`:
   ```elisp
   (use-package X-ts-mode :ensure nil :mode "\\.ext\\'")
   (add-to-list 'my/eglot-modes 'X-ts-mode)
   ;; optional: eglot server
   (with-eval-after-load 'eglot
     (add-to-list 'eglot-server-programs '(X-ts-mode . ("x-language-server"))))
   ;; optional: apheleia formatter
   (with-eval-after-load 'apheleia
     (setf (alist-get 'X-ts-mode apheleia-mode-alist) 'prettier))
   ```

2. Add `(my/load "lang-X")` in `init.el` after the other lang loads.

See `lisp/lang-typescript.el` as the canonical template — it shows the full pattern including eglot server registration, apheleia formatter, and auto-mode-alist additions.

## 7. Machine-local config

`init.el:40-43` defines the flag mechanism:

```elisp
(defvar my/unity-enabled nil
  "When non-nil, load C#/Unity support. Set in local.el on machines that need it.")
(load (expand-file-name "local.el" user-emacs-directory) 'noerror 'nomessage)
```

`local.el` is gitignored (`.gitignore`). To opt in on a machine, copy `local.el.example → local.el`:

```elisp
(setq my/unity-enabled t)
```

`init.el:68` gates the module load: `(when my/unity-enabled (my/load "lang-csharp"))`.

`lang-csharp.el` is the first flagged feature. It installs `shader-mode` and `unity` (via `use-package :ensure`) **only when the module loads**, so these packages are never installed on machines where the flag is nil. They are also absent from the unconditional pre-install list in `init.el:24-34`.

## 8. Rationale

**package.el + use-package + `:vc` over straight/elpaca**  
`:vc` landed in Emacs 30 as a built-in way to install packages directly from git. It covers the one remaining gap package.el had (GitHub-only packages), so straight/elpaca add complexity without a meaningful gain. Leanest credible option given Emacs 30.

**eglot over lsp-mode**  
eglot is built into Emacs 28+. `sideline` + `sideline-flymake` (`lsp.el:14-25`) recreate the lsp-ui inline-diagnostic experience on top of flymake, so the ergonomics are equivalent. No extra indirection or JSON marshalling layer.

**project.el over projectile**  
eglot, consult, and xref all resolve project roots via `project.el` natively. One source of truth for "what project am I in." Projectile's main edge — fast indexing — is neutralised by ripgrep and fd. One fewer package dependency.

**Modular plain-elisp over literate init.org**  
Each `lisp/*.el` file has real line numbers, works with `C-x C-e`, `M-.` (jump to definition), and the Emacs debugger. Editing is surgical: open the module, change it, `C-x C-e` or restart. The `SPC e` eval group and `helpful.el` (`lisp/elisp.el`) form a learning layer for Emacs Lisp without requiring org-mode.

**evil `C-z` fallback is free**  
`C-z` is evil's built-in `evil-toggle-key` — no extra configuration needed. Terminals and agent buffers start in `emacs-state` so widget navigation works immediately; `C-z` returns to evil-normal when needed. No friction, no custom toggle logic.
