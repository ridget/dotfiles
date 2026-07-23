;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;; Restore GC after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;;; Package bootstrap
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built-in in Emacs 30
(setq use-package-always-ensure t)

;; Pre-install all packages on first launch so use-package just configures.
;; This avoids partial-install failures when individual use-package :ensure calls
;; error mid-stream and cascade.
(let ((pkgs '(exec-path-from-shell envrc apheleia yasnippet yasnippet-snippets
              doom-themes nerd-icons doom-modeline dashboard hl-todo
              evil evil-collection evil-surround evil-nerd-commenter evil-matchit
              vertico orderless marginalia consult embark embark-consult
              corfu cape nerd-icons-corfu nerd-icons-completion
              general magit diff-hl ghostel sideline sideline-flymake consult-dir
              helpful treesit-auto web-mode
              markdown-mode emmet-mode)))
  (dolist (pkg pkgs)
    (unless (package-installed-p pkg)
      (package-install pkg))))

;;; Custom file (keep it out of init.el)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

;;; Machine-local feature flags (copy local.el.example → local.el; gitignored)
(defvar my/unity-enabled nil
  "When non-nil, load C#/Unity support. Set in local.el on machines that need it.")
(load (expand-file-name "local.el" user-emacs-directory) 'noerror 'nomessage)

;;; Module loader
(defun my/load (module)
  "Load MODULE from the lisp/ subdirectory."
  (load (expand-file-name (format "lisp/%s" module) user-emacs-directory) nil t))

(when (eq system-type 'darwin)
  ;; Tells the native compiler driver where to find GCC's emutls library
  (setq native-comp-driver-options 
        '("-B/opt/homebrew/Cellar/gcc/16.1.0/lib/gcc/current/gcc/aarch64-apple-darwin25/16/")))

;;; Core (order matters: core → ui → evil → completion → keys → rest)
(my/load "core")
(my/load "ui")
(my/load "evil")
(my/load "completion")
(my/load "keys")
(my/load "git")
(my/load "term")
(my/load "projects")
(my/load "lsp")
(my/load "elisp")
(my/load "treesit")
(my/load "ai")
(my/load "lang-typescript")
(my/load "lang-web")
(my/load "lang-ruby")
(my/load "lang-elixir")
(my/load "lang-go")
(my/load "lang-gdscript")
(my/load "lang-misc")
(when my/unity-enabled (my/load "lang-csharp"))
(my/load "obsidian")
(my/load "db")

;;; init.el ends here
