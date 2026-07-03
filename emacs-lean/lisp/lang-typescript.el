;;; lisp/lang-typescript.el --- TypeScript / TSX support -*- lexical-binding: t; -*-

;;; typescript-ts-mode and tsx-ts-mode are built into Emacs 30
(use-package typescript-ts-mode
  :ensure nil
  :mode (("\\.ts\\'"  . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)))

;; Register with the deferred eglot starter in lsp.el (fires after envrc)
(dolist (mode '(typescript-ts-mode tsx-ts-mode))
  (add-to-list 'my/eglot-modes mode))

;;; .eta templates — treat as their base language (ported from Doom config)
(add-to-list 'auto-mode-alist '("\\.html\\.eta\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\.eta\\'"  . css-mode))
(add-to-list 'auto-mode-alist '("\\.js\\.eta\\'"   . js-mode))

;;; oxfmt formatter via apheleia (ported from Doom config.el:193-198)
;;; Only runs in projects that have .oxfmtrc.json
(with-eval-after-load 'apheleia
  (setf (alist-get 'oxfmt apheleia-formatters)
        '("npx" "oxfmt" "--stdin-filepath" filepath))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'oxfmt)
  (setf (alist-get 'tsx-ts-mode        apheleia-mode-alist) 'oxfmt)
  (setf (alist-get 'typescript-mode    apheleia-mode-alist) 'oxfmt))

;;; lang-typescript.el ends here
