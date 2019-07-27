;;; init.el --- Config for stand alone magit  -*- lexical-binding: t; -*-

;;; Commentary:

;; This serves as the config associated with a
;; emacs-as-a-git-client

;;; Code:

;; Supports only 26+
(when (version< emacs-version "26")
  (error "This version of Emacs is not supported"))

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

;; Setup basic packages & use-package

(straight-use-package 'dash)
(straight-use-package 'f)
(straight-use-package 's)
(straight-use-package 'noflet)
(straight-use-package 'memoize)
(straight-use-package 'general)

(defconst use-package-verbose t)

(straight-use-package 'use-package)
(straight-use-package 'bind-map)

(require 'recentf)
(require 'use-package)
(require 'dash)
(require 'general)
(require 'f)
(require 's)

;; Setup basic stuff

(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)

(defun magito/init ()
  "Initialise magito."
  (toggle-frame-maximized))

(defalias #'yes-or-no-p #'y-or-n-p)

;; Scroll smoothly.

(setq scroll-preserve-screen-position t)
(setq scroll-margin 0)
(setq scroll-conservatively 101)

;; Instantly display current keystrokes in mini buffer

(setq echo-keystrokes 0.02)

(use-package menu-bar
  :bind (("C-c e e" . toggle-debug-on-error))
  :if (bound-and-true-p menu-bar-mode)
  :config
  (menu-bar-mode -1))

(use-package tool-bar
  :if (bound-and-true-p tool-bar-mode)
  :config
  (tool-bar-mode -1))

(use-package scroll-bar
  :if (display-graphic-p)
  :config
  (scroll-bar-mode -1))

(use-package doom-themes
  :straight t
  :config
  (load-theme 'doom-one t))

(use-package doom-modeline
  :straight t
  :hook (emacs-startup . doom-modeline-mode)
  :custom
  (doom-modeline-icon nil))

(use-package magit
  :straight t
  :demand t
  :functions (magit-status-setup-buffer magit-display-buffer-fullframe-status-v1)
  :custom
  (magit-log-section-commit-count 0)
  (magit-diff-refine-hunk t)
  (magit-section-visibility-indicator nil)
  (magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  :config
  (magit-status-setup-buffer default-directory))

(add-hook 'emacs-startup-hook #'magito/init)

;; Extend this with personal config, if it exists

(-when-let* ((personal-config "~/.magito-config.el")
             (config-exists-p (f-exists-p personal-config)))
  (load-file personal-config))

;;; init.el ends here
