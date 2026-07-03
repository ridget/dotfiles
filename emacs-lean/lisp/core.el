;;; lisp/core.el --- Sane defaults and core behaviors -*- lexical-binding: t; -*-

;;; Identity
(setq user-full-name "Tom Ridge"
      user-mail-address "thomas.ridge@cultureamp.com")

;;; Performance — bidi text
(setq-default bidi-display-reordering nil
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;;; File hygiene
(setq create-lockfiles nil
      make-backup-files nil
      auto-save-default nil)

;;; Recent files
(recentf-mode 1)
(setq recentf-max-menu-items 20
      recentf-max-saved-items 100)

;;; Persist cursor position and minibuffer history
(save-place-mode 1)
(savehist-mode 1)

;;; UI niceties
(delete-selection-mode 1)
(setq delete-by-moving-to-trash t)
(setq use-short-answers t)          ; y/n instead of yes/no

;;; UTF-8 everywhere
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

;;; Smooth scrolling
(pixel-scroll-precision-mode 1)

;;; Electric pair (auto-close brackets)
(electric-pair-mode 1)

;;; Which-key (built-in Emacs 30)
(which-key-mode 1)
(setq which-key-idle-delay 0.3)

;;; Dired extras (needed for dired-jump in keys.el)
(require 'dired-x)

;;; winner-mode — window layout undo/redo (built-in)
(winner-mode 1)

;;; desktop-save-mode — persist open files and layout across restarts (built-in)
(desktop-save-mode 1)
(setq desktop-restore-eager 5
      desktop-auto-save-timeout 30)

;;; exec-path-from-shell — inherit shell PATH/env in GUI Emacs on macOS
;;; Without this, LSP servers and devbox tools may not be found.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))

;;; direnv / envrc — devbox env per project (LSP must see the devbox env)
(use-package envrc
  :hook (after-init . envrc-global-mode))

;;; apheleia — format on save (formatters configured per lang module)
(use-package apheleia
  :hook (after-init . apheleia-global-mode))

;;; yasnippet
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package yasnippet-snippets
  :after yasnippet)

;;; core.el ends here
