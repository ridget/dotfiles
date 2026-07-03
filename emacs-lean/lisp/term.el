;;; lisp/term.el --- Terminal emulator (ghostel) -*- lexical-binding: t; -*-

;;; ghostel — libghostty-vt powered terminal; no build step, prebuilt binary auto-downloads
(use-package ghostel
  :commands ghostel
  :config
  ;; Start in emacs-state; C-z toggles back to evil-normal
  (add-hook 'ghostel-mode-hook #'evil-emacs-state))

;;; term.el ends here
