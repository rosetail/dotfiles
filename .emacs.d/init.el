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
(setq use-package-compute-statistics t
      use-package-always-ensure t)

;; indent with space, not tab
(setq-default indent-tabs-mode nil)

;; stop putting backup files everyphere
(setq version-control t       ;; Use version numbers for backups.
      kept-new-versions 10    ;; Number of newest versions to keep.
      kept-old-versions 0     ;; Number of oldest versions to keep.
      delete-old-versions t   ;; Don't ask to delete excess backup versions.
      backup-by-copying t     ;; Copy all files, don't rename them.
      vc-make-backup-files t  ;; also backup files under version control
      backup-directory-alist '(("" . "~/.emacs.d/backup/per-save")))

;; set default font
(set-frame-font "monospace-11" nil t)

;; load theme
(use-package base16-theme
  :init (load-theme 'base16-eighties t)
  :custom
  ;; skip startup screen and go to scratch buffer
  ;; TODO: see about using general-custom
  (inhibit-startup-screen t))

;; setup modeline
;; TODO: switch to something that starts up faster
(use-package doom-modeline
  :custom-face
  ;; (doom-modeline-bar ((t (:background "#f99157"))))
  (doom-modeline-evil-normal-state   ((t (:foreground "#99cc99"))))
  (doom-modeline-evil-insert-state   ((t (:foreground "#6699cc"))))
  (doom-modeline-evil-visual-state   ((t (:foreground "#f99157"))))
  (doom-modeline-evil-operator-state ((t (:foreground "#cc99cc"))))
  (doom-modeline-evil-motion-state   ((t (:foreground "#ffcc66"))))
  (doom-modeline-evil-replace-state  ((t (:foreground "#66cccc"))))
  (doom-modeline-evil-emacs-state    ((t (:foreground "#f2777a"))))
  ;; use window-setup-hook so modeline indicator face displays correctly
  :hook (window-setup . doom-modeline-mode))

;; show line numbers in fringe, but only in programming modes
(defun prog-mode-setup ()
  (display-line-numbers-mode)
  (highlight-numbers-mode 1))

(add-hook 'prog-mode-hook 'prog-mode-setup)
(add-hook 'conf-mode-hook 'prog-mode-setup)

;; enable word wrapping in modes deriving from text-mode
(add-hook 'text-mode-hook 'visual-line-mode)

;; make scrolling more like vim
(setq scroll-margin 2
      scroll-conservatively 10000
      scroll-preserve-screen-position t)

(use-package general
  :config
  ;; create leader key
  ;; bound to M-SPC in insert mode and SPC in all other modes
  (general-create-definer leader-def
    :states '(normal insert emacs motion visual operater)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    :prefix-map 'leader-prefix-map)

  ;; global leader keys
  (leader-def
    "a" 'avy-goto-subword-1
    ;; indent whole buffer
    "TAB" (lambda ()
            (interactive)
            (save-excursion
              (mark-whole-buffer)
              (indent-for-tab-command))))
  ;; we have to demand general to global leader keys get bound during init
  :demand t)

(use-package evil
  :demand t
  :init
  (setq-default cursor-in-non-selected-windows nil)
  (setq evil-want-keybinding nil)
  :general
  ;; alias C-e and M-e to C-p and M-p so scrolling with vim navigation keys works
  ;; this leaves us unable to access anything bound to C-e or M-e, but I don't really use thse keys
  ("C-e" (general-key "C-p")
   "M-e" (general-key "M-p"))
  ;; modify basic evil keybindings
  (:keymaps 'global-map
            :states '(motion normal visual operator)
            ;; make evil obey visual-line-mode
            "n"      'evil-next-visual-line
            "e"      'evil-previous-visual-line
            [escape] 'keyboard-quit
            "TAB"    'indent-for-tab-command)

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
  (setq evil-collection-setup-minibuffer nil
        evil-collection-company-use-tng nil) ; make company behave like emacs, not vim
  :config
  (evil-collection-init))

;; make sure we have flx so ivy does better fuzzy matching
(use-package flx :defer t)

(use-package ivy
  :init
  ;; use fuzzy search everywhere except swiper
  (setq ivy-re-builders-alist
        '((swiper . ivy--regex-plus)
          (t      . ivy--regex-fuzzy)))

  :general
  ;; C-x C-a is much more comfortable on colemak than C-x C-f
  ("C-x C-a" 'counsel-find-file
   ;; use counsel to insert unicode characters
   "C-x 8 RET" 'counsel-unicode-char
   ;; replace isearch with swiper
   "C-s" 'swiper)
  (:keymaps 'ivy-minibuffer-map
            ;; scroll through history with M-p
            ;; TODO: see why this binding isn't doing anything
            "M-p" 'ivy-previous-history-element
            ;; make escape work properly
            "ESC" 'minibuffer-keyboard-quit
            ;; make enter descend into directory instead of opening dired
            "RET" 'ivy-alt-done
            ;; make C-j open dired instead
            "C-j" 'ivy-immediate-done)
  :diminish ivy-mode
  :config
  (ivy-mode 1)
  :demand t)

(use-package counsel
  :after ivy
  :general
  (:keymaps 'swiper-map
            "ESC" 'minibuffer-keyboard-quit)
  :config
  (counsel-mode))

(use-package org
  :defer t
  :init
  (setq org-ellipsis " ▼")

  ;; make indentation work properly when editing org src
  (setq org-adapt-indentation nil
        org-edit-src-content-indentation 0
        org-src-tab-acts-natively t
        org-startup-indented t)

  :custom-face
  (org-block ((t (:foreground "#d3d0c8")))))

(use-package company
  :demand t
  :config (global-company-mode)
  :general
  ("C-<return>" 'company-complete))

(use-package avy :commands avy-goto-subword-1)
(use-package hydra)
(use-package smart-comment
  :general ("M-;" 'smart-comment))

(use-package aggressive-indent
  :demand t
  :config
  (global-aggressive-indent-mode 1)
  ;; don't enable in html mode
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode)

  ;; stop indenting the next line in c-like modes if ; is not entered yet
  (add-to-list
   'aggressive-indent-dont-indent-if
   '(and (derived-mode-p 'c++-mode)
         (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
                             (thing-at-point 'line))))))
(use-package undo-tree
  ;; TODO: make vim keybindings work here
  :demand t
  ;; make evil use undo tree
  :custom (evil-undo-system 'undo-tree)
  :init
  (leader-def "u" 'undo-tree-visualize)
  :config (global-undo-tree-mode))
(use-package which-key
  :demand t
  :config (which-key-mode 1))

(use-package smartparens
  :demand t
  :config
  (smartparens-global-strict-mode 1)
  ;; highlight matching delimiter
  (show-smartparens-global-mode 1)

  ;; enable default smartparens config
  (require 'smartparens-config)

  ;; bind <leader>-p to smartparens hydra
  (leader-def "p" 'hydra-smartparens/body)
  
  ;; hydra for most smartparens actions
  (defhydra hydra-smartparens (:hint nil)
    "
 Moving^^^^                       Slurp & Barf^^   Wrapping^^            Sexp juggling^^^^               Destructive
------------------------------------------------------------------------------------------------------------------------
 [_a_] beginning  [_n_] down      [_h_] bw slurp   [_R_]   rewrap        [_S_] split   [_t_] transpose   [_c_] change inner  [_w_] copy
 [_e_] end        [_N_] bw down   [_H_] bw barf    [_u_]   unwrap        [_s_] splice  [_A_] absorb      [_C_] change outer
 [_f_] forward    [_p_] up        [_l_] slurp      [_U_]   bw unwrap     [_r_] raise   [_E_] emit        [_k_] kill          [_g_] quit
 [_b_] backward   [_P_] bw up     [_L_] barf       [_(__{__[_] wrap (){}[]   [_j_] join    [_o_] convolute   [_K_] bw kill       [_q_] quit"
    ;; Moving
    ("a" sp-beginning-of-sexp)
    ("e" sp-end-of-sexp)
    ("f" sp-forward-sexp)
    ("b" sp-backward-sexp)
    ("n" sp-down-sexp)
    ("N" sp-backward-down-sexp)
    ("p" sp-up-sexp)
    ("P" sp-backward-up-sexp)
    
    ;; Slurping & barfing
    ("h" sp-backward-slurp-sexp)
    ("H" sp-backward-barf-sexp)
    ("l" sp-forward-slurp-sexp)
    ("L" sp-forward-barf-sexp)
    
    ;; Wrapping
    ("R" sp-rewrap-sexp)
    ("u" sp-unwrap-sexp)
    ("U" sp-backward-unwrap-sexp)
    ("(" sp-wrap-round)
    ("{" sp-wrap-curly)
    ("[" sp-wrap-square)
    
    ;; Sexp juggling
    ("S" sp-split-sexp)
    ("s" sp-splice-sexp)
    ("r" sp-raise-sexp)
    ("j" sp-join-sexp)
    ("t" sp-transpose-sexp)
    ("A" sp-absorb-sexp)
    ("E" sp-emit-sexp)
    ("o" sp-convolute-sexp)
    
    ;; Destructive editing
    ("c" sp-change-inner :exit t)
    ("C" sp-change-enclosing :exit t)
    ("k" sp-kill-sexp)
    ("K" sp-backward-kill-sexp)
    ("w" sp-copy-sexp)

    ("q" nil)
    ("g" nil)))


(use-package evil-smartparens
  :demand t
  :after smartparens-config
  :hook (smartparens-enabled . evil-smartparens-mode))
