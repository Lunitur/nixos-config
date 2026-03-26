;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Karlo Pušelj"
      user-mail-address "karlo.puselj@gmail.com")

(after! mu4e
  (setq mu4e-change-filenames-when-moving t
        mu4e-update-interval (* 5 60)
        mu4e-get-mail-command "mbsync -a"
        mu4e-maildir "~/.mail")

  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "Gmail"
          :match-func (lambda (msg)
                        (when msg
                          (string-match-p "^/gmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "karlo.puselj@gmail.com")
                  (user-full-name . "Karlo Pušelj")
                  (mu4e-drafts-folder . "/gmail/[Gmail]/Drafts")
                  (mu4e-sent-folder . "/gmail/[Gmail]/Sent Mail")
                  (mu4e-trash-folder . "/gmail/[Gmail]/Trash")
                  (mu4e-refile-folder . "/gmail/[Gmail]/All Mail")
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type . starttls)
                  (message-send-mail-function . message-send-mail-with-sendmail)
                  (sendmail-program . "msmtp")
                  (message-sendmail-extra-arguments . ("--read-envelope-from" "-a" "gmail"))))
         (make-mu4e-context
          :name "Anarhizam"
          :match-func (lambda (msg)
                        (when msg
                          (string-match-p "^/anarhizam" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "carjin@anarhizam.org")
                  (user-full-name . "Karlo Pušelj")
                  (mu4e-drafts-folder . "/anarhizam/Drafts")
                  (mu4e-sent-folder . "/anarhizam/Sent")
                  (mu4e-trash-folder . "/anarhizam/Trash")
                  (mu4e-refile-folder . "/anarhizam/Archive")
                  (smtpmail-smtp-server . "mail.anarhizam.org")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type . starttls)
                  (message-send-mail-function . message-send-mail-with-sendmail)
                  (sendmail-program . "msmtp")
                  (message-sendmail-extra-arguments . ("--read-envelope-from" "-a" "anarhizam")))))))

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;; (add-hook! 'hook function)
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
(setq shell-file-name (executable-find
                       "bash"))

(setq-default vterm-shell
              "/run/current-system/sw/bin/nu") (setq-default
              explicit-shell-file-name "/run/current-system/sw/bin/nu")

;; Show documentation in a popup
(corfu-popupinfo-mode)

(add-hook!
 'nix-mode-hook
 (add-hook 'before-save-hook
           'nix-format-before-save))

(require 'f)
(after! gptel
  (setq gptel-model 'gemini-3-flash-preview
        gptel-backend
        (gptel-make-gemini "Gemini"
          :key (f-read-text "~/Nextcloud/gemini.key")
          :stream t
          :models '(gemini-3-flash-preview)))

  (gptel-make-ollama "Ollama"
    :host "centaur:11434"
    :stream t
    :models '(qwen3-coder-next)))

(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold (* 100 1024 1024))

(after! eglot
  (add-to-list 'eglot-server-programs
               '((elixir-mode elixir-ts-mode heex-mode phoenix-heex-mode) . ("expert" "--stdio")))

  ;; Disable expensive features that might cause freezes in large templates
  ;; (add-to-list 'eglot-ignored-server-capabilities :documentHighlightProvider)
  ;; (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider)
  ;; (add-to-list 'eglot-ignored-server-capabilities :semanticTokensProvider)

  ;; (setq eglot-events-buffer-size 0)
  (setq eglot-sync-timeout 10)
  ;; (setq eglot-send-changes-idle-time 1.0)
  )

(after! consult
  ;; Automatically preview files with a 0.2-second delay while scrolling
  (setq consult-preview-key '(:debounce 0.2 any)))

;; (use-package! mcp
;;   :after gptel
;;   :init
;;   (setq mcp-hub-servers
;;         '(("filesystem" . (:command "nix" :args ("shell" "nixpkgs#nodejs" "-c" "npx" "-y" "@modelcontextprotocol/server-filesystem") :roots ("/home/carjin/nixos" "/home/carjin/projects")))))
;;   :config
;;   (require 'mcp-hub)
;;   (require 'gptel-integrations)

;;   ;; Start all defined servers automatically
;;   (mcp-hub-start-all-server)

;;   ;; Automatically connect gptel to the MCP servers
;;   (gptel-mcp-connect))

(use-package! nushell-mode)

(after! ess
  (setq ess-ask-for-ess-directory nil
        ess-local-process-name "R"))

(use-package! dired-preview
  :hook (dired-mode . dired-preview-mode)
  :config
  (setq dired-preview-delay 0.1)
  ;; keep previews from freezing emacs on massive files
  (setq dired-preview-max-size (expt 2 20)))

(after! dired
  (map! :map dired-mode-map
        :n "J" #'dired-preview-page-down
        :n "K" #'dired-preview-page-up))

(setq evil-esc-delay 0)

(setq projectile-switch-project-action #'projectile-dired)

(use-package! org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

(use-package! citar
  :after org
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar))
