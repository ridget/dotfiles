;;; lisp/elisp.el --- Elisp learning and evaluation tools -*- lexical-binding: t; -*-

;;; helpful — richer *Help* buffers with source links and examples
(use-package helpful
  :bind
  (([remap describe-function] . helpful-callable)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-key]      . helpful-key)
   ([remap describe-symbol]   . helpful-symbol)))

;;; elisp.el ends here
