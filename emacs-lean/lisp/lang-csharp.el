;;; lisp/lang-csharp.el --- C# / Unity support -*- lexical-binding: t; -*-
;;; Loaded only when my/unity-enabled (see init.el / local.el).

;; csharp-ts-mode is built into Emacs 30; grammar auto-installs via treesit-auto
(use-package csharp-ts-mode
  :ensure nil
  :mode "\\.cs\\'")

;; Register with the deferred eglot starter in lsp.el (fires after envrc)
(add-to-list 'my/eglot-modes 'csharp-ts-mode)

;; Microsoft Roslyn LSP via the roslyn-language-server wrapper.
;; Install (Unity machine only): cargo install roslyn-language-server
;; The MS server uses a named-pipe / solution-open handshake, so the wrapper is
;; required for eglot. Verify the wrapper's exact stdio invocation from its README.
;; Fallback if the handshake is too fiddly: csharp-ls
;;   (dotnet tool install -g csharp-ls) with server entry ("csharp-ls").
(with-eval-after-load 'eglotexport DOTNET_GOTO_DEFINITION_SYMBOLIC_LINKS=true
  (add-to-list 'eglot-server-programs
               '(csharp-ts-mode . ("roslyn-language-server" "--stdio" "--autoLoadProjects"))))

;; Unity generated project metadata — .asmdef is JSON
(add-to-list 'auto-mode-alist '("\\.asmdef\\'" . json-ts-mode))

;; ShaderLab / HLSL / CG — syntax only, no LSP
(use-package shader-mode
  :mode ("\\.shader\\'" "\\.cginc\\'" "\\.cg\\'" "\\.hlsl\\'"))

;; Unity editor integration: ships a `code` shim so Unity recognizes Emacs as the
;; external editor and keeps regenerating .sln/.csproj (which the LSP resolves
;; Unity assemblies against). Forwards to emacsclient.
;; One-time Unity setup: Preferences > External Tools > External Script Editor
;;   → the unity.el `code` shim; Args: emacsclient -n +$(Line):$(Column) $(File)
;; Run Emacs as a daemon (emacs --daemon) so emacsclient round-trips work.
(use-package unity
  :hook (csharp-ts-mode . unity-mode))

;;; lang-csharp.el ends here
