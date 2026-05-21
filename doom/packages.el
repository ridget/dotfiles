;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! lsp-tailwindcss :recipe (:host github :repo "merrickluo/lsp-tailwindcss"))
(package! pbcopy)
(package! evil-matchit)

(package! eca :recipe (:host github :repo "editor-code-assistant/eca-emacs" :files ("*.el")))
(package! agent-shell)
(package! pgmacs :recipe (:host github :repo "emarsden/pgmacs"))
(package! obsidian :recipe (:host github :repo "licht1stein/obsidian.el"))
