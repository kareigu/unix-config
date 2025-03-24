;; init.el -*- lexical-binding: t; -*-
;;;;;;;;;;;
;; UTILS ;;
;;;;;;;;;;;
(defun conf-dir(&optional path)
  (expand-file-name (or path "") user-emacs-directory))
(defun temp-dir(path)
  (let ((temp-dir (expand-file-name path temporary-file-directory)))
    (unless (file-exists-p temp-dir)
      (make-directory temp-dir))
    temp-dir))

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
(when window-system
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(menu-bar-mode -1)
(global-display-line-numbers-mode 1)
(prefer-coding-system 'utf-8-unix)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)
(setq ring-bell-function 'ignore)
(let ((temp-dir (temp-dir "emacs/")))
  (setq backup-directory-alist `((".*" . ,temp-dir)))
  (setq auto-save-file-name-transforms `((".*" ,temp-dir t)))
  (setq lock-file-name-transforms `((".*" ,temp-dir t)))
  (setq desktop-path `(,temp-dir)))
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq desktop-restore-frames nil)
(setq use-dialog-box nil)
(setq use-short-answers t)
(setq switch-to-prev-buffer-skip-regexp "\\*[^\\*]+\\*")
(setq c-basic-offset 4)
(setq scroll-margin 10)
(setq select-enable-clipboard nil)
(setq evil-normal-state-cursor 'hbar)
(setq evil-visual-state-cursor 'hbar)

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
  (defun search-configs() (interactive) (consult-fd (conf-dir) "init.el"))
  (defun grep-current-word() (interactive) (consult-ripgrep nil (current-word)))
  (defun save-session() (interactive) (desktop-save (car desktop-path) t))
  (defun load-session() (interactive) (desktop-read (car desktop-path)))
  :config
  (evil-mode 1)
  (evil-define-operator yank-to-plus-register (beg end &optional type register yank-handler)
    "Yank characters to the + register"
    :move-point nil
    :repeat nil
    (interactive "<R><x><y>")
    (evil-yank beg end type ?+ yank-handler))
  (evil-set-leader '(normal visual replace operator) (kbd "SPC"))
  (evil-define-key 'insert 'global
    (kbd "C-v") 'clipboard-yank
    (kbd "C-a") 'move-beginning-of-line
    (kbd "C-e") 'move-end-of-line)
  (evil-define-key 'normal 'global
    (kbd "<leader>.") 'find-file
    (kbd "<leader>bb") 'evil-switch-to-windows-last-buffer
    (kbd "<leader>bB") 'switch-to-buffer
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
    (kbd "<leader>sw") 'grep-current-word
    (kbd "<leader>sf") 'consult-fd
    (kbd "<leader>sb") 'consult-line
    (kbd "<leader>sB") 'consult-line-multi
    (kbd "<leader>sc") 'search-configs
    (kbd "<leader>p") "\"+p"
    (kbd "<leader>P") "\"+P"
    (kbd "<leader>y") 'yank-to-plus-register
    (kbd "<leader>Y") "\"+yy"
    (kbd "<leader>gs") 'git-gutter:popup-hunk
    (kbd "<leader>gr") 'git-gutter:revert-hunk
    (kbd "<leader>gu") 'git-gutter
    (kbd "<leader>mu") 'toggle-frame-maximized
    (kbd "<leader>qs") 'save-session
    (kbd "<leader>ql") 'load-session
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
(use-package corfu-terminal
  :ensure t
  :after corfu
  :init
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))
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
(use-package cmake-mode :ensure t :if (executable-find "cmake"))
(use-package toml-mode :ensure t)
(use-package zig-mode :ensure t :if (executable-find "zig"))
(use-package rust-mode :ensure t :if (or (executable-find "cargo") (executable-find "rustc")))
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

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

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
  :init
  (setq git-gutter:update-interval 2)
  :config
  (global-git-gutter-mode +1))

(use-package language-id
  :ensure t
  :vc (:url "https://github.com/lassik/emacs-language-id"))
(use-package format-all
  :ensure t
  :after language-id
  :config
  (define-format-all-formatter gersemi
    (:executable "gersemi")
    (:install)
    (:languages "CMake")
    (:features)
    (:format (format-all--buffer-easy executable)))
  (setq-default format-all-formatters
                '(("C" (clang-format))
                  ("C++" (clang-format))
                  ("Rust" (rustfmt))
                  ("TOML" (taplo-fmt))
                  ("CMake" (gersemi))
                  ("Shell" (shfmt)))))


(use-package emacs
  :hook (kill-emacs . save-session)
  :custom
  (enable-recursive-minibuffers t)
  (tab-always-indent 'complete)
  (read-extended-command-predicate #'command-completion-default-include-p))

;;;;;;;;;;;;;;;;;;;;
;; PERSIST VALUES ;;
;;;;;;;;;;;;;;;;;;;;

(defcustom krg-persist-file-name ".emacs.persist"
  "Filename for persist-file."
  :type 'string)
(defun krg-persist-file ()
  "Returns expanded path to current persist-file.
Filename for the file can be set using ‘krg-persist-file-name'."
  (conf-dir krg-persist-file-name))

(defun krg-save-persist-file ()
  "Save persist-file on disk at location defined by \\[krg-persist-file]."
  (let ((frame-left (frame-parameter (selected-frame) 'left))
        (frame-top (frame-parameter (selected-frame) 'top))
        (frame-width (frame-parameter (selected-frame) 'width))
        (frame-height (frame-parameter (selected-frame) 'height))
        (persist-file (krg-persist-file)))
    (with-temp-buffer
      (make-local-variable 'make-backup-files)
      (setq make-backup-files nil)
      (insert
       ";;; " krg-persist-file-name " -*- lexical-binding: t; -*-\n"
       ";;; " (current-time-string) " " (nth 1 (current-time-zone)) ".\n"
       "(setq initial-frame-alist '(\n"
       (format "  (top . %d)\n" (max frame-top 0))
       (format "  (left . %d)\n" (max frame-left 0))
       (format "  (width . %d)\n" (max frame-width 0))
       (format "  (height . %d)))\n" (max frame-height 0)))
      (when (file-writable-p persist-file)
        (write-file persist-file)))))

(defun krg-load-persist-file ()
  "Load persisted settings from the file location defined by \\[krg-persist-file]."
  (let ((persist-file (krg-persist-file)))
    (when (file-readable-p persist-file)
      (load-file persist-file))))

(when window-system
  (add-hook 'after-init-hook 'krg-load-persist-file)
  (add-hook 'kill-emacs-hook 'krg-save-persist-file))

(unless window-system
  (xterm-mouse-mode +1))
