;;; lisp/git.el --- Git integration -*- lexical-binding: t; -*-

(use-package magit
  :commands (magit-status magit-blame magit-log-buffer-file)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;;; diff-hl — vc-gutter indicators (like Doom's +pretty module)
(use-package diff-hl
  :hook
  ((prog-mode          . diff-hl-mode)
   (magit-pre-refresh  . diff-hl-magit-pre-refresh)
   (magit-post-refresh . diff-hl-magit-post-refresh)))

;;; Hunk motions at override priority (alongside ]d/[d in lsp.el)
(with-eval-after-load 'general
  (general-def
    :states 'normal
    :keymaps 'override
    "]g" #'diff-hl-next-hunk
    "[g" #'diff-hl-prev-hunk))

;;; git.el ends here
