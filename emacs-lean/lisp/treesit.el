;;; lisp/treesit.el --- Tree-sitter grammar management -*- lexical-binding: t; -*-

;;; treesit-auto — auto-install grammars and redirect to *-ts-mode variants
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'always)
  (treesit-auto-langs '(c-sharp css dockerfile elixir go gomod heex html json markdown ruby tsx typescript yaml))
  :config
  (global-treesit-auto-mode 1)
  (treesit-auto-install-all))

;;; treesit.el ends here
