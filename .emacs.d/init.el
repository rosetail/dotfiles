;; measure startup time
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))


;; disabe garbage collection during startup
;; TODO: see why emacs always reports 13 garbage collections during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      file-name-handler-alist nil)

;; re-enable garbage collection after everything is done
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 16777216 ; 16mb
                  gc-cons-percentage 0.1)))

;; intialize packages and add repositories
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(setq package-archive-priorities
      '(("melpa-stable" . 2)
        ("gnu" . 1)
        ("melpa" . 0)))

;; set up use-package
(require 'use-package)
(setq use-package-always-ensure t)

(use-package doom-modeline)
;; load theme
(use-package base16-theme
  :init (load-theme 'base16-eighties t)
  :custom
  ;; disable menubar, toolbar, and scrollbar
  ;; TODO: see about using general-custom
  (menu-bar-mode nil)
  (scroll-bar-mode nil)
  (tool-bar-mode nil)
  (inhibit-startup-screen t)) ; skip startup screen and go to scratch buffer

(use-package general)

(use-package evil
  :after general
  :init
  (setq-default cursor-in-non-selected-windows nil)
  (setq evil-want-keybinding nil)
  :general

  (:keymaps 'global-map
            :states '(motion normal visual operator)
            "n"		'evil-next-visual-line
            "N"		'evil-join
            "e"		'evil-previous-visual-line
            "E"		'evil-lookup
            "k"		'evil-search-next
            "K"		'evil-search-previous
            "l"		'undo-tree-undo
            "f"		'evil-forward-word-end
            "F"		'evil-forward-WORD-end
            "t"		'evil-find-char
            "T"		'evil-find-char-backward
            "j"		'evil-find-char-to
            "J"		'evil-find-char-to-backward
            "C-."	'next-important-buffer
            "S-SPC"	'evil-execute-in-god-state
            "SPC"	(lookup-key global-map (kbd "C-c"))
            [escape]	'keyboard-quit
            "TAB"	'indent-for-tab-command)

  (:keymaps '(ivy-mode-map ivy-minibuffer-map)
   "C-e" 'ivy-previous-line)
  (general-translate-key nil '(motion normal visual operator)
    "u" "i"
    "U" "I"
    "I" "L"
    "i" "l")

  :config (evil-mode 1))

;; enable vim keybindings everywhere
(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-setup-minibuffer t
        evil-collection-company-use-tng nil) ; keep company behavior default, not like vim

  ;; translate hjkl to hnei. Also translate with C- and M- prefixes
  (defun my-hjkl-rotation (_mode mode-keymaps &rest _rest)
    (evil-collection-translate-key 'normal mode-keymaps
      "n" "j"
      "e" "k"
      "i" "l"
      "j" "e"
      "k" "n"
      "l" "i"
      (kbd "C-n") (kbd "C-j")
      (kbd "C-e") (kbd "C-k")
      (kbd "C-k") (kbd "C-n")
      (kbd "C-j") (kbd "C-e")
      (kbd "M-n") (kbd "M-j")
      (kbd "M-e") (kbd "M-k")
      (kbd "M-k") (kbd "M-n")
      (kbd "M-j") (kbd "M-e"))
    ;; called after evil-collection makes its keybindings
    (add-hook 'evil-collection-setup-hook #'my-hjkl-rotation)))
