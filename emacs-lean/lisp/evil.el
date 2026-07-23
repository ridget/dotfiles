;;; lisp/evil.el --- Evil mode stack -*- lexical-binding: t; -*-

;;; Core evil
(use-package evil
  :init
  (setq evil-want-keybinding nil    ; evil-collection handles mode integrations
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-undo-system 'undo-redo
        evil-want-fine-undo t
        evil-toggle-key "C-z")     ; C-z toggles between evil and emacs state
  :config
  (evil-mode 1))

;;; evil-collection — integrates evil with many modes
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init
   '(consult corfu dired ediff eglot embark flymake helpful
     magit magit-section markdown-mode vertico xref)))

;;; Surround (ys.../cs.../ds...)
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;;; Commenter (gc to comment, gcc for line)
(use-package evil-nerd-commenter
  :commands (evilnc-comment-operator evilnc-comment-or-uncomment-lines)
  :init
  (define-key evil-normal-state-map "gc" #'evilnc-comment-operator)
  (define-key evil-visual-state-map "gc" #'evilnc-comment-operator)
  (define-key evil-normal-state-map "gcc" #'evilnc-comment-or-uncomment-lines))

;;; Matchit — extended % matching
(use-package evil-matchit
  :after evil
  :config
  (global-evil-matchit-mode 1))

;;; Tree-sitter text objects
(use-package evil-textobj-tree-sitter
  :after evil
  :vc (:url "https://github.com/meain/evil-textobj-tree-sitter" :rev :newest)
  :config
  ;; if/af — function   ic/ac — class   ia/aa — argument   ig/ag — call
  (define-key evil-inner-text-objects-map "f"
    (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (define-key evil-outer-text-objects-map "f"
    (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (define-key evil-inner-text-objects-map "c"
    (evil-textobj-tree-sitter-get-textobj "class.inner"))
  (define-key evil-outer-text-objects-map "c"
    (evil-textobj-tree-sitter-get-textobj "class.outer"))
  (define-key evil-inner-text-objects-map "a"
    (evil-textobj-tree-sitter-get-textobj "parameter.inner"))
  (define-key evil-outer-text-objects-map "a"
    (evil-textobj-tree-sitter-get-textobj "parameter.outer"))
  (define-key evil-inner-text-objects-map "g"
    (evil-textobj-tree-sitter-get-textobj "call.inner"))
  (define-key evil-outer-text-objects-map "g"
    (evil-textobj-tree-sitter-get-textobj "call.outer")))

;;; Dired — doom-style navigation on top of evil-collection
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "i")   #'wdired-change-to-wdired-mode
    (kbd "C-c") #'dired-do-copy
    (kbd "C-r") #'dired-do-rename))

;;; evil.el ends here
