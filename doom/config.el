;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;; PERSONAL IDENTITY & VISUALS
;; ---------------------------------------------------------------------------
(setq user-full-name "Tom Ridge"
      user-mail-address "tomridge2@gmail.com")

(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)
(setq org-directory "~/org/")

;; Set Font size
(setq doom-font (font-spec :family "Fira Code" :size 14)
      doom-big-font (font-spec :family "Fira Code" :size 24)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 16))

;; Performance tweaks for bidirectional text
(setq-default bidi-display-reordering nil
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
;; ---------------------------------------------------------------------------
;; PROJECTILE
;; ---------------------------------------------------------------------------
(setq projectile-project-search-path '(("~/projects/" . 2))
      projectile-auto-update-cache t
      projectile-indexing-method 'hybrid)

;; ---------------------------------------------------------------------------
;; DIRENV (ensure devbox env loads before LSP)
;; ---------------------------------------------------------------------------
(after! envrc
  (envrc-global-mode))

;; ---------------------------------------------------------------------------
;; GLOBAL LSP CONFIGURATION (General UI & Performance)
;; ---------------------------------------------------------------------------
(after! lsp-mode
  (setq lsp-lens-enable t
        lsp-ui-peek-enable t
        lsp-ui-doc-enable nil
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-max-height 70
        lsp-ui-doc-max-width 150
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-diagnostic-max-lines 20
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-sideline-enable t)

  (setq lsp-file-watch-ignored-directories
        '("[/\\\\]\\.git\\'" "[/\\\\]\\.hg\\'" "[/\\\\]\\.svn\\'"
          "[/\\\\]node_modules\\'" "[/\\\\]\\.devbox\\'"
          "[/\\\\]\\.devcontainer\\'" "[/\\\\]vendor\\'"
          "[/\\\\]_build\\'" "[/\\\\]deps\\'" "[/\\\\]build\\'"
          "[/\\\\]tmp\\'" "[/\\\\]postgres-data\\'"
          "[/\\\\]\\.idea\\'" "[/\\\\]\\.venv\\'"
          "[/\\\\]dist\\'" "[/\\\\]coverage\\'")))

;; ---------------------------------------------------------------------------
;; ELIXIR & HEEX CONFIGURATION
;; ---------------------------------------------------------------------------

;; Enable LSP for Elixir and HEEx Tree-sitter modes
(add-hook 'elixir-ts-mode-hook #'lsp-deferred)
(add-hook 'heex-ts-mode-hook #'lsp-deferred)

;; ElixirLS Specific Settings
(setq lsp-elixir-suggest-specs t
      lsp-elixir-dialyzer-enabled t
      lsp-elixir-signature-after-complete t
      lsp-elixir-enable-test-lenses t)

;; Workaround to enable running credo after lsp
(defvar-local my/flycheck-local-cache nil)
(defun my/flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker my/flycheck-local-cache))
      (funcall fn checker property)))
(advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)

(add-hook 'lsp-managed-mode-hook
          (lambda ()
            (when (derived-mode-p 'elixir-mode 'elixir-ts-mode)
              (setq my/flycheck-local-cache '((lsp . ((next-checkers . (elixir-credo)))))))))

;; Fix duplicate "end" insertion in all Elixir modes
(after! smartparens
  (dolist (mode '(elixir-mode elixir-ts-mode))
    (sp-local-pair mode "for" "end" :actions nil)
    (sp-local-pair mode "if" "end" :actions nil)
    (sp-local-pair mode "case" "end" :actions nil)
    (sp-local-pair mode "cond" "end" :actions nil)
    (sp-local-pair mode "unless" "end" :actions nil)
    (sp-local-pair mode "with" "end" :actions nil)
    (sp-local-pair mode "try" "end" :actions nil)
    (sp-local-pair mode "fn" "end" :actions nil)
    (sp-local-pair mode "do" "end" :actions nil)
    (sp-local-pair mode "def" "end" :actions nil)
    (sp-local-pair mode "defp" "end" :actions nil)
    (sp-local-pair mode "defmodule" "end" :actions nil)
    (sp-local-pair mode "defimpl" "end" :actions nil)))

;; ---------------------------------------------------------------------------
;; WEB, TAILWIND & EMMET
;; ---------------------------------------------------------------------------
(use-package! lsp-tailwindcss
  :after lsp-mode
  :init (setq lsp-tailwindcss-add-on-mode t))

(after! web-mode
  (setq web-mode-enable-auto-pairing t
        web-mode-enable-css-colorization t
        web-mode-engines-alist nil))

(use-package! emmet-mode
  :hook (elixir-ts-mode . emmet-mode)
  :config
  (add-to-list 'emmet-jsx-major-modes 'elixir-ts-mode)
  (setq emmet-expand-jsx-className? nil
        emmet-move-cursor-between-quotes t))

;; Emmet: Replace className with class in Elixir files
(defadvice! +emmet-elixir-classname-to-class-a (fn &rest args)
  :around #'emmet-make-html-tag
  (let ((result (apply fn args)))
    (if (derived-mode-p 'elixir-ts-mode)
        (replace-regexp-in-string " className=" " class=" result)
      result)))

(after! elixir-ts-mode
  (set-company-backend! 'elixir-ts-mode
    '(:separate company-emmet company-yasnippet company-capf))
  ;; Bind TAB to indent/expand
  (map! :map elixir-ts-mode-map
        :i [tab] #'+web/indent-or-yas-or-emmet-expand
        :i "TAB" #'+web/indent-or-yas-or-emmet-expand))

;; ---------------------------------------------------------------------------
;; TREE-SITTER TEXT OBJECTS & EVIL
;; ---------------------------------------------------------------------------
(require 'treesit)
(global-evil-matchit-mode 1)

;; Define Elixir "do...end" block selection
(defun +elixir/inner-do-block (count &optional beg end type)
  "Select the inner content of an Elixir do...end block."
  (interactive "p")
  (when-let* ((node (treesit-node-at (point)))
              (do-node (treesit-parent-until node (lambda (n) (equal (treesit-node-type n) "do_block")))))
    (let* ((children (treesit-node-children do-node))
           (start (treesit-node-end (car children)))
           (end (treesit-node-start (car (last children)))))
      (evil-range start end))))

(defun +elixir/outer-do-block (count &optional beg end type)
  "Select the entire Elixir do...end block."
  (interactive "p")
  (when-let* ((node (treesit-node-at (point)))
              (do-node (treesit-parent-until node (lambda (n) (equal (treesit-node-type n) "do_block")))))
    (evil-range (treesit-node-start do-node) (treesit-node-end do-node))))

;; Bindings for Elixir blocks and generic Tree-sitter calls
(after! elixir-ts-mode
  (map! :map elixir-ts-mode-map :textobj "b" #'+elixir/inner-do-block #'+elixir/outer-do-block)
  (define-key evil-inner-text-objects-map "b" #'+elixir/inner-do-block)
  (define-key evil-outer-text-objects-map "b" #'+elixir/outer-do-block))

(after! evil-textobj-tree-sitter
  (define-key evil-inner-text-objects-map "g" (evil-textobj-tree-sitter-get-textobj "call.outer"))
  (define-key evil-outer-text-objects-map "g" (evil-textobj-tree-sitter-get-textobj "call.outer")))

;; ---------------------------------------------------------------------------
;; RUBY
;; ---------------------------------------------------------------------------
;; Use ruby-lsp via bundler with standard as formatter/linter
(after! lsp-mode
  (setq lsp-ruby-lsp-use-bundler t)
  (lsp-register-custom-settings
   '(("rubyLsp.formatter" "standard")
     ("rubyLsp.linters" ["standard"]))))

;; ---------------------------------------------------------------------------
;; TYPESCRIPT / JAVASCRIPT
;; ---------------------------------------------------------------------------
;; Use oxfmt for formatting in projects that have .oxfmtrc.json
(after! apheleia
  (setf (alist-get 'oxfmt apheleia-formatters)
        '("npx" "oxfmt" "--stdin-filepath" filepath))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'oxfmt)
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) 'oxfmt)
  (setf (alist-get 'typescript-mode apheleia-mode-alist) 'oxfmt))

;; .eta templates → treat as their base language
(add-to-list 'auto-mode-alist '("\\.html\\.eta\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\.eta\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.js\\.eta\\'" . js-mode))

;; ---------------------------------------------------------------------------
;; OTHER LANGUAGES
;; ---------------------------------------------------------------------------
(setq org-babel-python-command "python3")


;; (use-package! mise
;;   :config
;;   (add-hook 'after-init-hook #'global-mise-mode))


(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-language-id-configuration
               '(elixir-mode . "elixir"))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("expert" "--stdio"))
    ; :major-modes '(elixir-mode)
    :priority -1
    :activation-fn (lsp-activate-on "elixir")
    :server-id 'expert))
  )

(add-hook 'elixir-mode-hook #'lsp)

;; ---------------------------------------------------------------------------
;; DATABASE (pgmacs)
;; ---------------------------------------------------------------------------
(use-package! pgmacs
  :commands (pgmacs)
  :init
  (map! :leader
        :desc "Database (pgmacs)" "D" #'pgmacs-open-connection)

  :config
  (defun pgmacs--detect-ports ()
    "Find running postgres ports by checking listening sockets."
    (let* ((raw (shell-command-to-string "lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep postgres | awk '{print $9}' | grep -oE '[0-9]+$' | sort -u"))
           (ports (seq-filter (lambda (s) (not (string-empty-p s)))
                              (split-string raw "\n"))))
      (mapcar #'string-to-number ports)))

  (defun pgmacs-open-connection ()
    "Connect to a PostgreSQL database.
Auto-detects from environment (PGPORT/PGHOST/PGUSER) or discovers running
postgres instances. With prefix arg (C-u), always prompt for connection details."
    (interactive)
    (let* ((env-host (getenv "PGHOST"))
           (env-port (getenv "PGPORT"))
           (env-user (getenv "PGUSER"))
           (running-ports (pgmacs--detect-ports))
           (host (or env-host "localhost"))
           (port (cond
                  (current-prefix-arg nil)  ; force prompt
                  (env-port (string-to-number env-port))
                  ((= (length running-ports) 1) (car running-ports))
                  (running-ports
                   (string-to-number
                    (completing-read "Port: " (mapcar #'number-to-string running-ports) nil t)))
                  (t nil)))
           (port (or port
                     (read-number "Port: " 5432)))
           (user (or env-user "ridget"))
           (raw (shell-command-to-string
                  (format "psql -h %s -p %d -U %s -t -A -c \"SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname\""
                          host port user)))
           (databases (seq-filter (lambda (s) (not (string-empty-p s)))
                                  (split-string raw "\n"))))
      (if (not databases)
          (message "No databases found on %s:%d (is postgres running?)" host port)
        (let ((db (completing-read (format "Database (%s:%d): " host port) databases nil t)))
          (pgmacs host port user nil db))))))

;; ---------------------------------------------------------------------------
;; OBSIDIAN
;; ---------------------------------------------------------------------------
(use-package! obsidian
  :config
  (obsidian-specify-path "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain")
  (global-obsidian-mode t)
  :custom
  (obsidian-inbox-directory "inbox")
  :bind (:map obsidian-mode-map
         ("C-c C-o" . obsidian-follow-link-at-point)
         ("C-c C-b" . obsidian-backlink-jump)
         ("C-c C-l" . obsidian-insert-wikilink))
  :init
  (map! :leader
        (:prefix ("n" . "notes")
         (:prefix ("w" . "wiki")
          :desc "Search notes"   "s" #'obsidian-search
          :desc "New note"       "n" #'obsidian-capture
          :desc "Daily note"     "d" #'obsidian-daily-note
          :desc "Follow link"    "o" #'obsidian-follow-link-at-point
          :desc "Backlinks"      "b" #'obsidian-backlink-jump
          :desc "Insert link"    "l" #'obsidian-insert-wikilink
          :desc "Switch vault"   "v" #'obsidian-switch-vault))))

(defvar obsidian-vaults
  '(("second-brain" . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain")
    ("claude-coworker" . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude-coworker")
    ("archive" . "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/archive"))
  "Alist of vault names to paths. Add new vaults here.")

(defun obsidian-switch-vault ()
  "Switch the active Obsidian vault."
  (interactive)
  (let* ((name (completing-read "Vault: " (mapcar #'car obsidian-vaults) nil t))
         (path (cdr (assoc name obsidian-vaults))))
    (obsidian-specify-path path)
    (setq obsidian-inbox-directory "inbox")
    (message "Switched to vault: %s (%s)" name path)))

;; ---------------------------------------------------------------------------
;; AI CODING TOOLS
;; ---------------------------------------------------------------------------
(use-package! eca
  :commands (eca eca-stop eca-chat-toggle-window)
  :init
  (map! :leader
        (:prefix ("A" . "ai")
         :desc "ECA Chat"    "a" #'eca-chat-toggle-window
         :desc "ECA Start"   "s" #'eca
         :desc "ECA Stop"    "S" #'eca-stop
         :desc "Agent Shell" "c" #'agent-shell))
  :config
  (set-evil-initial-state! 'eca-chat-mode 'insert))

(use-package! agent-shell
  :commands (agent-shell)
  :config
  (setq agent-shell-preferred-agent-config 'claude-code)
  ;; Insert state: space types normally for prompts
  ;; ESC → normal state: SPC leader, window nav, all vim bindings work
  (set-evil-initial-state! 'agent-shell-mode 'insert)
  ;; In normal state, RET activates button at point (toggle sections)
  (map! :map agent-shell-mode-map
        :n "RET" #'push-button
        :n "TAB" #'agent-shell-next-item
        :n [backtab] #'agent-shell-previous-item))

(defun devbox-services-up ()
  "Run `devbox services up` in a project-root vterm buffer."
  (interactive)
  (let* ((root (projectile-project-root))
         (name (projectile-project-name))
         (buf-name (format "*devbox:%s*" name)))
    (unless root
      (user-error "Not in a project"))
    (let ((default-directory root))
      (if-let ((buf (get-buffer buf-name)))
          (pop-to-buffer buf)
        (let ((buf (vterm buf-name)))
          (vterm-send-string (format "cd %s && devbox services up\n" (shell-quote-argument root)))
          buf)))))

(map! :leader
      :desc "Devbox services up" "p u" #'devbox-services-up)

;; ---------------------------------------------------------------------------
;; MACHINE-SPECIFIC
;; ---------------------------------------------------------------------------
(load! "config.local" doom-user-dir t)
