;;; lisp/db.el --- PostgreSQL via pgmacs -*- lexical-binding: t; -*-

(use-package pgmacs
  :vc (:url "https://github.com/emarsden/pgmacs" :rev :newest)
  :commands (pgmacs pgmacs-open-connection)
  :config
  (defun pgmacs--detect-ports ()
    "Find running postgres ports by checking listening sockets."
    (let* ((raw (shell-command-to-string
                 "lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep postgres | awk '{print $9}' | grep -oE '[0-9]+$' | sort -u"))
           (ports (seq-filter (lambda (s) (not (string-empty-p s)))
                              (split-string raw "\n"))))
      (mapcar #'string-to-number ports)))

  (defun pgmacs-open-connection ()
    "Connect to a PostgreSQL database.
Auto-detects from PGPORT/PGHOST/PGUSER environment, or discovers running
postgres instances via lsof. C-u to force manual prompt."
    (interactive)
    (let* ((env-host (getenv "PGHOST"))
           (env-port (getenv "PGPORT"))
           (env-user (getenv "PGUSER"))
           (running-ports (pgmacs--detect-ports))
           (host (or env-host "localhost"))
           (port (cond
                  (current-prefix-arg nil)
                  (env-port (string-to-number env-port))
                  ((= (length running-ports) 1) (car running-ports))
                  (running-ports
                   (string-to-number
                    (completing-read "Port: " (mapcar #'number-to-string running-ports) nil t)))
                  (t nil)))
           (port (or port (read-number "Port: " 5432)))
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

;;; Leader binding — SPC d (single command, no group needed)
(with-eval-after-load 'general
  (+leader "d" '(pgmacs-open-connection :wk "database")))

;;; db.el ends here
