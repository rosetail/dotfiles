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
;; (recentf-mode 1)

;; stop putting backup files everywhere
(setq version-control t       ;; Use version numbers for backups.
      kept-new-versions 10    ;; Number of newest versions to keep.
      kept-old-versions 0     ;; Number of oldest versions to keep.
      delete-old-versions t   ;; Don't ask to delete excess backup versions.
      backup-by-copying t     ;; Copy all files, don't rename them.
      vc-make-backup-files t  ;; also backup files under version control
      backup-directory-alist '(("" . "~/.emacs.d/backup/per-save"))) 

;; set up indentation
(setq-default c-basic-offset 4
              cperl-indent-level 4)
(setq tab-width 4
      c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "k&r")))


;; don't ask to save files when compiling
(setq compilation-ask-about-save nil
      compilation-save-buffers-predicate '(lambda () nil))

;; Make the compilation window automatically disappear - from enberg on #emacs
(setq compilation-finish-functions
      (lambda (buf str)
        (if (null (string-match ".*exited abnormally.*" str))
            ;; no errors, make the compilation window go away in a few seconds
            (progn
	      (run-at-time
	       "1 sec" nil 'delete-windows-on
	       (get-buffer-create "*compilation*"))
	      (message "No Compilation Errors!")))))

;; make yes or no prompts faster
(defalias 'yes-or-no-p 'y-or-n-p)

;; set default font
(set-frame-font "Input Mono Narrow Light-10" nil t)

;; load theme
(use-package base16-theme
  :init (load-theme 'base16-eighties t)
  :custom
  ;; skip startup screen and go to scratch buffer
  ;; TODO: see about using general-custom
  (inhibit-startup-screen t))

;; setup modeline
(use-package doom-modeline
  :init
  ;; show word count of region
  (setq doom-modeline-enable-word-count t)
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

;; emacs renders Mononoki 2 pixels to short
;; (setq-default line-spacing 0)

(use-package general
  :config
  ;; create leader key
  ;; bound to M-SPC in insert mode and SPC in all other modes
  (general-create-definer leader-def
    :states '(normal insert emacs motion visual operater)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "C-SPC"
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
  ;; make text ojects work properly in colemak
  (:keymaps 'override
            :states '(visual operator)
            "u"      evil-inner-text-objects-map
            "i"      'evil-forward-char)
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
  ;; evil-org doesn't bind textobjects properly so we have manually redefine them
  (:keymaps 'evil-inner-text-objects-map
            "e" 'evil-org-inner-object
            "E" 'evil-org-inner-element
            "r" 'evil-org-inner-greater-element
            "R" 'evil-org-inner-subtree)
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
            "U"   'org-agenda-clock-in))
(use-package evil-org-agenda
  :demand t
  :ensure nil ; don't ensure because it is built in to evil-org
  :after evil-org
  :config
  (evil-org-agenda-set-keys))

;; make sure we have flx so ivy does better fuzzy matching
(use-package flx :defer t)
;; not having ivy-hydra breaks some things
(use-package ivy-hydra :defer t)

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
  :after (counsel projectile)
  :config (counsel-projectile-mode 1))

(use-package org-agenda
  :ensure nil
  :defer t
  :init
  (setq org-directory    "~/org"
        org-agenda-files (list "~/org/inbox.org"
                               "~/org/agenda.org")
        org-agenda-hide-tags-regexp "inbox"
        org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo   . " ")
          (tags   . " %i %-12:c")
          (search . " %i %-12:c"))
        org-capture-templates
        `(("i" "Inbox" entry  (file "inbox.org")
           ,(concat "* TODO %?\n"
                    "/Entered on/ %U"))))
  (defhydra hydra-org (:color blue :hint nil)
    "
_a_: Agenda, _c_: Capture"
    ("a" org-agenda)
    ("c" org-capture))

  (leader-def "o" 'hydra-org/body))

(use-package org
  :defer t
  :init
  (setq org-ellipsis " ▼"
        ;; make all images 600px wide
        org-image-actual-width 600
        ;; use smart quotes when exporting
        org-export-with-smart-quotes t)

  ;; make indentation work properly when editing org src
  (setq org-adapt-indentation nil
        org-edit-src-content-indentation 0
        org-src-tab-acts-natively t
        org-startup-indented t
        org-hide-emphasis-markers t
        org-catch-invisible-edits 'smart
        org-ctrl-k-protect-subtree t)

  ;; align tags to the right regardless of window size
  (defun org-keep-tags-to-right ()
    (interactive)
    (let ((buffer-modified (buffer-modified-p))
	  (inhibit-message t)) ;; don't say the new column with every time
      (when (and (equal major-mode 'org-mode)
		 (org-get-buffer-tags))
	(setq org-tags-column (- 2 (window-body-width)))
	(org-align-tags t)
	(when (not buffer-modified)
	  (set-buffer-modified-p nil)))))
  
  (add-hook 'window-configuration-change-hook 'org-keep-tags-to-right)
  (add-hook 'focus-in-hook 'org-keep-tags-to-right)
  (add-hook 'focus-out-hook 'org-keep-tags-to-right)

  :config
  (use-package ox ; needed for org-export-filter-headline-function
    :ensure nil
    :demand t
    :config
    ;; add ignore tag that will make org-export ignore the headline but keep the body
    (defun org-ignore-headline (contents backend info)
      "Ignore headlines with tag `ignore'."
      (when (and (org-export-derived-backend-p backend 'latex 'html 'ascii)
	         (string-match "\\`.*ignore.*\n"
                               (downcase contents)))
        (replace-match "" nil nil contents)))

    (add-to-list 'org-export-filter-headline-functions 'org-ignore-headline))
  :custom-face
  (org-block ((t (:foreground "#d3d0c8")))))

(use-package company
  :defer 0.75
  :config (global-company-mode)
  :general
  ("C-<return>" 'company-complete))

(use-package flycheck
  :defer 1
  :init
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :config
  (global-flycheck-mode))

(use-package projectile
  :defer 0.5
  :after (hydra)
  :init
  (setq projectile-project-search-path '("~/" "~/code")
        projectile-indexing-method 'hybrid ;; needed to make sorting work
        projectile-sort-order 'default)
  
  (defun my/counsel-projectile-find-org-file ()
    "call counsel-projectile-find-file-dwim but pretend the current dir is ~/org"
    (interactive)
    (let ((default-directory "~/org/"))
      (call-interactively 'counsel-projectile-find-file-dwim)))

  (defun my/projectile-popwin-eshell ()
    (interactive)
    (popwin:display-buffer-1
     (save-window-excursion
       (call-interactively 'projectile-run-eshell))))

  (defhydra hydra-projectile (:color blue :hint nil)
    "
^Projectile
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
  :config
  (projectile-mode 1)

  :general (:keymaps 'projectile-mode-map
                     "C-c p"  'projectile-command-map))

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
  _l_: show last buffer _f_: maximize popup     _o_: open file
_SPC_: switch to popup  _s_: make popup sticky  _s_: open eshell

"
    ("b"   popwin:popup-buffer)
    ("l"   popwin:popup-last-buffer)
    ("SPC" popwin:select-popup-window)

    ("c"   popwin:close-popup-window)
    ("f"   popwin:one-window)
    ("S"   popwin:stick-popup-window)

    ("m"   popwin:messages)
    ("o"   popwin:find-file)
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

(use-package lsp-mode
  :defer t
  :custom
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-indentation nil)
  :hook
  ((before-save . lsp-format-buffer))
  (c++-mode . lsp))

(use-package auctex
  :after tex
  :no-require t
  :init
  ;; compile with latexmk
  (setq-default TeX-command-default "Latexmk")

  ;; parse on save
  (setq TeX-auto-save t
        ;; parse on load
        TeX-parse-self t
        TeX-master nil)
  :hook (LaTeX-mode . (lambda () (setq TeX-command-default "Latexmk")))
  :config
  (push 
   '("Latexmk" "latexmk -pvc -interaction=nonstopmode %t" TeX-run-TeX nil t
     :help "Make pdf output using latexmk.")
   TeX-command-list))

(use-package avy :commands avy-goto-subword-1)
(use-package hydra
  :custom-face 
  (hydra-face-red      ((t (:foreground "#f2777a"))))
  (hydra-face-blue     ((t (:foreground "#6699cc"))))
  (hydra-face-amaranth ((t (:foreground "#f99157"))))
  (hydra-face-teal     ((t (:foreground "#66cccc"))))
  (hydra-face-pink     ((t (:foreground "#cc99cc")))))

(use-package comment-dwim-2
  :general ("M-;" 'comment-dwim-2))

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
  ;; enable in programming modes
  :hook ((prog-mode . highlight-numbers-mode)
         (conf-mode . highlight-numbers-mode)))

(use-package smart-compile
  :defer t
  :init
  (leader-def "m" 'smart-compile))

;; (use-package quickrun
;;   :after hydra
;;   :defer t
;;   :init
;;   (defhydra hydra-quickrun (:color blue :hint nil)
;;     "
;; _c_: Compile, _r_: Run, _s_: Run in shell, _a_: Run with arg, _R_: Run region"
;;     ("c" quickrun-compile-only)
;;     ("r" quickrun)
;;     ("s" quickrun-shell)
;;     ("a" quickrun-with-arg)
;;     ("R" quickrun-region))
;;   (leader-def "r" 'hydra-quickrun/body))

;; reset file-name-handler-alist
(setq file-name-handler-alist my/file-name-handler-alist)

(use-package smartparens
  :demand t
  :init
  ;; bind <leader>-s to smartparens hydra
  (leader-def "s" 'hydra-smartparens/body)
  
  :config
  (smartparens-global-strict-mode 1)
  ;; highlight matching delimiter
  (show-smartparens-global-mode 1)

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

;; enable default smartparens config
(use-package smartparens-config
  ;; don't ensure because this is built in to smartparent
  :ensure nil
  :demand t
  :after smartparens)



(use-package evil-smartparens
  :demand t
  :after smartparens-config
  :hook (smartparens-enabled . evil-smartparens-mode))
