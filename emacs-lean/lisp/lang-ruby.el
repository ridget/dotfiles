;;; lisp/lang-ruby.el --- Ruby support -*- lexical-binding: t; -*-

;;; ruby-ts-mode is built into Emacs 29+
(use-package ruby-ts-mode
  :ensure nil
  :mode (("\\.rb\\'"      . ruby-ts-mode)
         ("\\.rake\\'"    . ruby-ts-mode)
         ("Gemfile\\'"    . ruby-ts-mode)
         ("Rakefile\\'"   . ruby-ts-mode)
         ("\\.gemspec\\'" . ruby-ts-mode)))

;;; Register with deferred eglot starter (fires after envrc)
(add-to-list 'my/eglot-modes 'ruby-ts-mode)

;;; ruby-lsp — eglot knows it automatically; install via:
;;;   gem install ruby-lsp  OR  add ruby-lsp to Gemfile dev group
;;; Formatting and diagnostics (rubocop/standard) handled by ruby-lsp itself.

;; Disable apheleia for ruby — ruby-lsp handles formatting via eglot
(with-eval-after-load 'apheleia
  (setf (alist-get 'ruby-ts-mode apheleia-mode-alist) nil))

;;; lang-ruby.el ends here
