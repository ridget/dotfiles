;;; lisp/projects.el --- project.el configuration -*- lexical-binding: t; -*-

;;; Auto-discover all projects under ~/projects/ on startup
(with-eval-after-load 'project
  (project-remember-projects-under "~/projects/" nil))

;;; Devbox services up — adapted from Doom config (projectile → project.el)
(defun devbox-services-up ()
  "Run `devbox services up` in a vterm buffer at the current project root."
  (interactive)
  (let* ((pr (project-current t))
         (root (project-root pr))
         (name (file-name-nondirectory (directory-file-name root)))
         (buf-name (format "*devbox:%s*" name)))
    (if-let ((buf (get-buffer buf-name)))
        (pop-to-buffer buf)
      (let ((default-directory root))
        (ghostel buf-name)))))

;;; projects.el ends here
