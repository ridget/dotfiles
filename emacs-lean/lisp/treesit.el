;;; lisp/treesit.el --- Tree-sitter grammar management -*- lexical-binding: t; -*-

;;; treesit-auto — auto-install grammars and redirect to *-ts-mode variants
(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode 1))

;;; treesit.el ends here
