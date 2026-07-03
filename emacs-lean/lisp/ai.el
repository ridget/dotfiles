;;; lisp/ai.el --- ECA chat + Agent Shell coding agent -*- lexical-binding: t; -*-

;;; ECA — chat interface (editor-code-assistant/eca-emacs, GitHub-only)
(use-package eca
  :vc (:url "https://github.com/editor-code-assistant/eca-emacs" :rev :newest)
  :commands (eca eca-stop eca-chat-toggle-window)
  :config
  ;; Start in insert state so the buffer is ready to type
  (add-hook 'eca-chat-mode-hook #'evil-insert-state)
  ;; RET in normal state submits without switching to insert first
  (with-eval-after-load 'evil
    (evil-define-key 'normal eca-chat-mode-map
      (kbd "RET") #'eca-chat--key-pressed-return)))

;;; Agent Shell — coding agent (claude-code / cursor, MELPA)
(use-package agent-shell
  :vc (:url "https://github.com/xenodium/agent-shell" :rev :newest)
  :commands (agent-shell agent-shell-new-shell)
  :config
  (setq agent-shell-preferred-agent-config 'claude-code)

  ;;; Headroom proxy — run `headroom proxy` separately (default port 8787).
  ;;; Routes Anthropic calls through the proxy for token savings attribution.
  (defconst +agent-shell-headroom-port 8787)

  (defun +agent-shell/headroom-project-name ()
    (file-name-nondirectory (directory-file-name default-directory)))

  (defun +agent-shell/headroom-proxy-urls (&optional project)
    (let* ((port +agent-shell-headroom-port)
           (project (or project (+agent-shell/headroom-project-name)))
           (anthropic (if (string-empty-p project)
                          (format "http://127.0.0.1:%d" port)
                        (format "http://127.0.0.1:%d/p/%s" port project)))
           (openai (if (string-empty-p project)
                       (format "http://127.0.0.1:%d/v1" port)
                     (format "http://127.0.0.1:%d/p/%s/v1" port project))))
      (list anthropic openai)))

  (defun +agent-shell/headroom-claude-environment ()
    (let* ((urls (+agent-shell/headroom-proxy-urls))
           (project (+agent-shell/headroom-project-name))
           (vars (list :inherit-env t
                       "ANTHROPIC_BASE_URL" (car urls)
                       "ENABLE_TOOL_SEARCH" "true")))
      (when (and project (not (string-empty-p project)))
        (setq vars (append vars
                           (list "ANTHROPIC_CUSTOM_HEADERS"
                                 (format "x-headroom-project: %s" project)))))
      (apply #'agent-shell-make-environment-variables vars)))

  ;; Recompute proxy env each time a client starts (picks up current project dir)
  (advice-add 'agent-shell-anthropic-make-claude-client :before
    (lambda (&rest _)
      (setq agent-shell-anthropic-claude-environment
            (+agent-shell/headroom-claude-environment)))
    '((name . +agent-shell/inject-headroom-claude-env)))

  ;; Start in emacs state so widget navigation and input work naturally
  (add-hook 'agent-shell-mode-hook #'evil-emacs-state)

  ;; Diff buffers spawned by agent-shell also start in emacs state
  (add-hook 'diff-mode-hook
            (lambda ()
              (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                (evil-emacs-state))))

  ;; Navigation between items (tool calls, messages)
  (with-eval-after-load 'general
    (general-def agent-shell-mode-map
      "TAB"     #'agent-shell-next-item
      [backtab] #'agent-shell-previous-item
      "C-j"     #'agent-shell-next-item
      "C-k"     #'agent-shell-previous-item)))

;;; Switch between claude-code and cursor agents
(defun my/agent-shell-switch-agent (agent)
  "Switch preferred agent config and open a new shell."
  (interactive
   (list (intern (completing-read "Agent: " '(claude-code cursor) nil t))))
  (setq agent-shell-preferred-agent-config agent)
  (agent-shell-new-shell))

;;; Pi — AI coding agent TUI (https://pi.dev); install: npm i -g @pi-dev/cli
(defun my/pi ()
  "Open a ghostel buffer running `pi` at the current project root.
Reuses an existing *pi:<project>* buffer if already open."
  (interactive)
  (let* ((pr (ignore-errors (project-current)))
         (root (if pr (project-root pr) default-directory))
         (name (file-name-nondirectory (directory-file-name root)))
         (buf-name (format "*pi:%s*" name)))
    (if-let ((buf (get-buffer buf-name)))
        (pop-to-buffer buf)
      (let ((default-directory root))
        (ghostel buf-name)
        (with-current-buffer buf-name
          (ghostel-send-string "pi\n"))))))

;;; Leader bindings — SPC a for AI
(with-eval-after-load 'general
  (+leader
    :infix "a"
    ""  '(:ignore t                   :wk "ai")
    "a" '(agent-shell                 :wk "agent shell")
    "n" '(agent-shell-new-shell       :wk "new agent shell")
    "p" '(my/pi                       :wk "pi agent")
    "c" '(eca-chat-toggle-window      :wk "chat")
    "s" '(eca                         :wk "start chat")
    "S" '(eca-stop                    :wk "stop chat")
    "A" '(my/agent-shell-switch-agent :wk "switch agent")))

;;; ai.el ends here
