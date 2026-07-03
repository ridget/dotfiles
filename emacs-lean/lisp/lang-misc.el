;;; lisp/lang-misc.el --- Markdown, Dockerfile, YAML, shell -*- lexical-binding: t; -*-

;;; Markdown — markdown-mode from MELPA (richer than md-ts-mode)
(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\'"      . markdown-mode))
  :custom
  (markdown-command "multimarkdown")
  (markdown-fontify-code-blocks-natively t))

;;; marksman LSP for cross-file link checking / completions
;;; Install: brew install marksman  OR  download from github.com/artempyanykh/marksman
(add-to-list 'my/eglot-modes 'markdown-mode)

;;; Prettier for markdown formatting
(with-eval-after-load 'apheleia
  (setf (alist-get 'markdown-mode apheleia-mode-alist) 'prettier))

;;; Dockerfile — built-in treesit mode (Emacs 29+)
(use-package dockerfile-ts-mode
  :ensure nil
  :mode (("Dockerfile\\'"        . dockerfile-ts-mode)
         ("\\.dockerfile\\'"     . dockerfile-ts-mode)
         ("Dockerfile\\.[^/]*\\'" . dockerfile-ts-mode)))

;;; docker-langserver LSP
;;; Install: npm i -g dockerfile-language-server-nodejs
(add-to-list 'my/eglot-modes 'dockerfile-ts-mode)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(dockerfile-ts-mode . ("docker-langserver" "--stdio"))))

;;; YAML — built-in treesit mode (Emacs 29+)
(use-package yaml-ts-mode
  :ensure nil
  :mode (("\\.yml\\'"  . yaml-ts-mode)
         ("\\.yaml\\'" . yaml-ts-mode)))

;;; yaml-language-server LSP
;;; Install: npm i -g yaml-language-server
(add-to-list 'my/eglot-modes 'yaml-ts-mode)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(yaml-ts-mode . ("yaml-language-server" "--stdio"))))

;;; Prettier for YAML formatting
(with-eval-after-load 'apheleia
  (setf (alist-get 'yaml-ts-mode apheleia-mode-alist) 'prettier))

;;; lang-misc.el ends here
