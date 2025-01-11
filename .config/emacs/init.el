;; init.el -*- lexical-binding: t; -*-
;;;;;;;;;;;
;; UTILS ;;
;;;;;;;;;;;
(defun conf-dir(path) (concat user-emacs-directory path))

;;;;;;;;;;;;;;;;;;;;
;; REROUTE CUSTOM ;;
;;;;;;;;;;;;;;;;;;;;
(setq custom-file (conf-dir "emacs.custom.el"))
(when (file-exists-p custom-file)
  (load-file custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PACKAGE REPOSITORIES ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;;;;;;;;;;;;;;;;;;;;
;; BASIC SETTINGS ;;
;;;;;;;;;;;;;;;;;;;;
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)
(setq ring-bell-function 'ignore)
(setq backup-directory-alist '(("." . (conf-dir "backup/"))))
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq c-basic-offset 4)
(setq scroll-margin 10)
(setq select-enable-clipboard nil)

;;;;;;;;;;;;;;;;
;; APPEARANCE ;;
;;;;;;;;;;;;;;;;
(set-frame-font "TX-02 13" nil t)
(use-package autothemer
  :ensure t)
(use-package cl-lib
  :ensure t)
(load-file (conf-dir "kanagawa-theme.el"))
(load-theme 'kanagawa)


;;;;;;;;;;;;;;;;;
;; EVIL CONFIG ;;
;;;;;;;;;;;;;;;;;
(use-package evil
  :ensure t
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (defun kill-current-buffer() (interactive) (kill-buffer (current-buffer)))
  (defun kill-other-buffers()
    (interactive)
    (dolist (elt (buffer-list))
      (when (not (eql elt (current-buffer)))
        (message "Closing " (buffer-name elt))
        (kill-buffer elt))))
  :config
  (evil-mode 1)
  (evil-define-operator yank-to-plus-register (beg end &optional type register yank-handler)
    "Yank characters to the + register"
    :move-point nil
    :repeat nil
    (interactive "<R><x><y>")
    (evil-yank beg end type ?+ yank-handler))
  (evil-set-leader '(normal visual replace operator) (kbd "SPC"))
  (evil-define-key 'normal 'global
    (kbd "<leader>.") 'find-file
    (kbd "<leader>bb") 'switch-to-buffer
    (kbd "<leader>bs") 'consult-buffer
    (kbd "<leader>bB") 'project-switch-to-buffer
    (kbd "<leader>bd") 'kill-current-buffer
    (kbd "<leader>bD") 'kill-buffer
    (kbd "<leader>bo") 'kill-other-buffers
    (kbd "<leader>SPC") 'project-find-file
    (kbd "<leader>he") 'eval-buffer
    (kbd "<leader>hf") 'describe-function
    (kbd "<leader>hv") 'describe-variable
    (kbd "<leader>cc") 'compile
    (kbd "<leader>cf") 'format-all-buffer
    (kbd "<leader>cF") 'format-all-region
    (kbd "<leader>sg") 'consult-ripgrep
    (kbd "<leader>sf") 'consult-fd
    (kbd "<leader>sb") 'consult-line
    (kbd "<leader>sB") 'consult-line-multi
    (kbd "<leader>p") "\"+p"
    (kbd "<leader>P") "\"+P"
    (kbd "<leader>y") 'yank-to-plus-register
    (kbd "<leader>Y") "\"+yy"
    (kbd "<leader>gs") 'git-gutter:popup-hunk
    (kbd "<leader>gr") 'git-gutter:revert-hunk
    (kbd "<leader>gu") 'git-gutter
    (kbd "<leader>mu") 'toggle-frame-maximized
    (kbd "[c") 'git-gutter:previous-hunk
    (kbd "]c") 'git-gutter:next-hunk
    (kbd "L") 'evil-next-buffer
    (kbd "H") 'evil-prev-buffer
    (kbd "gC") 'comment-box
    (kbd "C-h") 'evil-window-left
    (kbd "C-j") 'evil-window-down
    (kbd "C-k") 'evil-window-up
    (kbd "C-l") 'evil-window-right))
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))
(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))
(use-package evil-commentary
  :after evil
  :ensure t
  :config
  (evil-commentary-mode))
(use-package evil-goggles
  :ensure t
  :init
  (setq evil-goggles-duration 0.05)
  :config
  (evil-goggles-mode))

;;;;;;;;;;;;;;;;;;;;;;;
;; COMPLETION CONFIG ;;
;;;;;;;;;;;;;;;;;;;;;;;
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  :config
  (vertico-mode))

(use-package corfu
  :ensure t
  :init
  (setq corfu-auto t)
  (global-corfu-mode)
  (define-key corfu-map (kbd "C-n") 'corfu-next)
  (define-key corfu-map (kbd "C-p") 'corfu-previous)
  (define-key corfu-map (kbd "C-l") 'corfu-insert)
  (define-key corfu-map (kbd "C-e") 'corfu-reset))
(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-keyword))

;;;;;;;;;;;;;;;;;;;;
;; LANGUAGE MODES ;;
;;;;;;;;;;;;;;;;;;;;
(use-package cmake-mode :ensure t)
(use-package toml-mode :ensure t)
(use-package zig-mode :ensure t)
(use-package rust-mode :ensure t)
(mapc 'load (file-expand-wildcards (conf-dir "local-modes/*.el")))


;;;;;;;;;;;;;;;;;;;;
;; OTHER PACKAGES ;;
;;;;;;;;;;;;;;;;;;;;
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package consult
  :ensure t
  :hook (completion-list-mode . consult-preview-at-point-mode)
  )

(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode +1))

(use-package language-id
  :ensure t
  :vc (:url "https://github.com/lassik/emacs-language-id"))
(use-package format-all
  :ensure t
  :after language-id
  :commands format-all-mode
  :hook (prog-mode . format-all-mode)
  :config)


(use-package emacs
  :custom
  (enable-recursive-minibuffers t)
  (tab-always-indent 'complete)
  (read-extended-command-predicate #'command-completion-default-include-p))
