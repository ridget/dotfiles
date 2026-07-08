;;; lisp/treesit.el --- Tree-sitter grammar management -*- lexical-binding: t; -*-

;;; treesit-auto — auto-install grammars and redirect to *-ts-mode variants
(use-package treesit-auto
  :ensure t
  :custom
  ;; 'always means it silently installs missing grammars without prompting you
  (treesit-auto-install 'always) 
  :config
  (global-treesit-auto-mode 1)
  
  ;; Limit treesit-auto to prioritize your exact preferred languages
  (setq treesit-auto-langs '(c-sharp css dockerfile elixir heex html json markdown ruby tsx typescript yaml)))
