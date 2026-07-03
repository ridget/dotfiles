;;; lisp/lang-web.el --- HTML / CSS / JSON support -*- lexical-binding: t; -*-

;;; HTML, CSS, JSON — built-in treesit modes (Emacs 29+)
(use-package html-ts-mode :ensure nil :mode "\\.html\\'")
(use-package css-ts-mode  :ensure nil :mode "\\.css\\'")
(use-package json-ts-mode :ensure nil
  :mode (("\\.json\\'"  . json-ts-mode)
         ("\\.jsonc\\'" . json-ts-mode)))

;;; Register with deferred eglot starter (fires after envrc)
(dolist (mode '(html-ts-mode css-ts-mode json-ts-mode))
  (add-to-list 'my/eglot-modes mode))

;;; LSP server programs
;;; npm i -g vscode-langservers-extracted   (html + css + json)
;;; npm i -g @tailwindcss/language-server   (tailwind; tried before vscode-css)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(html-ts-mode . ("vscode-html-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               `(css-ts-mode . ,(eglot-alternatives
                                 '(("tailwindcss-language-server" "--stdio")
                                   ("vscode-css-language-server" "--stdio")))))
  (add-to-list 'eglot-server-programs
               '(json-ts-mode . ("vscode-json-language-server" "--stdio"))))

;;; Prettier formatter via apheleia (prettier is built into apheleia)
(with-eval-after-load 'apheleia
  (dolist (entry '((html-ts-mode . prettier)
                   (css-ts-mode  . prettier)
                   (json-ts-mode . prettier)
                   (web-mode     . prettier)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry))))

;;; lang-web.el ends here
