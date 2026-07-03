;;; lisp/obsidian.el --- Obsidian vault integration -*- lexical-binding: t; -*-

(use-package obsidian
  :vc (:url "https://github.com/licht1stein/obsidian.el" :rev :newest)
  :config
  (obsidian-specify-path "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain")
  (global-obsidian-mode t)
  :custom
  (obsidian-inbox-directory "inbox")
  :bind (:map obsidian-mode-map
         ("C-c C-o" . obsidian-follow-link-at-point)
         ("C-c C-b" . obsidian-backlink-jump)
         ("C-c C-l" . obsidian-insert-wikilink)))

(defvar obsidian-vaults
  '(("second-brain"   . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain")
    ("claude-coworker" . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-coworker")
    ("archive"        . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/archive"))
  "Alist of vault names to paths.")

(defun obsidian-switch-vault ()
  "Switch the active Obsidian vault."
  (interactive)
  (let* ((name (completing-read "Vault: " (mapcar #'car obsidian-vaults) nil t))
         (path (cdr (assoc name obsidian-vaults))))
    (obsidian-specify-path path)
    (setq obsidian-inbox-directory "inbox")
    (message "Switched to vault: %s" name)))

;;; Leader bindings — SPC n (notes)
(with-eval-after-load 'general
  (+leader
    :infix "n"
    ""  '(:ignore t                    :wk "notes")
    "s" '(obsidian-search              :wk "search notes")
    "n" '(obsidian-capture             :wk "new note")
    "d" '(obsidian-daily-note          :wk "daily note")
    "o" '(obsidian-follow-link-at-point :wk "follow link")
    "b" '(obsidian-backlink-jump       :wk "backlinks")
    "l" '(obsidian-insert-wikilink     :wk "insert link")
    "v" '(obsidian-switch-vault        :wk "switch vault")))

;;; obsidian.el ends here
