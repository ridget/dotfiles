;;; lisp/lang-elixir.el --- Elixir + HEEx support -*- lexical-binding: t; -*-

;;; elixir-ts-mode and heex-ts-mode are built into Emacs 30
(use-package elixir-ts-mode
  :ensure nil
  :mode (("\\.ex\\'"   . elixir-ts-mode)
         ("\\.exs\\'"  . elixir-ts-mode)
         ("\\.heex\\'" . heex-ts-mode)))

;;; Register with deferred eglot starter (fires after envrc)
(dolist (mode '(elixir-ts-mode heex-ts-mode))
  (add-to-list 'my/eglot-modes mode))

;;; elixir-ls (primary) or expert (CA internal) — install via mise: `mise use -g elixir-ls`
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((elixir-ts-mode heex-ts-mode) . ,(eglot-alternatives
                                                    '(("elixir-ls")
                                                      ("expert" "--stdio"))))))

;;; mix format — reads from stdin via `-`
(with-eval-after-load 'apheleia
  (setf (alist-get 'mix-format apheleia-formatters) '("mix" "format" "-"))
  (setf (alist-get 'elixir-ts-mode apheleia-mode-alist) 'mix-format))

;;; Emmet in HEEx templates — use JSX mode so attr expansion works correctly
(use-package emmet-mode
  :hook heex-ts-mode
  :config
  (add-to-list 'emmet-jsx-major-modes 'elixir-ts-mode)
  (setq emmet-expand-jsx-className? nil
        emmet-move-cursor-between-quotes t))

;;; Emmet: HEEx uses class= not className= (JSX default)
(defun my/emmet-elixir-classname-to-class (fn &rest args)
  (let ((result (apply fn args)))
    (if (derived-mode-p 'elixir-ts-mode)
        (replace-regexp-in-string " className=" " class=" result)
      result)))
(advice-add 'emmet-make-html-tag :around #'my/emmet-elixir-classname-to-class)

;;; do...end block text objects — ib/ab in elixir-ts-mode only
(defun my/elixir-inner-do-block (count &optional beg end type)
  (interactive "p")
  (when-let* ((node (treesit-node-at (point)))
              (do-node (treesit-parent-until
                        node (lambda (n) (equal (treesit-node-type n) "do_block")))))
    (let* ((children (treesit-node-children do-node))
           (start (treesit-node-end (car children)))
           (end (treesit-node-start (car (last children)))))
      (evil-range start end))))

(defun my/elixir-outer-do-block (count &optional beg end type)
  (interactive "p")
  (when-let* ((node (treesit-node-at (point)))
              (do-node (treesit-parent-until
                        node (lambda (n) (equal (treesit-node-type n) "do_block")))))
    (evil-range (treesit-node-start do-node) (treesit-node-end do-node))))

(with-eval-after-load 'elixir-ts-mode
  (evil-define-key '(visual operator) elixir-ts-mode-map
    "ib" #'my/elixir-inner-do-block
    "ab" #'my/elixir-outer-do-block))

;;; lang-elixir.el ends here
