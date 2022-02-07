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
;; (require 'package)
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; (package-initialize)
;; (setq package-archive-priorities
;;       '(("melpa" . 2)
;;         ("melpa-stable" . 1)
;;         ("gnu" . 0)))

;; (unless (package-installed-p 'use-package)
;;   (package-refresh-contents)
;;   (package-install 'use-package))
;; set up use-package
;; (require 'use-package)
;; (setq use-package-compute-statistics t
;;       use-package-always-ensure t)

;; set up straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; set up use package
(straight-use-package 'use-package)
(setq use-package-compute-statistics t
      straight-use-package-by-default t)

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

;; https://stackoverflow.com/questions/14668744/emacs-indent-for-c-class-method
(add-hook 'c++-mode-hook
          (lambda ()
            (c-set-offset 'access-label -2)
            (c-set-offset 'inline-open 0)))


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

;; don't show nativecomp warnings
(setq warning-suppress-log-types '((comp)))

;; make middle click paste not move the cursor
(setq mouse-yank-at-point t)

;; use electric pair mode
(electric-pair-mode)
;; disable <> pair
(setq electric-pair-inhibit-predicate
      `(lambda (c)
         (if (char-equal c ?\<) t (,electric-pair-inhibit-predicate c))))

;; install hydra first so it's available to other packages
(use-package hydra
  :custom-face 
  ;; (hydra-face-red      ((t (:foreground "#f2777a"))))
  ;; (hydra-face-blue     ((t (:foreground "#6699cc"))))
  ;; (hydra-face-amaranth ((t (:foreground "#f99157"))))
  ;; (hydra-face-teal     ((t (:foreground "#66cccc"))))
  ;; (hydra-face-pink     ((t (:foreground "#cc99cc"))))
  )

(defvar my/global-hydra-heads-list '()
  "List of hydra heads to be used by global-hydra. Use
my/add-to-global-hydra to add entries")

(defun my/add-to-global-hydra (head)
  "add HEAD to my/global-hydra-heads-list"
  ;; don't ever add SPC or ESC to GLOBAL-HYDRA
  (catch 'invalid-head
    (when (or (string= (car head) "ESC") (string= (car head) "SPC"))
      (throw 'invalid-head "Can't add ESC or SPC to GLOBAL-HYDRA"))
    ;; if there is already a head with the same keybinding, remove it
    (let ((current-head nil))
      (dolist (current-head my/global-hydra-heads-list)
        (when (string= (car head) (car current-head))
          (setq my/global-hydra-heads-list ; for some reason this doesn't work unless we use setq
                (delete current-head my/global-hydra-heads-list)))))
    ;; add the new head to the hydra
    (add-to-list 'my/global-hydra-heads-list head)))

(defun my/global-hydra ()
  "Global hydra that functions like a leader key. Add heads with `my/add-to-global-hydra`"
  (interactive)
  (call-interactively
   (eval `(defhydra my-hydra (:hint nil :color blue)
            ,@my/global-hydra-heads-list))))

;; start by adding TAB
(my/add-to-global-hydra '("TAB"
                          (lambda ()
                            (interactive)
                            (save-excursion
                              (mark-whole-buffer)
                              (indent-for-tab-command)))
                          "Indent Buffer" :column "Editing"))

;; from https://gist.github.com/tttuuu888/267a8a56c207d725ea999e353646eec9
(defvar sk-pacakge-loading-notice-list '(yasnippet))
;; (defvar sk-pacakge-loading-notice-list '(org yasnippet))

(defun sk-package-loading-notice (old &rest r)
  (let* ((elt (car r))
         (mode
          (when (stringp elt)
            (let ((ret (assoc-default elt auto-mode-alist 'string-match)))
              (and (symbolp ret) (symbol-name ret)))))
         (pkg
          (cond ((symbolp elt) elt)
                ((stringp mode) (intern (string-remove-suffix "-mode" mode)))
                (t nil))))
    (if (not (member pkg sk-pacakge-loading-notice-list))
        (apply old r)
      (let ((msg (capitalize (format " %s loading ..." pkg)))
            (ovr (make-overlay (point) (point))))
        (when (fboundp 'company-cancel) (company-cancel))
        (setq sk-pacakge-loading-notice-list
              (delq pkg sk-pacakge-loading-notice-list))
        (unless sk-pacakge-loading-notice-list
          (advice-remove 'require #'sk-package-loading-notice)
          (advice-remove 'find-file #'sk-package-loading-notice))
        (message msg)
        (overlay-put ovr 'after-string
                     (propertize msg 'face '(:inverse-video t :weight bold)))
        (redisplay)
        (let ((ret (apply old r)))
          (delete-overlay ovr)
          ret)))))

(advice-add 'require :around #'sk-package-loading-notice)
(advice-add 'find-file-noselect :around #'sk-package-loading-notice)

(use-package general
  :config
  ;; create leader key
  ;; bound to M-SPC in insert mode and SPC in all other modes
  ;; this has now been replaced with my/global-hydra
  ;; (general-create-definer leader-def
  ;;   :states '(normal insert emacs motion visual operater)
  ;;   :keymaps 'override
  ;;   :prefix "SPC"
  ;;   :non-normal-prefix "C-SPC"
  ;;   :prefix-map 'leader-prefix-map)

  ;; ;; global leader keys
  ;; (leader-def
  ;;   ;; indent whole buffer
  ;;   "TAB" (lambda ()
  ;;           (interactive)
  ;;           (save-excursion
  ;;             (mark-whole-buffer)
  ;;             (indent-for-tab-command))))
  ;; we have to demand general to global leader keys get bound during init
  (general-define-key
   :states '(normal motion visual operater)
   :keymaps 'override
   "SPC" 'my/global-hydra)
  ;; (general-define-key
  ;;  :states '(normal insert emacs motion visual operater)
  ;;  :keymaps 'override
  ;;  "C-SPC" 'my/global-hydra)
  :demand t)

;; don't confirm when running load-theme interactively
(advice-add 'load-theme
            :around (lambda
                      (fn theme &optional no-confirm no-enable)
                      (funcall fn theme t)))

;; setup modeline
(use-package doom-modeline
  :init
  ;; show word count of region
  (setq doom-modeline-enable-word-count t)
  (doom-modeline-mode))

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

(use-package modus-themes
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-slanted-constructs t
        modus-themes-region '(bg-only)
        modus-themes-completions 'opinionated
        modus-themes-fringes 'intense
        modus-themes-org-blocks 'grayscale
        modus-themes-headings '((t . (rainbow)))
        modus-themes-bold-constructs nil
        modus-themes-markup '(background intense))
  
  ;; don't make modeline be variable pitched
  (set-face-attribute 'mode-line-active nil :inherit 'mode-line)

  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;; Load the theme of your choice:
  (modus-themes-load-vivendi) ;; OR (modus-themes-load-vivendi)
  :custom
  ;; skip startup screen and go to scratch buffer
  ;; TODO: see about using general-custom
  ;; TODO: add this to a (use-package emacs...) declaration
  (inhibit-startup-screen t)
  :general ("<f5>" 'modus-themes-toggle))

(use-package evil
  :demand t
  :init
  (setq-default cursor-in-non-selected-windows nil)
  (setq evil-want-keybinding nil
        ;; make ctrlf integration work
        evil-search-module 'evil-search)
  :general
  ;; alias C-e and M-e to C-p and M-p so scrolling with vim navigation keys works
  ;; this leaves us unable to access anything bound to C-e or M-e, but I don't really use thse keys
  ("C-e" (general-key "C-p")
   "M-e" (general-key "M-p")
   ;; use M-/ to unhighlight search
   "M-/" 'evil-ex-nohighlight)
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
  :custom
  (evil-ex-search-persistent-highlight nil)
  (evil-ex-search-highlight-all t)
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
  ;; (defun my-hjkl-rotation (_mode mode-keymaps &rest _rest)
  ;;   (evil-collection-translate-key 'normal mode-keymaps
  ;;     "n" "j"
  ;;     "e" "k"
  ;;     "i" "l"
  ;;     "j" "e"
  ;;     "k" "n"
  ;;     "l" "i"))

  (defun my-hjkl-rotation (_mode mode-keymaps &rest _rest)
    (evil-collection-translate-key 'normal mode-keymaps
      (kbd "C-n") (kbd "C-j")
      (kbd "C-e") (kbd "C-k")))

  ;; called after evil-collection makes its keybindings
  ;; TODO: switch this to :hook
  (add-hook 'evil-collection-setup-hook #'my-hjkl-rotation)

  (evil-collection-init)
  :custom (evil-collection-company-use-tng nil) ; make company behave like emacs, not vim
  :config
  (evil-collection-init))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

;; TODO: actually learn these keybindings
(use-package evil-org
  :after (:any (:all evil org) (:all evil org-agenda))
  :commands org-agenda
  :init
  ;; make keybindings work in insert mode
  (setq evil-org-use-additional-insert t
        ;; use colemak movement
        evil-org-movement-bindings '((up . "e") (down . "n") (left . "h") (right . "i"))

        ;; add keybindings for more things
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
  :straight nil ; don't ensure because it is built in to evil-org
  :after (:or evil-org org-agenda)
  :config
  (evil-org-agenda-set-keys))

(use-package ctrlf
  :demand t
  :general
  (:states
   '(motion normal visual operator)
   "/" 'ctrlf-forward-regexp
   "?" 'ctrlf-backward-regexp)
  :config
  (ctrlf-mode))

(use-package vertico
  :demand t
  ;; TODO: move this to somewhere better
  :general ("C-x C-a" 'find-file)
  :config
  (savehist-mode)
  (vertico-mode))

(use-package orderless
  :demand t
  :init
  (setq orderless-matching-styles '(orderless-initialism orderless-prefixes orderless-regexp)
        orderless-component-separator " +\\|/")

  :custom (completion-styles '(orderless)))

(use-package marginalia
  :demand t
  :init
  ;; TODO: figure out what happened to this variable
  ;; (setq marginalia-annotators
  ;;       '(marginalia-annotators-heavy
  ;;         marginalia-annotators-light))
  :config
  (marginalia-mode)
  ;; this fixes the annotations for describe variable/functions
  (add-to-list 'marginalia-annotator-registry
	       '(symbol-help marginalia-annotate-variable)))

(use-package embark
  :demand t
  :after which-key
  :init
  (setq embark-indicators #'embark-minimal-indicator)
  ;; disable which-key in favor of using C-h
  ;; (setq embark-action-indicator
  ;;       (lambda (map)
  ;;         (which-key--show-keymap "Embark" map nil nil 'no-paging)
  ;;         #'which-key--hide-popup-ignore-command)
  ;;       embark-become-indicator embark-action-indicator)
  :general
  (:keymaps 'override
   :states '(normal insert emacs motion visual operater)
            "C-." 'embark-act)
  (:keymaps 'vertico-map
            "C-." 'embark-act))

(use-package consult
  :defer t
  :general
  
  ("M-'" 'consult-line)
  ("C-x b" 'consult-buffer)
  (:keymaps 'consult-narrow-map
            "<" 'consult-narrow-help))

(use-package embark-consult
  :demand t
  :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))

(use-package corfu
  :init
  (setq tab-always-indent 'complete
        corfu-quit-no-match t
        corfu-preview-current nil
        corfu-quit-at-boundary t
        corfu-auto t)
  
  (corfu-global-mode)
  
  (defun corfu-move-to-minibuffer ()
    "Transfer the current completion session to the minibuffer"
    (interactive)
    (let ((completion-extra-properties corfu--extra)
          completion-cycle-threshold completion-cycling)
      (apply #'consult-completion-in-region completion-in-region--data)))

  ;; stop C-n and C-e from being overridden
  (general-unbind '(insert normal motion visual operator) "C-n" "C-e" "C-d")
  :general
  (:keymaps 'corfu-map
            "C-i" 'corfu-move-to-minibuffer
            "C-n" 'corfu-next
            "C-e" 'corfu-previous)
  :hook (eshell-mode . (lambda ()
                         (setq-local corfu-quit-at-boundary t
                                     corfu-auto nil)
                         (corfu-mode))))

;; add more capf functions
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-ispell))

;; show corfu icons
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; show documentation
(use-package corfu-doc
  :straight (corfu-doc :type git :host github :repo "galeo/corfu-doc")
  :general (:keymaps 'corfu-map
                     "C-d" 'corfu-doc-toggle
                     ;; scroll-down and scroll-up are reversed for some reason here
                     "M-e" 'corfu-doc-scroll-down
                     "M-n" 'corfu-doc-scroll-up))

;; better eshell completion
(use-package pcmpl-args
  :init
  ;; corfu doc told me to add this part
  
  ;; Silence the pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)

  :after eshell)

(use-package dtache
  :after hydra
  :init
  (setq dtache-detach-key (kbd "C-\\"))
  :config
  ;; create a hydra for all the common actions
  (defhydra hydra-dtache (:color blue :hint nil)
    "
_SPC_: new, _a_: attach, _=_: diff, _r_: rerun, _w_: copy command, _W_: copy output, _k_: kill, _d_: delete"
    ("SPC" dtache-shell-command)
    ("a" dtache-attach-session)
    ("=" dtache-diff-session)
    ("r" dtache-rerun-session)
    ("w" dtache-copy-session-command)
    ("W" dtache-copy-session)
    ("k" dtache-kill-session)
    ("d" dtache-delete-session)
    ("o" dtache-consult-session))
  
  (my/add-to-global-hydra '("d" hydra-dtache/body "Dtache" :column "Misc"))
  
  ;; add embark actions to dtache-open-session
  (defvar embark-dtache-map (make-composed-keymap dtache-action-map embark-general-map))
  (add-to-list 'embark-keymap-alist '(dtache . embark-dtache-map))
  
  :hook (after-init . dtache-setup)
  :bind (([remap async-shell-command] . dtache-shell-command)))

(use-package dtache-consult
  :straight nil
  :after dtache ; included with dtache
  :bind ([remap dtache-open-session] . dtache-consult-session))

;; detatch commands run in eshell
(use-package dtache-eshell
  :straight nil ; included with dtache
  :hook (eshell-mode . dtache-eshell-mode))

;; enable detatching compile commands
(use-package dtache-compile
  :straight nil
  :hook (after-init . dtache-compile-setup)
  :bind (([remap compile] . dtache-compile)
         ([remap recompile] . dtache-compile-recompile)))

;; TODO: refactor this whole section
(use-package org
  :demand t
  :init
  (setq ;; let emphasis markers be nested
   org-emphasis-regexp-components '("-[:space:]('\"{*/=~_" "-[:space:].,*/=~_:!?;'\")}\\[" "[:space:]" "." 1)
   ;; start in org-mode with a source block for lisp evaluation
   initial-major-mode #'org-mode
   initial-scratch-message "#+begin_src emacs-lisp\n;; This block is for text that is not saved, and for Lisp evaluation.\n;; To create a file, visit it with \\[find-file] and enter text in its buffer.\n\n#+end_src\n\n")


  
  (add-hook 'org-mode-hook #'flyspell-mode)
  ;; override C-RET
  ;; (add-hook 'org-mode-hook
  ;;           (lambda ()
  ;;             (general-define-key
  ;;              :keymaps 'local
  ;;              :states '(motion normal visual operator insert)
  ;;              "C-return" 'company-complete)))

  ;; (add-hook 'org-mode-hook #'flyspell-buffer)
  (setq org-ellipsis " ▼"
        ;; make all images 600px wide
        org-image-actual-width 600
        ;; use smart quotes when exporting
        org-export-with-smart-quotes t
        ;; make checkbox counters recursive
        org-checkbox-hierarchical-statistics nil)

  ;; make indentation work properly when editing org src
  (setq org-adapt-indentation nil
        org-tags-column 0
        org-edit-src-content-indentation 0
        org-src-tab-acts-natively t
        org-src-window-setup 'current-window
        org-startup-indented t
        org-startup-folded t
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
	(setq org-tags-column (- 3 (window-body-width)))
	(org-align-tags t)
	(when (not buffer-modified)
	  (set-buffer-modified-p nil)))))
  
  
  ;; TODO: switch to :hook
  ;; (add-hook 'window-configuration-change-hook 'org-keep-tags-to-right)
  ;; (add-hook 'focus-in-hook 'org-keep-tags-to-right)
  ;; (add-hook 'focus-out-hook 'org-keep-tags-to-right)

  :general (:keymaps 'org-mode-map :states '(normal insert) "M-n" nil)
  :config
  ;; TODO: switch this to custom-face
  ;; (set-face-attribute 'org-block-begin-line nil :background 'unspecified)
  ;; (set-face-attribute 'org-block-end-line nil :background 'unspecified)
  (set-face-attribute 'org-block nil :extend t)
  ;; :general
  ;; (:keymaps 'org-mode-map
  ;;           :states 'insert
  ;;           "C-<return>" 'company-complete)
  :custom-face
  ;; make default face in org src block look right
  ;; (org-block ((t (:foreground "#cbced0" :background "#232530" :extend t))))
  ;; (org-block ((t (:foreground "#cbced0"))))
  ;; highlight beginning and end of block
  ;; (org-block-begin-line ((t (:background "#2e303e" :extend t))))
  ;; (org-block-end-line ((t (:background "#2e303e" :extend t))))
  ;; switch outline-4 and outline-4 so I don't see comment face as much
  ;; (outline-4 ((t (:foreground "#efaf8e"))))
  ;; (outline-8 ((t (:foreground "#6f6f70"))))
  )

(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode))

(use-package ox ; needed for org-export-filter-headline-function
  :straight nil
  :defer t
  :config
  ;; use the soul and csquotes packages
  ;; TODO: see if this can be done with 1 call to add-to-list
  (add-to-list 'org-latex-packages-alist '("" "soul"))
  (add-to-list 'org-latex-packages-alist '("" "csquotes"))
  ;; define a general purpose assignment class and make it the default
  (add-to-list 'org-latex-classes
               '("assignment"
                 "\\documentclass[11pt]{article}
\\usepackage[margin=1in]{geometry}
\\usepackage[doublespacing]{setspace}
\\setlength{\\parskip}{1em}
[DEFAULT-PACKAGES]
[PACKAGES]
\\usepackage{titlesec}
\\titleformat*{\\section}{\\Large\\bfseries}
\\titleformat*{\\subsection}{\\large\\bfseries}
\\titleformat*{\\subsubsection}{\\bfseries}
\\titleformat*{\\paragraph}{\\bfseries}
\\titleformat*{\\subparagraph}{\\bfseries}
\\titlespacing\\section{0pt}{-10pt}{-10pt}
\\titlespacing\\subsection{0pt}{-10pt}{-10pt}
\\titlespacing\\subsubsection{0pt}{-10pt}{-10pt}
\\setlength{\\parindent}{4em}

\\setcounter{secnumdepth}{0}
[EXTRA]

\\makeatletter
\\renewcommand\\maketitle{
\\begin{flushright}
  \\@author\\\\
  \\@date
\\end{flushright}
\\begin{center}
  \\Large{\\@title}
\\end{center}
}
\\makeatother
"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%}")))
  (setq org-latex-default-class "assignment")

  ;; don't ever switch to enumerate for headlines
  (setq org-export-headline-levels -1
        ;; org-latex-pdf-process '("latexmk -pvc -cd -interaction=nonstopmode %f")
        TeX-auto-local ".build"
        org-export-with-toc nil
        org-export-with-tags nil)
  ;; dont add \label when exporting
  ;; from https://stackoverflow.com/questions/18076328/org-mode-export-to-latex-suppress-generation-of-labels
  (defun rm-org-latex-labels (text backend _info)
    "Remove labels auto-generated by `org-mode' export to LaTeX."
    (when (eq backend 'latex)
      (replace-regexp-in-string "\\\\label{sec:org[a-f0-9]+}\n" "" text)))

  (add-to-list #'org-export-filter-headline-functions
               #'rm-org-latex-labels)
  ;; add ignore tag that will make org-export ignore the headline but keep the body
  ;; (defun org-ignore-headline (contents backend info)
  ;;   "Ignore headlines with tag `ignore'."
  ;;   (when (and (org-export-derived-backend-p backend 'latex 'html 'ascii)
  ;;              (string-match "\\`.*ignore.*\n"
  ;;                            (downcase contents)))
  ;;     (replace-match "" nil nil contents)))

  ;; (add-to-list 'org-export-filter-headline-functions 'org-ignore-headline)


  ;; ignore tags without the noignore headline in latex export
  (defun org-noignore-headline (contents backend info)
    "Ignore headlines without tag `noignore'."
    (unless (string-match "\\`.*noignore.*\n" (downcase contents))
      (when (and (org-export-derived-backend-p backend 'latex)
                 (string-match "\\`.*\n"
                               (downcase contents)))
        (replace-match "" nil nil contents))))

  (add-to-list 'org-export-filter-headline-functions 'org-noignore-headline)
  
  
(defun my/toggle-org-latex-export-on-save ()
  "Toggle auto export to latex when saving an org buffer"
  (interactive)
  (if (memq 'org-latex-export-to-latex after-save-hook)
      (progn
        (org-latex-export-to-latex t)
        (remove-hook 'after-save-hook 'org-latex-export-to-latex t)
        (message "Disabled org latex export on save for current buffer..."))
    (add-hook 'after-save-hook 'org-latex-export-to-latex nil t)
    (message "Enabled org latex export on save for current buffer..."))))

(use-package htmlize
  :init
  ;; use readthedocs stylesheet for html export
  ;; from fniessen.github.org/org-html-themes
  (setq org-html-head
        (concat "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg_theme/css/htmlize.css\"/>\n"
                "<link rel=\"stylesheet\" type=\"text/css\" href=\"https://fniessen.github.io/org-html-themes/src/readtheorg_theme/css/readtheorg.css\"/>\n"
                "<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\"></script>\n"
                "<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js\"></script>\n"
                "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/lib/js/jquery.stickytableheaders.min.js\"></script>\n"
                "<script type=\"text/javascript\" src=\"https://fniessen.github.io/org-html-themes/src/readtheorg_theme/js/readtheorg.js\"></script>\n"
                "<style>pre.src{background:#ffffff;color:#000000;} </style>\n"
                "<style>#postamble .date{color:#6f6f70;} </style>"))
  :defer t)

(use-package org-agenda
  :straight nil
  :defer t
  :init
  (setq org-directory "~/org"
        ;; inbox.org must be first here or refiletargets will break
        org-agenda-files (list "~/org/inbox.org"
                               "~/org/agenda.org")
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "|" "DONE(d)" "CANCELLED(c)"))
        ;; org-agenda-window-setup 'current-frame ; make agenda buffer only use the current frame
        org-use-fast-todo-selection 'expert

        
        
        org-agenda-prefix-format
        '((agenda . "  %i %-12:c%?-12t% s")
          (todo   . "  ")
          (tags   . "  %(my/org-print-parent-heading)")
          (search . "  %i %-12:c"))
        
        ;; org-agenda-hide-tags-regexp "inbox\\|school\\|computer\\|emacs"
        org-agenda-hide-tags-regexp ".*"
        org-refile-targets `((,(cdr org-agenda-files) :maxlevel . 9))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil

        org-log-done 'time ; record when tasks are completed so we can see what was done today

        org-capture-templates
        `(("i" "Inbox" entry  (file "inbox.org")
           "* TODO %?\n/Entered on/ %U")))
  
  ;; helper functions for org-agenda-custom-commands
  
  ;; from https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
  ;; modified to also skip entries that are scheaduled or have a deadline
  ;; TODO: make this actually give the highest priority
  ;; possibly can be done by first going through all siblings and finding the highest priority
  ;; then skip all entries with lower priorities
  (defun my/org-agenda-skip-all-siblings-but-first ()
    "Skip all but the first TODO entry that is unscheduled and has no deadline."
    (let (should-skip-entry)
      (unless (my/org-current-is-todo-and-not-scheduled-or-deadline)
        (setq should-skip-entry t))
      (save-excursion
        (while (and (not should-skip-entry) (org-goto-sibling t))
          (when (my/org-current-is-todo-and-not-scheduled-or-deadline)
            (setq should-skip-entry t))))
      (when should-skip-entry
        (or (outline-next-heading)
            (goto-char (point-max))))))

  (defun my/org-current-is-todo-and-not-scheduled-or-deadline ()
    "Return t if todo state of the element at point is \"TODO\", it is not scheduled,
and it has no deadline"
    (and (string= "TODO" (org-get-todo-state))
         (not (org-element-property :deadline (org-element-at-point)))
         (not (org-element-property :scheduled (org-element-at-point)))))

  (defun my/org-print-parent-heading ()
    "Print the name of the parent of the org element at point
The name is formatted to end in a colon and take up 24 characters
If the element has no header, return an empty string
If the parent heading has the tag \"printParentHeadingRecurse\", go up a level"
    (save-excursion
      (if (org-up-heading-safe)
          
          (if (member "printParentHeadingRecurse" (org-get-local-tags))
              (my/org-print-parent-heading)
            (format "%-24s" (concat (org-element-property :title (org-element-at-point)) ":")))
        "")))
  
  (setq org-agenda-custom-commands
        '((" " "Agenda"
           ;; weekly agenda
           ((agenda "" ((org-agenda-span 7)
                        ;; don't wark about deadlines because they will be displayed below
                        (org-deadline-warning-days 0)))

            ;; tasks to refile
            (tags "inbox"
                  ((org-agenda-overriding-header "\nInbox")))

            ;; next tasks
            (todo "NEXT"
                  ((org-agenda-overriding-header "\nNext Tasks")))

            ;; all tasks with a deadline
            (todo 'todo
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notdeadline))
                   (org-agenda-sorting-strategy '(deadline-up))
                   (org-agenda-overriding-header "\nDeadlines")))

            ;; the first TODO item that isn't NEXT and has no deadline or schedule from each heading
            ;; this shows things that would otherwise get list
            (tags "-inbox"
                  ((org-agenda-skip-function #'my/org-agenda-skip-all-siblings-but-first)
                   (org-agenda-sorting-strategy '(priority-down))
                   (org-agenda-overriding-header "\nUndated Tasks")))

            ;; tasks that were completed today
            ;; from https://www.labri.fr/perso/nrougier/GTD/index.html
            (tags "CLOSED>=\"<today>\""
                  ((org-agenda-overriding-header "\nCompleted Today"))))

           ((org-agenda-compact-blocks t)))))

  (defhydra hydra-org (:color blue :hint nil)
    "
_a_: Agenda, _c_: Capture"
    ("a" org-agenda)
    ("c" org-capture))

  (my/add-to-global-hydra '("o" hydra-org/body "Org" :column "Misc")))

(use-package flycheck
  :defer 1
  :init
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :config
  (global-flycheck-mode))

(use-package vimish-fold)

(use-package evil-vimish-fold
  :after vimish-fold
  :init
  ;; enable in all modes, not just prog-mode
  (setq evil-vimish-fold-target-modes '(prog-mode conf-mode text-mode))
  (global-evil-vimish-fold-mode)
  :general
  (:states
   '(motion normal visual)
   "z SPC" 'evil-toggle-fold
   "za" 'vimish-fold-avy
   "zn" ' evil-vimish-fold/next-fold
   "ze" ' evil-vimish-fold/previous-fold))

(use-package projectile
  :defer 0.5
  :after (hydra)
  :init
  (setq projectile-project-search-path '("~/")
        ;; projectile-project-search-path '("~/" "~/code")
        projectile-indexing-method 'hybrid ;; needed to make sorting work
        projectile-sort-order 'default)
  
  (defun my/projectile-find-org-file ()
    "call projectile-find-file-dwim but pretend the current dir is ~/org"
    (interactive)
    (let ((default-directory "~/org/"))
      (call-interactively 'projectile-find-file-dwim)))

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
    ("f" projectile-find-file-dwim)
    ("a" projectile-find-file-in-known-projects)
    ("d" projectile-find-dir)
    ("o" my/projectile-find-org-file)

    ("p" projectile-switch-project)
    ("e" projectile-find-other-file)
    ("T" projectile-toggle-between-implementation-and-test)
    ("s" my/projectile-popwin-eshell)

    ("b" projectile-switch-to-buffer)
    ("%" projectile-replace)
    ("S" projectile-save-project-buffers)
    ("k" projectile-kill-buffers)

    ("r" projectile-rg)
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

  (my/add-to-global-hydra '("p" hydra-projectile/body "Projectile" :column "Tools"))
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

  (my/add-to-global-hydra '("t" hydra-popwin/body "Popwin" :column "Misc"))
  :config
  (push '("\\*dtache.*" :regexp t) popwin:special-display-config)
  (push '("\\*vterm\\*" :regexp t) popwin:special-display-config)
  (popwin-mode 1))

(use-package yasnippet
  :defer 5
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
  ((before-save . (lambda () (when (bound-and-true-p lsp-mode) (lsp-format-buffer))))
   (c++-mode . lsp)))

(use-package magit
  :defer t
  :init
  ;; "n" binding gets overridden, so we have to rebind it every time we open magit
  (add-hook 'magit-mode-hook
            (lambda ()
              (general-define-key
               :keymaps 'local
               :states '(motion normal visual operator)
               "n" 'magit-section-forward))) 
  :general
  (:keymaps 'magit-mode-map
            :states '(motion normal visual operator)
            "TAB" 'magit-section-cycle
            "e" 'magit-section-backward))

;; add support for git forges
(use-package forge :after magit)

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

;; TODO: see if this is actually the package I should be using
(use-package haskell-mode)

(use-package esh-help
  :after esh-mode
  :config
  (setup-esh-help-eldoc))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :demand t ;; Install if not already installed.
  :config
  ;; Enable in all Eshell buffers.
  (eshell-syntax-highlighting-global-mode +1))

(use-package rainbow-mode
  :init
  (setq rainbow-html-colors nil
        rainbow-r-colors nil
        rainbow-x-colors nil)
  :hook (prog-mode . rainbow-mode))

(use-package avy
  :init 
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o))
  (my/add-to-global-hydra '("a" avy-goto-subword-1 "Avy" :column "Editing"))
  :commands avy-goto-subword-1)

(use-package iedit
  :init 
  (my/add-to-global-hydra '("i" iedit-mode "Iedit" :column "Editing")))

(use-package comment-dwim-2
  :general
  ("M-;" 'comment-dwim-2)
  (:keymaps 'org-mode-map "M-;" 'org-comment-dwim-2))

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
  (my/add-to-global-hydra '("m" smart-compile "Smart Compile" :column "Tools")))

(use-package undo-tree
  :demand t
  :config
  (global-undo-tree-mode)
  :custom
  (evil-undo-system 'undo-tree))

(use-package minimap
  :defer t
  :init (setq minimap-window-location 'right))

(use-package vterm
  :defer t
  :init (setq vterm-always-compile-module t))

;; reset file-name-handler-alist
(when (boundp 'my/file-name-handler-alist)
      (setq file-name-handler-alist my/file-name-handler-alist))
