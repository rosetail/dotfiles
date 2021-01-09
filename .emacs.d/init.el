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
        ("melpa" . 1)
        ("gnu" . 0)))

;; set up use-package
(require 'use-package)
(setq use-package-compute-statistics t
      use-package-always-ensure t)

;; indent with space, not tab
(setq-default indent-tabs-mode nil)

;; enable eldoc
(global-eldoc-mode 1)

;; enable recentf-mode
(recentf-mode 1)

;; stop putting backup files everywhere
(setq version-control t       ;; Use version numbers for backups.
      kept-new-versions 10    ;; Number of newest versions to keep.
      kept-old-versions 0     ;; Number of oldest versions to keep.
      delete-old-versions t   ;; Don't ask to delete excess backup versions.
      backup-by-copying t     ;; Copy all files, don't rename them.
      vc-make-backup-files t  ;; also backup files under version control
      backup-directory-alist '(("" . "~/.emacs.d/backup/per-save"))) 

;; TODO: remove this
;; some dirs in home are symlinks pointing to /data, and this sometimes causes problems
;; this is a terrible hack to make emacs think that these are real dirs and not symlinks
(defun my/ignore-some-symlinks (dir)
  (replace-regexp-in-string "\\(/data/\\)\\(org\\|code\\|Documents\\)"
                            "~/" dir nil nil 1))
;; (advice-add #'file-truename :filter-return #'my/ignore-some-symlinks)
;; (advice-add #'buffer-file-name :filter-return #'my/ignore-some-symlinks)
(setq find-file-visit-truename t)

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
  (doom-modeline-evil-visual-state   ((t (:foreground "#66cccc"))))
  (doom-modeline-evil-operator-state ((t (:foreground "#cc99cc"))))
  (doom-modeline-evil-motion-state   ((t (:foreground "#ffcc66"))))
  (doom-modeline-evil-replace-state  ((t (:foreground "#f99157"))))
  (doom-modeline-evil-emacs-state    ((t (:foreground "#f2777a"))))
  :hook (after-init . doom-modeline-mode))

;; show line numbers in fringe, but only in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'conf-mode-hook 'display-line-numbers-mode)

;; enable word wrapping in modes deriving from text-mode
(add-hook 'text-mode-hook 'visual-line-mode)

;; show column number in modeline
(column-number-mode 1)

;; make scrolling more like vim
(setq scroll-margin 2
      scroll-conservatively 10000
      scroll-preserve-screen-position t)

;; set up indentation
(setq-default c-basic-offset 4
              cperl-indent-level 4)
(setq tab-width 4
      c-default-style "linux")

(use-package general
  :config
  ;; create leader key
  ;; bound to M-SPC in insert mode and SPC in all other modes
  (general-create-definer leader-def
    :states '(normal insert emacs motion visual operater)
    :keymaps 'override
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
  (setq evil-collection-setup-minibuffer nil)
  :custom (evil-collection-company-use-tng nil) ; make company behave like emacs, not vim
  :config
  (evil-collection-init))

;; TODO: actually learn these keybindings
(use-package evil-org
  :ensure t
  :after (evil org)
  :init
  ;; make keybindings work in insert mode
  (setq evil-org-use-additional-insert t
        ;; use colemak movement
        evil-org-movement-bindings '((up . "e") (down . "n") (left . "h") (right . "i"))

        ;; add keybindings for more thinds
        evil-org-key-theme '(navigation
                             insert
                             return
                             textobjects
                             additional
                             todo
                             heading
                             calendar))
  
  :hook ((org-mode . evil-org-mode)
         (evil-org-mode . evil-org-set-key-theme))
  :general
  (:keymaps 'evil-org-mode-map
            :states '(motion normal visual operator)
            "g i" 'org-down-element
            "U"   'evil-org-insert-line)
  (:keymaps 'org-agenda-mode-map
            :states '(motion normal visual operator)
            "n"   'org-agenda-next-line
            "e"   'org-agenda-previous-line
            "gn"  'org-agenda-next-item
            "ge"  'org-agenda-previous-item
            "gI"  'evil-window-bottom
            "C-n" 'org-agenda-next-item
            "C-e" 'org-agenda-previous-item
            "N"   'org-agenda-priority-down
            "E"   'org-agenda-priority-up
            "I"   'org-agenda-do-date-later
            "M-n" 'org-agenda-drag-line-forward
            "M-e" 'org-agenda-drag-line-backward
            "C-S-i" 'org-agenda-todo-nextset ; Original binding "C-S-<right>"
            "l"   'org-agenda-undo
            "u"   'org-agenda-diary-entry
            "U"   'org-agenda-clock-in)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

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

;; improve projectile integration
(use-package counsel-projectile
  :demand t
  :config (counsel-projectile-mode 1))

(use-package org
  :defer t
  :init
  (setq org-ellipsis " ▼")

  ;; make indentation work properly when editing org src
  (setq org-adapt-indentation nil
        org-edit-src-content-indentation 0
        org-src-tab-acts-natively t
        org-startup-indented t)
  ;; add agenda file
  (setq org-agenda-files '("~/org/"))

  :custom-face
  (org-block ((t (:foreground "#d3d0c8")))))

(use-package company
  :demand t
  :config (global-company-mode)
  :general
  ("C-<return>" 'company-complete))

(use-package flycheck
  :init
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :config
  (global-flycheck-mode))

(use-package projectile
  :demand t
  :after (hydra counsel)
  :init
  (defun my/counsel-projectile-find-org-file ()
    "call counsel-projectile-find-file-dwim but pretend the current dir is ~/org"
    (interactive)
    (let ((default-directory "~/org/"))
      (call-interactively 'counsel-projectile-find-file-dwim)))

  (defun my/projectile-popwin-eshell ()
    (interactive)
    (popwin:display-buffer-1
     (or (get-buffer "*eshell*")
         (save-window-excursion
           (call-interactively 'projectile-run-eshell)))))

  (defhydra hydra-projectile (:color blue :hint nil)
    "
^Projectile: %(projectile-project-name)
^Find File^            ^Navigate Files^       ^^Buffers^              ^Search/Tags^          ^^^Exec^
^^---------------------^^---------------------^^^---------------------^^---------------------^^^^----------------
_f_: find file         _p_: switch project    ^_b_: list buffers      _r_: ripgrep           ^^_x_: run
_a_: all known files   _e_: toggle extensions _\%_: query replace     _O_: multi occur       ^^_c_: compile
_d_: find dir          _T_: switch to test    ^_S_: save buffers      _g_: find tag          ^^_C_: configure
_o_: file in ~/org     _s_: eshell            ^_k_: kill buffers      _G_: regenerate tags   ^^_t_: test
_D_: edit dir-locals   ^^                     ^^^                     ^^                   _!_/_&_: shell command
"
    ("f" counsel-projectile-find-file-dwim)
    ("a" projectile-find-file-in-known-projects)
    ("d" counsel-projectile-find-dir)
    ("o" my/counsel-projectile-find-org-file)

    ("p" counsel-projectile-switch-project)
    ("e" projectile-find-other-file)
    ("T" projectile-toggle-between-implementation-and-test)
    ("s" my/projectile-popwin-eshell)

    ("b" counsel-projectile-switch-to-buffer)
    ("%" projectile-replace)
    ("S" projectile-save-project-buffers)
    ("k" projectile-kill-buffers)

    ("r" counsel-projectile-rg)
    ("O" projectile-multi-occur)
    ("g" projectile-find-tag)
    ("G" projectile-regenerate-tags)

    ("x" projectile-run-project) 
    ("c" projectile-compile-project)
    ("C" projectile-configure-project)
    ("t" projectile-test-project)

    ("D" projectile-edit-dir-locals)
    ("!" projectile-run-shell-command-in-root)
    ("&" projectile-run-async-shell-command-in-root))

  (leader-def "p" 'hydra-projectile/body)

  (setq projectile-project-search-path '("~/" "~/code")
        projectile-indexing-method 'hybrid ;; needed to make sorting work
        projectile-sort-order 'default) ;; disable sortng for now
  :general (:keymaps 'projectile-mode-map
                     "C-c p"  'projectile-command-map)
  :config (projectile-mode 1))

(use-package popwin
  :after (general hydra)
  :demand t
  :init
  (defun my/popwin-eshell ()
    (interactive)
    (popwin:display-buffer-1
     (or (get-buffer "*eshell*")
         (save-window-excursion
           (call-interactively 'eshell)))))


  (defhydra hydra-popwin (:color blue :hint nil :idle 0.1)
    "
  ^Buffers^             ^Window Placement^      ^Misc^
--^^--------------------^^----------------------^^-------------------
  _b_: show buffer      _c_: close popup        _m_: display messages
  _l_: show last buffer _1_: maximize popup     _f_: show file
_SPC_: switch to popup  _s_: make popup sticky  _s_: open eshell

"
    ("b"   popwin:popup-buffer)
    ("l"   popwin:popup-last-buffer)
    ("SPC" popwin:select-popup-window)

    ("c"   popwin:close-popup-window)
    ("1"   popwin:one-window)
    ("S"   popwin:stick-popup-window)

    ("m"   popwin:messages)
    ("f"   popwin:find-file)
    ("s"   my/popwin-eshell))

  (leader-def "t" 'hydra-popwin/body)
  :config
  (popwin-mode 1))

(use-package yasnippet
  :defer 1
  :general ("TAB" 'yas-expand)
  :config
  (yas-global-mode))
(use-package yasnippet-snippets
  :after yasnippet)

(use-package avy :commands avy-goto-subword-1)
(use-package hydra
  :custom-face 
  (hydra-face-red      ((t (:foreground "#f2777a"))))
  (hydra-face-blue     ((t (:foreground "#6699cc"))))
  (hydra-face-amaranth ((t (:foreground "#f99157"))))
  (hydra-face-teal     ((t (:foreground "#66cccc"))))
  (hydra-face-pink     ((t (:foreground "#cc99cc")))))
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
(use-package which-key
  :demand t
  :config (which-key-mode 1))

(use-package highlight-numbers
  :init
  ;; enable in programming modes
  (add-hook 'prog-mode-hook 'highlight-numbers-mode)
  (add-hook 'conf-mode-hook 'highlight-numbers-mode))

(use-package smartparens
  :demand t
  :init
  ;; bind <leader>-s to smartparens hydra
  (leader-def "s" 'hydra-smartparens/body)
  
  :config
  (smartparens-global-strict-mode 1)
  ;; highlight matching delimiter
  (show-smartparens-global-mode 1)

  ;; enable default smartparens config
  (require 'smartparens-config)
  
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
