;;; lisp/treesit.el --- Tree-sitter grammar management -*- lexical-binding: t; -*-

;;; treesit-auto — auto-install grammars and redirect to *-ts-mode variants
(use-package treesit-auto
  :custom
  (treesit-auto-install t)
  :config
  (global-treesit-auto-mode 1)
  (dolist (lang '(c-sharp css dockerfile elixir heex html json markdown ruby tsx typescript yaml))
    (treesit-auto-install-grammar lang)))

;;; treesit.el ends here
