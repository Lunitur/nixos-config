;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package:
;;
;;   1. Declare them here in a `package!' statement,
;;   2. Run 'doom sync' in the shell,
;;   3. Restart Emacs.
;;
;; Use 'C-h f package\!' to look up documentation for the `package!' macro.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)
(package! lean4-mode
  :recipe (:host github
           :repo "leanprover-community/lean4-mode"
           :files ("*.el" "data")))

(package! mcp
  :recipe (:host github
           :repo "lizqwerscott/mcp.el"))

(package! nushell-mode)

(package! dired-preview)

(package! org-fragtog)
(package! citar)

(package! ai-code
  :recipe (:host github :repo "tninja/ai-code-interface.el"))

(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

(package! ghostel)

;; Typst major mode; parsing uses Emacs's built-in treesit support.
(package! typst-ts-mode
  ;; Emacs 31 generates an unloadable autoload for `define-compilation-mode'.
  :recipe (:build (:not autoloads)))

;; Julia Workbench release, including runtime/server helpers on every host.
(package! julia-workbench
  :recipe (:host github :repo "Lunitur/julia-workbench"
           :files ("julia-workbench*.el" "julia")
           ;; Julia's setup preserves template symlinks when copying them to
           ;; its cache.  Build these two assets as files so setup is repeatable.
           :post-build
           (let ((templates (expand-file-name
                             "julia/server-environment/"
                             (straight--build-dir "julia-workbench"))))
             (dolist (name '("Project.toml" "Manifest.toml"))
               (let ((file (expand-file-name name templates)))
                 (when (file-symlink-p file)
                   (let ((copy (make-temp-file (concat file "."))))
                     (copy-file (file-truename file) copy t)
                     (rename-file copy file t)))))))
  :pin "e6f3bf2e44ec2ce6ce2485ab971d4fd51fe7a93e")
