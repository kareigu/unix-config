;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "BerkeleyMono Nerd Font" :size 14))
(add-to-list 'default-frame-alist '(height . 58))
(add-to-list 'default-frame-alist '(width . 140))

(setq doom-theme 'kanagawa)
(setq kanagawa-theme-comment-italic nil)
(setq kanagawa-theme-keyword-italic nil)

(setq display-line-numbers-type t)

(setq org-directory "~/org/")

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq c-basic-offset 4)
(setq scroll-margin 10)

(+global-word-wrap-mode +1)

(map! :desc "Next buffer" :n "L" #'next-buffer)
(map! :desc "Next buffer" :n "H" #'previous-buffer)

(setq tab-always-indent t)
(setq select-enable-clipboard nil)

(setq doom-modeline-modal-modern-icon nil)

(remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)

