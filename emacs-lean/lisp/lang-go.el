;;; lisp/lang-go.el --- Go via treesitter + gopls -*- lexical-binding: t; -*-

(use-package go-ts-mode
  :ensure nil
  :mode "\\.go\\'")

(add-to-list 'my/eglot-modes 'go-ts-mode)

(with-eval-after-load 'apheleia
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) '(goimports)))

;;; lang-go.el ends here
