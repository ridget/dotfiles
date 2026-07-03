;;; lisp/keys.el --- Leader key bindings via general.el -*- lexical-binding: t; -*-

(use-package general
  :config
  (general-create-definer +leader
    :states '(normal visual)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  ;;; Top-level
  (+leader
    "SPC" '(project-find-file           :wk "find file in project")
    "."   '(find-file                   :wk "find file")
    ","   '(consult-buffer              :wk "switch buffer")
    ":"   '(execute-extended-command    :wk "M-x")
    "/"   '(consult-ripgrep             :wk "search project"))

  ;;; f — file
  (+leader
    :infix "f"
    ""  '(:ignore t :wk "file")
    "f" '(find-file                     :wk "find file")
    "s" '(save-buffer                   :wk "save file")
    "r" '(consult-recent-file           :wk "recent files")
    "R" '(rename-visited-file           :wk "rename file")
    "y" '(my/yank-file-path             :wk "yank file path")
    "D" '(my/delete-current-file        :wk "delete file"))

  ;;; b — buffers
  (+leader
    :infix "b"
    ""  '(:ignore t :wk "buffers")
    "b" '(consult-buffer                :wk "switch buffer")
    "n" '(next-buffer                   :wk "next buffer")
    "p" '(previous-buffer               :wk "prev buffer")
    "k" '(kill-current-buffer           :wk "kill buffer")
    "l" '(list-buffers                  :wk "list buffers")
    "m" '(bookmark-set                  :wk "set bookmark")
    "j" '(bookmark-jump                 :wk "jump to bookmark")
    "B" '(bookmark-bmenu-list           :wk "list bookmarks"))

  ;;; p — project
  (+leader
    :infix "p"
    ""  '(:ignore t :wk "project")
    "p" '(project-switch-project        :wk "switch project")
    "f" '(project-find-file             :wk "find file in project")
    "r" '(consult-ripgrep               :wk "search project")
    "k" '(project-kill-buffers          :wk "kill project buffers")
    "u" '(devbox-services-up            :wk "devbox services up"))

  ;;; s — search
  (+leader
    :infix "s"
    ""  '(:ignore t :wk "search")
    "s" '(consult-line                  :wk "search in buffer")
    "p" '(consult-ripgrep               :wk "search project")
    "S" '(consult-isearch-history       :wk "isearch history")
    "i" '(consult-imenu                 :wk "goto symbol"))

  ;;; g — git
  (+leader
    :infix "g"
    ""  '(:ignore t :wk "git")
    "g" '(magit-status                  :wk "magit status")
    "b" '(magit-blame                   :wk "blame")
    "l" '(magit-log-buffer-file         :wk "file log")
    "r" '(diff-hl-revert-hunk           :wk "revert hunk"))

  ;;; c — code (eglot)
  (+leader
    :infix "c"
    ""  '(:ignore t :wk "code")
    "r" '(eglot-rename                  :wk "rename symbol")
    "a" '(eglot-code-actions            :wk "code actions")
    "f" '(eglot-format                  :wk "format buffer")
    "d" '(consult-flymake               :wk "diagnostics")
    "x" '(eglot-reconnect               :wk "reconnect LSP"))

  ;;; h — help (helpful)
  (+leader
    :infix "h"
    ""  '(:ignore t :wk "help")
    "f" '(helpful-callable              :wk "describe function")
    "v" '(helpful-variable              :wk "describe variable")
    "k" '(helpful-key                   :wk "describe key")
    "o" '(helpful-symbol                :wk "describe symbol")
    "m" '(describe-mode                 :wk "describe mode")
    "i" '(info                          :wk "info manual"))

  ;;; e — eval (elisp learning)
  (+leader
    :infix "e"
    ""  '(:ignore t :wk "eval")
    "e" '(eval-last-sexp                :wk "eval last sexp")
    "b" '(eval-buffer                   :wk "eval buffer")
    "r" '(eval-region                   :wk "eval region")
    "i" '(ielm                          :wk "ielm REPL"))

  ;;; o — open
  (+leader
    :infix "o"
    ""  '(:ignore t :wk "open")
    "t" '(ghostel                       :wk "terminal")
    "-" '(dired-jump                    :wk "dired here")
    "d" '(dired-jump                    :wk "dired"))

  ;;; w — windows
  (+leader
    :infix "w"
    ""  '(:ignore t :wk "windows")
    "v" '(split-window-right            :wk "split right")
    "s" '(split-window-below            :wk "split below")
    "d" '(delete-window                 :wk "delete window")
    "o" '(delete-other-windows          :wk "maximize window")
    "b" '(balance-windows               :wk "balance windows")
    "u" '(winner-undo                   :wk "undo layout")
    "U" '(winner-redo                   :wk "redo layout")
    "h" '(windmove-left                 :wk "move left")
    "j" '(windmove-down                 :wk "move down")
    "k" '(windmove-up                   :wk "move up")
    "l" '(windmove-right                :wk "move right"))

  ;;; t — toggles
  (+leader
    :infix "t"
    ""  '(:ignore t :wk "toggle")
    "l" '(display-line-numbers-mode     :wk "line numbers")
    "w" '(visual-line-mode              :wk "word wrap")
    "f" '(flymake-mode                  :wk "flymake")
    "t" '(consult-theme                 :wk "theme")
    "b" '(my/toggle-big-font            :wk "big font")
    "i" '(eglot-inlay-hints-mode        :wk "inlay hints"))

  ;;; q — quit/session
  (+leader
    :infix "q"
    ""  '(:ignore t :wk "quit")
    "q" '(save-buffers-kill-terminal    :wk "quit emacs")
    "Q" '(kill-emacs                    :wk "kill emacs (no save)")
    "f" '(delete-frame                  :wk "close frame")))

;;; Utility commands referenced in the leader tree
(defun my/yank-file-path ()
  "Copy the current buffer's file path to the kill ring."
  (interactive)
  (if-let ((path (buffer-file-name)))
      (progn (kill-new path) (message "%s" path))
    (user-error "Buffer is not visiting a file")))

(defun my/delete-current-file ()
  "Delete the file visited by the current buffer and kill the buffer."
  (interactive)
  (let ((file (buffer-file-name)))
    (unless file (user-error "Buffer is not visiting a file"))
    (when (yes-or-no-p (format "Delete %s? " file))
      (delete-file file t)
      (kill-current-buffer))))

;;; keys.el ends here
