;;; lisp/lang-go.el --- Go via treesitter + gopls -*- lexical-binding: t; -*-

(use-package go-ts-mode
  :ensure nil
  :mode "\\.go\\'")

(dolist (mode '(go-ts-mode go-mod-ts-mode))
  (add-to-list 'my/eglot-modes mode))

(with-eval-after-load 'apheleia
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) '(goimports)))

;;; lang-go.el ends here
