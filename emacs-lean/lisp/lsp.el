;;; lisp/lsp.el --- LSP via eglot + flymake diagnostics -*- lexical-binding: t; -*-

;;; Eglot — built-in LSP client
(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-report-progress nil)
  :config
  ;; Silence JSONRPC event noise in *Messages*
  (fset 'jsonrpc--log-event #'ignore))

;;; sideline — frame for inline diagnostic display
(use-package sideline
  :hook (flymake-mode . sideline-mode)
  :custom
  (sideline-delay 0.2))

;;; sideline-flymake — show flymake diagnostics inline at end of line
(use-package sideline-flymake
  :after sideline
  :custom
  (sideline-backends-right '(sideline-flymake))
  (sideline-flymake-display-mode 'line))

;;; g-motion and diagnostic bindings at override priority (beats mode/plugin maps)
(with-eval-after-load 'general
  (general-def
    :states 'normal
    :keymaps 'override
    "gd" #'xref-find-definitions
    "gD" #'xref-find-definitions-other-window
    "gr" #'xref-find-references
    "gi" #'eglot-find-implementation
    "gO" #'consult-imenu
    "K"  #'eldoc-doc-buffer
    "]d" #'flymake-goto-next-error
    "[d" #'flymake-goto-prev-error))

;;; Inlay hints — off by default; toggle with SPC t i
(add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)

;;; Deferred eglot startup — fires after envrc has applied the devbox env,
;;; so project-local language servers (devbox) are in exec-path.
;;; Lang modules push their modes here instead of using mode hooks directly.
(defvar my/eglot-modes '()
  "Major modes that should start eglot. Lang modules add to this list.")

(add-hook 'hack-local-variables-hook
          (lambda ()
            (when (and buffer-file-name
                       (apply #'derived-mode-p my/eglot-modes))
              (eglot-ensure))))

;;; lsp.el ends here
