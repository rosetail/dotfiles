;;; -*- lexical-binding: t; -*-
;; lexical binding improves load time

;; measure startup time
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "Emacs ready in %s with %d garbage collections."
		     (format "%.2f seconds"
			     (float-time
			  (time-subtract after-init-time before-init-time)))
		     gcs-done)))

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

;; set default font
(set-frame-font "Inconsolata-11" nil t)

;; load theme
(use-package base16-theme
  :init (load-theme 'base16-eighties t)
  :custom
  ;; skip startup screen and go to scratch buffer
  ;; TODO: see about using general-custom
  (inhibit-startup-screen t))

;; setup modeline
;; TODO: switch to something that starts up faster
(use-package spaceline
  :config
  (spaceline-toggle-minor-modes-off)
  :init
  (spaceline-spacemacs-theme)
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state))

;; show line numbers in fringe, but only in programming modes
(defun prog-mode-setup ()
  (display-line-numbers-mode)
  (highlight-numbers-mode 1))

(add-hook 'prog-mode-hook 'prog-mode-setup)
(add-hook 'conf-mode-hook 'prog-mode-setup)

;; enable word wrapping in modes derivef from text-mode
(add-hook 'text-mode-hook 'visual-line-mode)

(use-package general)

(use-package evil
  :demand t
  :init
  (setq-default cursor-in-non-selected-windows nil)
  (setq evil-want-keybinding nil)
  :general
  ;; alias C-e and M-e to C-p and M-p so scrolling with vim navigation keys works
  ;; this leaves us unable to access anything bound to C-e or M-e, but I don't really use thse keys
  ("C-e" (general-key "C-p"))
  ("M-e" (general-key "M-p"))
  ;; modify basic evil keybindings
  (:keymaps 'global-map
            :states '(motion normal visual operator)
            ;; make evil obey visual-line-mode
            "n"		'evil-next-visual-line
            "e"		'evil-previous-visual-line
            [escape]	'keyboard-quit
            "TAB"	'indent-for-tab-command)

  :config
  ;; translate keybindings for colemak
  (general-translate-key nil '(motion normal visual operator)
    ;; change hjkl to hnei
    "n" "j"
    "e" "k"
    "i" "l"
    "N" "J"
    "E" "K"
    "I" "L"

    ;; rotate j t and f so j -> t -> f -> e
    "j" "t"
    "t" "f"
    "f" "e"
    "J" "T"
    "T" "F"
    "F" "E"

    ;; make k function as n so as not to disrupt muscle memory when searching
    "k" "n"
    "K" "N"

    ;; rotate u i and l so u -> i -> l -> u
    "u" "i"
    "i" "l"
    "l" "u"
    "U" "I"
    "I" "L"
    "L" "U")

  ;; enable evil mode
  (evil-mode 1))

;; enable vim keybindings everywhere
(use-package evil-collection
  :after evil
  :init
  (setq evil-collection-setup-minibuffer t
        evil-collection-company-use-tng nil)) ; make company behave like emacs, not vim

(use-package ivy
  :general
  ("C-x 8 RET" 'counsel-unicode-char)
  ("M-x"	   'counsel-M-x)
  ("C-x C-f"   'counsel-find-file)
  ("C-h f"	   'counsel-describe-function)
  ("C-h v"	   'counsel-describe-variable)
  ("M-X"	   'execute-extended-command)
  ("M-'"	   'swiper)
  :diminish ivy-mode
  :config
  (use-package flx
    :ensure t)
  (ivy-mode 1)
  (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy)))
  (require 'swiper)
  (define-key swiper-map [escape] 'minibuffer-keyboard-quit)
  (define-key ivy-minibuffer-map [escape] 'minibuffer-keyboard-quit)
  (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-immediate-done)
  (define-key ivy-minibuffer-map (kbd "RET") #'ivy-alt-done)
  :defer t)
