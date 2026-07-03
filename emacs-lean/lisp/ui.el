;;; lisp/ui.el --- Visual presentation -*- lexical-binding: t; -*-

;;; Line numbers
(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)

;;; Fonts — Fira Code 14pt default, Ubuntu 16pt variable-pitch
(set-face-attribute 'default nil :family "Fira Code" :height 140)
(set-face-attribute 'variable-pitch nil :family "Ubuntu" :height 160)

(defvar my/big-font-p nil)
(defun my/toggle-big-font ()
  "Toggle between 14pt (normal) and 24pt (big) font."
  (interactive)
  (setq my/big-font-p (not my/big-font-p))
  (set-face-attribute 'default nil :height (if my/big-font-p 240 140)))

;;; Doom theme
(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;;; Nerd icons (doom-modeline and completions depend on this)
(use-package nerd-icons)

;;; Doom modeline
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t))

;;; Dashboard
(use-package dashboard
  :hook (after-init . dashboard-setup-startup-hook)
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-projects-backend 'project-el)
  (dashboard-items '((recents . 5)
                     (projects . 5)
                     (bookmarks . 3))))

;;; Highlight TODOs in source
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :custom
  (hl-todo-keyword-faces
   '(("TODO"  . "#ff9800")
     ("FIXME" . "#f44336")
     ("NOTE"  . "#4caf50")
     ("HACK"  . "#9c27b0"))))

;;; ui.el ends here
