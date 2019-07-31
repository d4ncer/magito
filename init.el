;;; init.el --- Config for stand alone magit  -*- lexical-binding: t; -*-

;;; Commentary:

;; This serves as the config associated with a
;; emacs-as-a-git-client

;;; Code:

;; Supports only 26+
(when (version< emacs-version "26")
  (error "This version of Emacs is not supported"))

(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))

(setq evil-want-integration t)
(setq evil-want-keybinding nil)

(setq gc-cons-threshold (* 800 1024))

;; Bootstrap straight

(setq package-enable-at-startup nil)

(eval-and-compile
  (defvar bootstrap-version 5)
  (defvar bootstrap-file (concat user-emacs-directory "straight/repos/straight.el/bootstrap.el")))

(unless (file-exists-p bootstrap-file)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
       'silent 'inhibit-cookies)
    (goto-char (point-max))
    (eval-print-last-sexp)))

(defconst straight-cache-autoloads t)
(defconst straight-check-for-modifications 'live)

(require 'straight bootstrap-file t)

;; Setup basic packages

(straight-use-package 'dash)
(straight-use-package 'f)
(straight-use-package 's)
(straight-use-package 'noflet)
(straight-use-package 'memoize)
(straight-use-package 'general)
(straight-use-package 'doom-modeline)
(straight-use-package 'doom-themes)
(straight-use-package 'hydra)
(straight-use-package 'evil)
(straight-use-package 'evil-collection)
(straight-use-package 'magit)
(straight-use-package 'evil-magit)
(straight-use-package 'git-timemachine)
(straight-use-package 'pretty-hydra)
(straight-use-package 'which-key)
(straight-use-package 'bind-map)

(require 'recentf)
(require 'dash)
(require 'general)
(require 'f)
(require 's)
(require 'menu-bar)
(require 'tool-bar)
(require 'scroll-bar)
(require 'doom-modeline)
(require 'doom-themes)
(require 'hydra)
(require 'evil)
(require 'evil-collection)
(require 'magit)
(require 'evil-magit)
(require 'git-timemachine)
(require 'which-key)
(require 'pretty-hydra)

;; Setup basic stuff

(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)

(defun magito/init ()
  "Initialise."
  (toggle-frame-maximized))

(defalias #'yes-or-no-p #'y-or-n-p)

;; Scroll smoothly.

(setq scroll-preserve-screen-position t)
(setq scroll-margin 0)
(setq scroll-conservatively 101)

;; Instantly display current keystrokes in mini buffer

(setq echo-keystrokes 0.02)

;; Clean up visuals

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Setup themes

(load-theme 'doom-nord t)
(general-setq doom-modeline-icon nil)
(doom-modeline-mode 1)

;; The meat and potatoes

(evil-mode +1)
(which-key-mode)

(setq evil-collection-mode-list '(git-timemachine help info))
(evil-collection-init)

(general-setq magit-log-section-commit-count 0)
(general-setq magit-diff-refine-hunk t)
(general-setq magit-section-visibility-indicator nil)
(general-setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
(magit-status-setup-buffer default-directory)

;; Timemachine

(pretty-hydra-define magito/timemachine
  (:title "Hot Git Time Machine" :pre (unless (bound-and-true-p git-timemachine-mode) (call-interactively 'git-timemachine)) :post (when (bound-and-true-p git-timemachine-mode) (git-timemachine-quit)) :foreign-keys run :quit-key "q")
  ("Goto"
   (("p" git-timemachine-show-previous-revision "previous commit")
    ("n" git-timemachine-show-next-revision "next commit")
    ("c" git-timemachine-show-current-revision "current commit")
    ("g" git-timemachine-show-nth-revision "nth commit"))

   "Misc"
   (("Y" git-timemachine-kill-revision "copy hash"))))

;; Base bindings

(pretty-hydra-define magito/base
  (:title "Magito" :foreign-keys run :quit-key "C-g")
  ("File/Project"
   (("f" find-file "find file" :exit t))

   "Git"
   (("t" magito/timemachine/body "time machine" :exit t)
    ("s" magit-status "status" :exit t))))

(general-define-key :states '(normal motion visual)
                    "SPC" 'magito/base/body)

(general-define-key :keymaps 'magit-status-mode-map :states 'normal
                    "SPC" 'magito/base/body
                    "q" 'kill-emacs)

(add-hook 'emacs-startup-hook #'magito/init)

;; Extend this with personal config, if it exists

(-when-let* ((personal-config "~/.magito-config.el")
             (config-exists-p (f-exists-p personal-config)))
  (load-file personal-config))

;;; init.el ends here
