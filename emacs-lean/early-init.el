;;; early-init.el --- Early startup optimizations -*- lexical-binding: t; -*-

;; Raise GC threshold during init; restored in init.el via emacs-startup-hook
(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

;; Silence native comp warnings
(setq native-comp-async-report-warnings-errors nil)

;; Frame setup before first frame renders
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
(push '(horizontal-scroll-bars . nil) default-frame-alist)

;; Manage package initialization manually in init.el
(setq package-enable-at-startup nil)

;;; early-init.el ends here
