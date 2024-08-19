;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "BerkeleyMono Nerd Font" :size 14))
(add-to-list 'default-frame-alist '(height . 58))
(add-to-list 'default-frame-alist '(width . 140))

(setq doom-theme 'kanagawa)
(setq display-line-numbers-type t)

(setq org-directory "~/org/")

(map! :desc "Next buffer" :n "L" #'next-buffer)
(map! :desc "Next buffer" :n "H" #'previous-buffer)

(remove-hook 'doom-first-buffer-hook #'smartparens-global-mode)
