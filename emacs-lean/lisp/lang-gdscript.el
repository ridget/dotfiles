;;; lisp/lang-gdscript.el --- GDScript (Godot) -*- lexical-binding: t; -*-

(use-package gdscript-mode
  :vc (:url "https://github.com/godotengine/emacs-gdscript-mode" :rev :newest)
  :defer t
  :mode "\\.gd\\'")

(add-to-list 'my/eglot-modes 'gdscript-mode)

;; Godot runs a built-in LSP server on port 6005 when the editor is open
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(gdscript-mode . ("localhost" 6005))))

;;; lang-gdscript.el ends here
