;;; lisp/completion.el --- Vertico / Corfu / Consult stack -*- lexical-binding: t; -*-

;;; Vertico — vertical minibuffer completion UI
(use-package vertico
  :hook (after-init . vertico-mode)
  :custom
  (vertico-cycle t))

;;; Orderless — fuzzy / space-separated matching
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Marginalia — annotations next to completion candidates
(use-package marginalia
  :after vertico
  :config
  (marginalia-mode 1))

;;; Consult — enhanced versions of built-in commands
(use-package consult
  :bind
  (([remap switch-to-buffer]          . consult-buffer)
   ([remap goto-line]                 . consult-goto-line)
   ([remap imenu]                     . consult-imenu)
   ([remap recentf-open-files]        . consult-recent-file))
  :custom
  (consult-preview-key 'any))

;;; Embark — contextual action dispatcher
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;;; Corfu — in-buffer popup completion
(use-package corfu
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-preview-current nil)
  (corfu-separator ?\s)
  (tab-always-indent 'complete)
  :config
  (corfu-popupinfo-mode 1))

;;; Cape — extra completion-at-point sources
(use-package cape
  :config
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-to-list 'completion-at-point-functions #'cape-file)
              (add-to-list 'completion-at-point-functions #'cape-dabbrev t))))

;;; Nerd icons for corfu popup
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;;; Nerd icons for vertico / marginalia minibuffer
(use-package nerd-icons-completion
  :after (marginalia nerd-icons)
  :config
  (nerd-icons-completion-mode 1)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;;; completion.el ends here
