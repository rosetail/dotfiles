;;; -*- lexical-binding: t; -*-
;; lexical loads faster

;; setting this var improves init time
;; from https://www.reddit.com/r/emacs/comments/mtb05k/emacs_init_time_decreased_65_after_i_realized_the/
(setq straight-check-for-modifications '(check-on-save find-when-checking))

;; make straight obey no-littering
(setq straight-base-dir "~/.emacs.d/var")

;; install straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "var/straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq use-package-compute-statistics t
      straight-use-package-by-default t ; auto-install packages
      use-package-always-defer t)

;; TODO: maybe move some of the stuff out of here
;; like column-number, visual line mode, savehist, scrolling?
(use-package emacs
  :straight nil
  :init
  ;; indent with space, not tab
  (setq-default indent-tabs-mode nil)
  ;; don't show nativecomp warnings
  (setq native-comp-async-report-warnings-errors nil)
  ;; make middle click paste not move the cursor
  (setq mouse-yank-at-point t)
  ;; make yes or no prompts faster
  (defalias 'yes-or-no-p 'y-or-n-p)
  ;; skip startup screen and go to scratch buffer
  (setq inhibit-startup-screen t)
  ;; only show cursor in current window
  (setq-default cursor-in-non-selected-windows nil)
  ;; make scrolling more like vim
  (setq scroll-margin 2
        scroll-conservatively 10000
        scroll-preserve-screen-position t)
  ;; start in org-mode with a source block for lisp evaluation
  (setq initial-major-mode #'org-mode
        initial-scratch-message "#+begin_src emacs-lisp\n;; This block is for text that is not saved, and for Lisp evaluation.\n;; To create a file, visit it with \\[find-file] and enter text in its buffer.\n\n#+end_src\n\n")
  ;; local vars
  (setq safe-local-variable-values
        ;; tangle on save for init file
        '((eval add-hook 'after-save-hook (lambda () (org-babel-tangle)) nil t))
        ;; this is for the dtache repo
        ignored-local-variable-values '((magit-todos-exclude-globs))
        warning-suppress-types '((org-element-cache)))
  
  ;; enable word wrapping in modes deriving from text-mode
  (add-hook 'text-mode-hook 'visual-line-mode)
  ;; show column number in modeline
  (column-number-mode 1)
  ;; don't confirm when running load-theme interactively
  (advice-add 'load-theme
              :around (lambda
                        (fn theme &optional no-confirm no-enable)
                        (funcall fn theme t)))
  :hook
  ((emacs-startup ; measure startup time
    . (lambda ()
        (message "Emacs ready in %s with %d garbage collections."
                 (format "%.2f seconds"
                         (float-time
                          (time-subtract after-init-time before-init-time)))
                 gcs-done)))
   (emacs-startup ; re-enable garbage collection after everything is done
    . (lambda ()
        (setq gc-cons-threshold 16777216 ; 16mb
              gc-cons-percentage 0.1)))))

(defun my/disable-cursor ()
  (interactive)
  (hl-line-mode)
  ;; hide the cursor
  ;; idk what this does but it works
  (setq-local evil-default-cursor '(ignore))
  (setq-local cursor-type nil))

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

(defun my/major-mode-hydra ()
  "Call `<major-mode>-hydra/body` if it is defined"
  (interactive)
  (let ((hydra-name (intern (concat (symbol-name major-mode) "-hydra/body"))))
    (if (fboundp hydra-name)
        (call-interactively hydra-name)
      (message (concat "No hydra defined for " (symbol-name major-mode))))))

(my/add-to-global-hydra '("m" my/major-mode-hydra "Major Mode" :column "Tools"))

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

(use-package no-littering
  :demand t
  :init
  ;; stop putting backup files everywhere
  (setq version-control t       ; Use version numbers for backups.
        kept-new-versions 10    ; Number of newest versions to keep.
        kept-old-versions 0     ; Number of oldest versions to keep.
        delete-old-versions t   ; Don't ask to delete excess backup versions.
        backup-by-copying t     ; Copy all files, don't rename them.
        vc-make-backup-files t) ; also backup files under version control
  :config
  ;; TODO: move this to the eshell section
  ;; keep eshell aliases in var
  (setq eshell-aliases-file "/home/rose/.emacs.d/var/eshell/alias")
  ;; put autosaves in var
  auto-save-file-name-transforms
  `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(use-package general
  :demand t
  :init
  (general-define-key "C-x C-a" 'find-file))
  
  ;; :config
  ;; TODO: maybe switch back to this from global-hydra
  ;; create leader key
  ;; bound to C-SPC in insert mode and SPC in all other modes
  ;; this has now been replaced with my/global-hydra
  ;; (general-create-definer leader-def
  ;;   :states '(normal insert emacs motion visual operater)
  ;;   :keymaps 'override
  ;;   :prefix "SPC"
  ;;   :non-normal-prefix "C-SPC"
  ;;   :prefix-map 'leader-prefix-map)
  ;; syntax is (leader-def "key" 'command)

(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil) ; evil collection needs this to be nil
  (setq evil-search-module 'evil-search) ; make ctrlf integration work
  :general
  ;; TODO: see if following setting was necessary
  ;; alias C-e and M-e to C-p and M-p so scrolling with vim navigation keys works
  ;; this leaves us unable to access anything bound to C-e or M-e, but I don't really use thse keys
                                        ;"C-e" (general-key "C-p")
                                        ;"M-e" (general-key "M-p")
  ;; use M-/ to unhighlight search
  
  ("M-/" 'evil-ex-nohighlight)
  ;; modify basic evil keybindings
  (:states '(motion normal visual operator)
           ;; make evil use visual lines
           "n"      'evil-next-visual-line
           "e"      'evil-previous-visual-line
           ;; use escape as C-g
           ;; TODO: this was disabled. See if it was useful
           ;; [escape] 'keyboard-quit
           "TAB"    'indent-for-tab-command)
  
  ;; scroll with C-n and C-e
  (:states '(motion normal visual operator insert)
           "C-n" 'evil-scroll-down
           "C-e" 'evil-scroll-up)
  ;; make text objects work properly in colemak
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
    ;; ;; rotate j t and f so j -> t -> f -> e
    ;; "j" "t"
    ;; "t" "f"
    ;; "f" "e"
    ;; "J" "T"
    ;; "T" "F"
    ;; "F" "E"
    ;; rotate j t and f so j -> f -> e
    "j" "f"
    "f" "e"
    "J" "F"
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
  (evil-mode 1))

(use-package evil-collection
  :demand t
  :after evil
  :init
  ;; TODO: see if this is a good setting
  (setq evil-collection-setup-minibuffer t)
  ;; TODO: I disabled the hook. see if this was doing anything
  ;; remap C-{j,k} to C-{n,e} for colemak
  (defun my-hjkl-rotation (_mode mode-keymaps &rest _rest)
    (evil-collection-translate-key 'normal mode-keymaps
      (kbd "C-n") (kbd "C-j")
      (kbd "C-e") (kbd "C-k")))

  (evil-collection-init)
  ;; :hook
  ;; (evil-collection-setup-hook . my-hjkl-rotation)

  :custom (evil-collection-company-use-tng nil) ; make company behave like emacs, not vim
  :config
  (evil-collection-init))

;; TODO: actually learn these keybindings
;; TODO: go through all the themes and see which ones are actually necessary
(use-package evil-org
  :demand t
  :after (:any (:all evil org) (:all evil org-agenda))
  :init
  (setq evil-org-use-additional-insert t ; make keybindings work in insert mode
        ;; use colemak movement
        evil-org-movement-bindings '((up . "e") (down . "n") (left . "h") (right . "i"))

        ;; add keybindings for more things
        evil-org-key-theme '(navigation
                             insert
                             todo
                             textobjects
                             additional
                             calendar))
  
  :hook ((org-mode . evil-org-mode)
         (evil-org-mode . evil-org-set-key-theme))
  :general
  ;; bind RET here so it doesn't clobber corfu
  (:keymaps 'org-mode-map
            "RET" 'evil-org-return)
  (:keymaps 'org-mode-map
            :states '(motion normal visual operator)
            "C-o" (evil-org-define-eol-command org-insert-heading)
            "M-o" (evil-org-define-eol-command org-insert-subheading)
            "C-t" 'evil-org-org-insert-todo-heading-below
            "M-t" 'evil-org-org-insert-todo-subheading-below)
  (:keymaps 'evil-org-mode-map 
            :states '(motion normal visual operator)
            "g i" 'org-down-element ; for g {h,n,e,i}
            "U"   'evil-org-insert-line)
  ;; evil-org doesn't bind textobjects properly so we have manually redefine them
  (:keymaps 'evil-inner-text-objects-map
            "e" 'evil-org-inner-object
            "E" 'evil-org-inner-element
            "r" 'evil-org-inner-greater-element
            "R" 'evil-org-inner-subtree))

(use-package evil-org-agenda
  :straight nil
  :demand t
  :after (:or evil-org org-agenda)
  :config
  (evil-org-agenda-set-keys)
  :general
  (:keymaps 'org-agenda-mode-map
            :states '(motion normal visual operator)
            "n"   'org-agenda-next-item
            "e"   'org-agenda-previous-item
            "gn"  'org-agenda-next-item
            "ge"  'org-agenda-previous-item
            "gI"  'evil-window-bottom
            "C-n" 'org-agenda-next-line
            "C-e" 'org-agenda-previous-line
            "b"   'org-agenda-tree-to-indirect-buffer
            "N"   'org-agenda-priority-down
            "E"   'org-agenda-priority-up
            "I"   'org-agenda-do-date-later
            "M-n" 'org-agenda-drag-line-forward
            "M-e" 'org-agenda-drag-line-backward
            "C-S-i" 'org-agenda-todo-nextset ; Original binding "C-S-<right>"
            "l"   'org-agenda-undo
            "u"   'org-agenda-diary-entry
            "U"   'org-agenda-clock-in))

(use-package evil-surround
  :demand t
  :config
  (global-evil-surround-mode 1))

;; TODO: maybe move my/global-hydre here
(use-package hydra
  :demand t
  :init
  ;; make function that lets us bind C-SPC without clobbering C-u C-SPC
  (defun my/C-SPC (arg)
    "Call set-mark-command if there's a prefix arg, otherwise call my/global-hydra"
    (interactive "P")
    (if arg
        (set-mark-command arg)
      (call-interactively #'my/global-hydra)))
  :general
  (:keymaps 'override
            :states '(normal motion visual operater)
            "SPC" 'my/global-hydra)
  (:keymaps 'override
            :states '(normal insert emacs motion visual operater)
            "C-SPC" 'my/C-SPC))

(use-package consult
  :config
  (add-to-list 'consult-buffer-filter "magit.*")
  (add-to-list 'consult-buffer-filter "\\*forge.*")
  (add-to-list 'consult-buffer-filter "\\*straight.*")
  (add-to-list 'consult-buffer-filter "\\*Native-compile-log\\*")
  (add-to-list 'consult-buffer-filter "\\*Async-native-compile-log\\*")
  
  ;; TODO: make this work for all tramp bookmarks, not just portage
  (defun my/consult-dont-preview-portage-bookmark ()
    "Buffer state function that doesn't preview Tramp buffers."
    (let ((orig-state (consult--bookmark-state))
          ;; TODO: maybe make this work for all tramp buffers
          (filter (lambda (cand restore)
                    (if (and (not restore) (string= "portage" cand))
                        (progn (message "preview disabled for this bookmark")
                               nil)
                      cand))))
      (lambda (cand restore)
        (funcall orig-state (funcall filter cand restore) restore))))
  (setq consult--source-bookmark
        (plist-put consult--source-bookmark :state #'my/consult-dont-preview-portage-bookmark))
  ;; TODO: make this work for all tramp files, not just portage
  (defun my/consult-dont-preview-portage-recentf ()
    "Buffer state function that doesn't preview Tramp buffers."
    (let ((orig-state (consult--file-state))
          ;; TODO: maybe make this work for all tramp buffers
          (filter (lambda (cand restore)
                    (if (and (not restore) (string-prefix-p "/etc/portage" cand))
                        (progn (message "preview disabled for this file")
                               nil)
                      cand))))
      (lambda (cand restore)
        (funcall orig-state (funcall filter cand restore) restore))))
  (setq consult--source-recent-file
        (plist-put consult--source-recent-file :state #'my/consult-dont-preview-portage-recentf))
  :general
  ("M-'" 'consult-line)
  ("C-x b" 'consult-buffer)
  (:keymaps 'consult-narrow-map
            "<" 'consult-narrow-help))

(use-package consult-dir
  :general ("C-x C-d" 'consult-dir)
  (:keymaps 'vertico-map
            "C-x C-d" 'consult-dir
            "C-x C-a" 'consult-dir-jump-file))

;; add consult actions to embark
(use-package embark-consult
  :demand t
  :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))

(use-package consult-yasnippet)

(defhydra hydra-consult (:color blue :hint nil)
  "
_b_: bookmarks    _r_: ripgrep        ^^_y_: yank
_i_: imenu        _f_/_l_: find/locate  _Y_: yank replace
_I_: imenu multi  _g_: grep           ^^_s_: insert snippet
_m_: jump to mark _G_: git grep
"
  ("b" consult-bookmark)
  ("i" consult-imenu)
  ("I" consult-imenu-multi)
  ("m" consult-global-mark)
  ("r" (lambda () (interactive) (consult-ripgrep default-directory)))
  ("f" (lambda () (interactive) (message default-directory) (consult-find default-directory)))
  ("l" 'consult-locate)
  ("g" (lambda () (interactive) (consult-grep default-directory)))
  ("G" (lambda () (interactive) (consult-git-grep default-directory)))
  ("y" consult-yank-from-kill-ring)
  ("Y" consult-yank-replace)
  ("s" consult-yasnippet))
(my/add-to-global-hydra '("c" hydra-consult/body "Consult" :column "Misc"))

(use-package corfu
  :demand t
  :init
  (setq tab-always-indent 'complete
        corfu-quit-no-match t
        corfu-preview-current nil
        corfu-quit-at-boundary t
        corfu-auto t)
  (defun corfu-move-to-minibuffer ()
    "Transfer the current completion session to the minibuffer"
    (interactive)
    (let ((completion-extra-properties corfu--extra)
          completion-cycle-threshold completion-cycling)
      (apply #'consult-completion-in-region completion-in-region--data)))
  
  (corfu-global-mode 1)
  :config
  ;; from corfu issue #12
  (evil-make-overriding-map corfu-map)
  (advice-add 'corfu--setup :after 'evil-normalize-keymaps)
  (advice-add 'corfu--teardown :after 'evil-normalize-keymaps)
  
  :general
  ("C-<tab>" 'completion-at-point)
  (:keymaps 'corfu-map
            "M-m" 'corfu-move-to-minibuffer
            "C-n" 'corfu-next
            "C-e" 'corfu-previous
            "<escape>" 'corfu-quit)
  :hook
  (eshell-mode . (lambda ()
                   (setq-local corfu-quit-at-boundary t
                               corfu-auto nil)
                   (corfu-mode))))

;; add more capf functions
(use-package cape
  :demand t
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-ispell))

;; better eshell completion
;; shows options with documentation for certain commands
(use-package pcmpl-args
  :demand t
  :after (:all eshell cape)
  :init
  ;; corfu doc told me to add this part
  
  ;; Silence the pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; toggle documentation with C-d
(use-package corfu-doc
  :straight (corfu-doc :type git :host github :repo "galeo/corfu-doc")
  :demand t
  :after corfu
  :init
  :general (:keymaps 'corfu-map
                     "M-d" 'corfu-doc-toggle
                     ;; scroll-down and scroll-up are reversed for some reason here
                     "M-e" 'corfu-doc-scroll-down
                     "M-n" 'corfu-doc-scroll-up))

;; show corfu icons
(use-package kind-icon
  :demand t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; TODO: take out the functions
(use-package embark
  :demand t
  :after marginalia ; TODO: maybe change this
  :init
  ;; don't show popup
  (setq embark-indicators #'embark-minimal-indicator)
  :config
  ;; add actionr for straight commands
  ;; from embark wiki
  (embark-define-keymap embark-straight-map
    "Keymap for straight commands"
    ("v" straight-visit-package-website)
    ("r" straight-get-recipe)
    ("c" straight-check-package)
    ("F" straight-pull-package)
    ("f" straight-fetch-package)
    ("p" straight-push-package)
    ("n" straight-normalize-package)
    ("m" straight-merge-package))
  (add-to-list 'embark-keymap-alist '(straight . embark-straight-map))
  (add-to-list 'marginalia-prompt-categories '("recipe\\|package" . straight))
  
  ;; show type of actions available in modeline
  ;; also from embark wiki
  (defvar embark--target-mode-timer nil)
  (defvar embark--target-mode-string "")

  (defun embark--target-mode-update ()
    (setq embark--target-mode-string
          (if-let (targets (embark--targets))
              (format "[%s%s] "
                      (propertize (symbol-name (plist-get (car targets) :type)) 'face 'bold)
                      (mapconcat (lambda (x) (format ", %s" (plist-get x :type)))
                                 (cdr targets)
                                 ""))
            "")))

  (define-minor-mode embark-target-mode
    "Shows the current targets in the modeline."
    :global t
    (setq mode-line-misc-info (assq-delete-all 'embark-target-mode mode-line-misc-info))
    (when embark--target-mode-timer
      (cancel-timer embark--target-mode-timer)
      (setq embark--target-mode-timer nil))
    (when embark-target-mode
      (push '(embark-target-mode (:eval embark--target-mode-string)) mode-line-misc-info)
      (setq embark--target-mode-timer
            (run-with-idle-timer 0.1 t #'embark--target-mode-update))))
  (embark-target-mode 1)
  
  :general
  (:keymaps 'override
            :states '(normal insert emacs motion visual operater)
            "C-." 'embark-act)
  (:keymaps 'vertico-map
            "C-." 'embark-act))

(use-package marginalia
  :demand t
  :config
  (marginalia-mode)
  ;; this fixes the annotations for describe variable/functions
  (add-to-list 'marginalia-annotator-registry
	       '(symbol-help marginalia-annotate-variable))
  :general
  (:keymaps 'minibuffer-local-map
            "M-a" 'marginalia-cycle))

;; needed for all-the-icons
(use-package svg-lib
  :config
  (setq svg-lib-icons-dir "~/.emacs.d/var/svg-lib"))

(use-package all-the-icons)

(use-package all-the-icons-completion
  :demand t
  :after marginalia
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package orderless
  :demand t
  :init
  (setq completion-styles '(orderless)
        ;; escape a space with \
        orderless-component-separator 'orderless-escapable-split-on-space
        ;; set up allowed completion styles
        orderless-matching-styles
        '(orderless-initialism orderless-prefixes orderless-regexp)))

(use-package vertico
  ;; Special recipe to load extensions conveniently
  :straight (vertico :files (:defaults "extensions/*")
                     :includes (vertico-indexed
                                vertico-flat
                                vertico-grid
                                vertico-mouse
                                vertico-quick
                                vertico-buffer
                                vertico-repeat
                                vertico-reverse
                                vertico-directory
                                vertico-multiform
                                vertico-unobtrusive))
  :demand t
  :init
  ;; use vertico-quick but with embark-acs
  ;; from https://kristofferbalintona.me/posts/vertico-marginalia-all-the-icons-completion-and-orderless/
  (defun my/vertico-quick-embark (&optional arg)
    "Embark on candidate using quick keys."
    (interactive)
    (when (vertico-quick-jump)
      (embark-act arg)))
  
  :config
  (evil-make-overriding-map vertico-map) ; don't let this be overridden by evil
  (vertico-mode 1)
  
  :general
  (:keymaps 'vertico-map
            "C-M-n" 'vertico-next-group
            "C-M-e" 'vertico-previous-group
            "C-e" 'vertico-previous ; evil normally overrides this
            "C-q" 'vertico-quick-exit
            "M-q" 'my/vertico-quick-embark
            "DEL" 'vertico-directory-delete-char
            "C-<backspace>" 'vertico-directory-delete-word)
  :hook ((minibuffer-setup . vertico-repeat-save) ; Make sure vertico state is saved
         (rfn-eshadow-update-overlay . vertico-directory-tidy))) ; this is for vertico-directory

(use-package doom-modeline
  :demand t
  :init
  ;; show word count of region
  (setq doom-modeline-enable-word-count t)
  (doom-modeline-mode 1))

(use-package desplay-line-numbers
  :straight nil
  :hook
  ;; show line numbers in fringe, but only in programming modes
  ((prog-mode . display-line-numbers-mode)
   (conf-mode . display-line-numbers-mode)))

(use-package minimap
  :init (setq minimap-window-location 'right))

(use-package popwin
  :demand t
  :init
  (defun my/popwin-eshell ()
    (interactive)
    (popwin:display-buffer-1
     (or (get-buffer "*eshell*")
         (save-window-excursion
           (call-interactively 'eshell)))))
  :config
  (add-to-list 'popwin:special-display-config '("\\*dtache.*" :regexp t))
  (add-to-list 'popwin:special-display-config '("\\*vterm\\*" :regexp t))
  (popwin-mode 1))

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

(use-package pp
  :straight nil
  ;; use pp-eval-last-sexp instead of eval-last-sexp
  :general
  ([remap eval-last-sexp] 'pp-eval-last-sexp
   [remap eval-expression] 'pp-eval-expression))

(use-package modus-themes
  :demand t
  :init
  (setq modus-themes-slanted-constructs t
        modus-themes-region '(bg-only)
        modus-themes-completions '(moderate)
        modus-themes-prompts '(bold background)
        modus-themes-fringes 'intense
        modus-themes-org-blocks 'grayscale ;
        modus-themes-headings '((t . (1.1 overline)))
        modus-themes-bold-constructs nil
        modus-themes-hl-line '(accented intense)
        modus-themes-markup '(background intense))
  
  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;; Load the theme of your choice:
  (modus-themes-load-vivendi)
  :general ("<f5>" 'modus-themes-toggle))

(use-package which-key
  :init (which-key-mode 1))

(use-package comint
  :straight nil
  :general
  (:keymaps 'comint-mode-map :states 'insert
            "C-a" 'comint-kill-input)
  (:keymaps 'comint-mode-map
            "C-e" 'comint-previous-prompt
            "C-n" 'comint-next-prompt
            "M-e" 'comint-previous-matching-input-from-input
            "M-n" 'comint-next-matching-input-from-input)
  (:keymaps 'shell-mode-map :states '(normal emacs motion visual operater)
            "g e" 'comint-previous-prompt
            "g n" 'comint-next-prompt
            "M-e" 'comint-previous-matching-input-from-input
            "M-n" 'comint-next-matching-input-from-input))

(use-package eshell
  :straight nil
  :init
  (setq eshell-banner-message "")
  :config
  (evil-make-overriding-map eshell-mode-map) ; don't let eshell bindings be overridden by evil
  
  ;; default eshell bookmark handler doesn't work so we have to rewrite it
  ;; this needs to be evaluated after eshell loads so it isn't overwritten
  (defun eshell-bookmark-jump (bookmark)
    "Default bookmark handler for Eshell buffers."
    (eshell)
    (setq-local default-directory (bookmark-prop-get bookmark 'location))
    (eshell-reset))
  
  :general
  (:keymaps 'eshell-hist-mode-map
            "M-r" 'prot-eshell-complete-history)
  (:keymaps 'eshell-mode-map
            "C-a" 'eshell-kill-input
            "C-e" 'eshell-previous-prompt
            "C-n" 'eshell-next-prompt
            "M-h" 'eshell-backward-argument
            "M-i" 'eshell-forward-argument
            "M-e" 'eshell-previous-matching-input-from-input ;
            "M-n" 'eshell-next-matching-input-from-input
            "M-b" 'eshell-insert-buffer-name
            "M-." (lambda () (interactive) (insert "$_")))
  (:keymaps 'eshell-mode-map :states '(normal motion visual operater)
            "g e" 'eshell-previous-prompt
            "g n" 'eshell-next-prompt
            "B"   'eshell-backward-argument
            "W"   'eshell-forward-argument
            "M-e" 'eshell-previous-matching-input-from-input
            "M-n" 'eshell-next-matching-input-from-input))

;; enable autosuggestions
;; TODO: maybe disable this because it depends on company
(use-package esh-autosuggest
  :hook (eshell-mode . esh-autosuggest-mode)
  :general
  (:keymaps 'esh-autosuggest-active-map
            "C-t" 'company-complete-selection))

(use-package fish-completion
  :demand t
  :after pcomplete
  :config (global-fish-completion-mode))

(use-package esh-help
  :demand t
  :after esh-mode
  :config
  (setup-esh-help-eldoc))

(defun my/eshell-scratchpad ()
  "This should be called from the command line to launch emacs with a scratchpad
This sets the 'eshell-buffer' parameter so the buffer can be killed when the frame closes"
  (eshell t)
  ;; don't ever delete the first eshell buffer
  (unless (string= eshell-buffer-name (buffer-name))
    (set-frame-parameter nil 'eshell-buffer (current-buffer))))

(defun my/close-eshell-scratchpad (&optional _frame)
  "Closes the eshell scratchpad. To be run in 'delete-frame-functions'"
  (let ((eshell-buffer (frame-parameter nil 'eshell-buffer)))
    (when eshell-buffer
      (kill-buffer eshell-buffer))))

(add-hook 'delete-frame-functions 'my/close-eshell-scratchpad)

(defun eshell/saveterm ()
  "Run this in an eshell scratchpad to stopp the the buffer from being killed
when the window exits"
  (set-frame-parameter nil 'eshell-buffer nil))

;; show last commands status in fringe
(use-package eshell-fringe-status
  :hook (eshell-mode . eshell-fringe-status-mode))

(use-package eshell-syntax-highlighting
  :demand t
  :after esh-mode
  :config
  ;; Enable in all Eshell buffers.
  (eshell-syntax-highlighting-global-mode +1))

(use-package eshell-vterm
  :after eshell
  :demand t
  :config
  (eshell-vterm-mode)
  ;; use v command to exec command in vterm
  (defalias 'eshell/v 'eshell-exec-visual))

;; directly from Prot's eshell config
(defvar prot-eshell--complete-history-prompt-history '()
  "History of `prot-eshell-narrow-output-highlight-regexp'.")

(defun prot-eshell--complete-history-prompt ()
  "Prompt with completion for history element.
Helper function for `prot-eshell-complete-history'."
  (if-let ((hist (ring-elements eshell-history-ring)))
      (completing-read "Input from history: "
                       hist nil t nil
                       'prot-eshell--complete-history-prompt-history)
    (user-error "There is no Eshell history")))

;;;###autoload
(defun prot-eshell-complete-history (elt)
  "Insert ELT from Eshell history using completion."
  (interactive
   (list (prot-eshell--complete-history-prompt)))
  (insert elt))

;; copied from Prot, who mostly copied from Sean Whitton

;; Copied on 2022-01-04 10:32 +0200 from Sean Whitton's `spw/eshell-cd'.
;; I had to change the symbol to use the prot-eshell prefix for lexical
;; binding.  Sean's dotfiles: <https://git.spwhitton.name/dotfiles>.
(defun my/eshell-cd (dir)
  "Routine to cd into DIR."
  (delete-region eshell-last-output-end (point-max))
  (when (> eshell-last-output-end (point))
    (goto-char eshell-last-output-end))
  (insert-and-inherit "cd " (eshell-quote-argument dir))
  (eshell-send-input))


(defun my/eshell-complete-recent-dir (dir &optional arg)
  "Switch to a recent Eshell directory.

When called interactively, DIR is selected with completion from
the elements of `eshell-last-dir-ring'.

With optional ARG prefix argument (\\[universal-argument]) also
open the directory in a `dired' buffer."
  (interactive
   (list
    (if-let ((dirs (ring-elements eshell-last-dir-ring)))
        (completing-read "Switch to recent dir: " dirs nil t)
      (user-error "There is no Eshell history for recent directories"))
    current-prefix-arg))
  (my/eshell-cd dir)
  ;; UPDATE 2022-01-04 10:48 +0200: The idea for `dired-other-window'
  ;; was taken from Sean Whitton's `spw/eshell-cd-recent-dir'.  Check
  ;; Sean's dotfiles: <https://git.spwhitton.name/dotfiles>.
  (when arg
    (dired-other-window dir)))

;; add an eshell function to call this interactively
(defun eshell/z ()
  (call-interactively #'my/eshell-complete-recent-dir))

(use-package vterm
  :init (setq vterm-always-compile-module t))

(use-package dtache
  :straight (dtache :type git :host gitlab :repo "niklaseklund/dtache"
                    :fork (:host gitlab :repo "rosetail/dtache" :branch "personal"))
  :init
  (setq dtache-detach-key (kbd "C-\\")
        ;; don't reuse the last input for shell commands
        dtache-shell-command-initial-input nil
        dtache-show-output-on-attach t
        ;; use custom env script with unbuffer
        dtache-env "~/.emacs.d/var/dtache/dtache-env"
        ;; obey no-littering
        dtache-db-directory "~/.emacs.d/var/dtache")
  :config
  ;; add embark actions to dtache-open-session
  (defvar embark-dtache-map (make-composed-keymap dtache-action-map embark-general-map))
  (add-to-list 'embark-keymap-alist '(dtache . embark-dtache-map))
  :hook (after-init . dtache-setup))

(use-package dtache-eshell
  :straight nil
  :hook (eshell-mode . dtache-eshell-mode))

(use-package dtache-shell
  :straight nil
  :config (dtache-shell-setup))

;; enable detatching compile commands
(use-package dtache-compile
  :straight nil
  :hook (after-init . dtache-compile-setup)
  :bind (([remap compile] . dtache-compile)
         ([remap recompile] . dtache-compile-recompile)))

(use-package dtache-consult
  :straight nil
  :bind ([remap dtache-open-session] . dtache-consult-session))

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

(my/add-to-global-hydra '("d" hydra-dtache/body "Dtache" :column "Tools"))

(use-package cc-mode
  :straight nil
  :init
  ;; major mode specific indentation
  (setq-default c-basic-offset 4
                cperl-indent-level 4)
  
  ;; set indentation styles for c-like languages
  (setq tab-width 4
        c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r")))
  :hook 
  ;; fix indentation in c++ mode
  ;; from https://stackoverflow.com/questions/14668744/emacs-indent-for-c-class-method
  (c++-mode
   . (lambda ()
       (c-set-offset 'access-label -2)
       (c-set-offset 'inline-open 0))))

(use-package haskell-mode)

(use-package auctex
  :demand t
  :after tex
  :no-require t
  :init
  ;; TODO: make this actually show up first
  ;; compile with latexmk
  (setq-default TeX-command-default "Latexmk")
  
  ;; parse on save
  (setq TeX-auto-save t
        TeX-auto-local ".build"
        ;; parse on load
        TeX-parse-self t
        TeX-master nil
        TeX-command-default "latexmk") ; TODO: see if this works
  :hook (LaTeX-mode . (lambda () (setq TeX-command-default "Latexmk")))
  :config
  (add-to-list 'TeX-command-list
   '("Latexmk" "latexmk -pvc -interaction=nonstopmode %t" TeX-run-TeX nil t
     :help "Make pdf output using latexmk.")))

(use-package org
  :init
  ;; let emphasis markers be nested
  (setq org-emphasis-regexp-components '("-[:space:]('\"{*/=~_" "-[:space:].,*/=~_:!?;'\")}\\[" "[:space:]" "." 1))
  ;; visual settings
  (setq org-startup-folded t
        org-hide-emphasis-markers t ; don't show borders for emphasis
        org-ellipsis " ▼"
        org-image-actual-width 600 ; make all images 600px wide
        org-tags-column 0 ; don't indent tags
        org-edit-src-content-indentation 0 ; don't indent src blocks
        org-src-window-setup 'current-window) ; don't make a new buffer for editing src blocks
  ;; these settings are for indenting subtrees and stuff
  ;; org-hide-leading-stars t
  ;; org-adapt-indentation nil
  ;; org-startup-indented t
  
  (setq org-src-tab-acts-natively t ; correctly indent src blocks with tab
        org-catch-invisible-edits 'smart
        org-ctrl-k-protect-subtree t)
  :config
  ;; enable habits
  ;; this should be in the agenda section but it needs be here so it's loaded after org and before org-agenda
  (add-to-list 'org-modules 'org-habit t)
  :hook
  ;; these are for my/org-keep-tags-to-right
  ;; (window-configuration-change . my/org-keep-tags-to-right)
  ;; (focus-in . my/org-keep-tags-to-right)
  ;; (focus-out . my/org-keep-tags-to-right)
  (org-mode . flyspell-mode))

(use-package org-agenda
  :straight nil
  :init
  ;; file settings
  (setq org-directory "~/org"
        ;; inbox.org must be first here or refiletargets will break
        org-agenda-files (list "~/org/inbox.org"
                               "~/org/agenda.org"))
  
  ;; todo settings
  (setq org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "|" "DONE(d)" "CANCELLED(c)"))
        ;; org-agenda-window-setup 'current-frame ; make agenda buffer only use the current frame
        org-use-fast-todo-selection 'expert
        org-checkbox-hierarchical-statistics nil ; make checkbox counters recursive
        ;; set default priority to C and add D priority
        org-priority-default 67
        org-priority-lowest 68)
  
  ;; agenda view settings 
  (setq org-agenda-prefix-format
        '((agenda . "  %i %-12:c%?-12t% s")
          (todo   . "  ")
          (tags   . "  %(my/org-print-parent-heading)")
          (search . "  %i %-12:c"))
        org-agenda-hide-tags-regexp ".*") ; don't show any tags
        
  ;; capture and refile
  (setq org-refile-targets `((,(cdr org-agenda-files) :maxlevel . 9))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-capture-templates
        `(("i" "Inbox" entry  (file "inbox.org")
           "* TODO %?\n/Entered on/ %U")))
  
  ;; metadata
  (setq org-capture-bookmark nil ; don't set bookmarks
        org-bookmark-names-plist nil
        org-log-done 'time) ; record when tasks are completed so we can see what was done today
  
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
                  ((org-agenda-skip-function #'my/org-agenda-skip-all-siblings-but-highest-priority)
                   (org-agenda-sorting-strategy '(priority-down))
                   (org-agenda-overriding-header "\nUndated Tasks")))
            ;; tasks that were completed today
            ;; from https://www.labri.fr/perso/nrougier/GTD/index.html
            (tags "CLOSED>=\"<today>\""
                  ((org-agenda-overriding-header "\nCompleted Today"))))
           ((org-agenda-compact-blocks t)))))
  
  ;; save agenda buffers before quitting and after reloading
  ;; from https://emacs.stackexchange.com/questions/477/how-do-i-automatically-save-org-mode-buffers
  (advice-add 'org-agenda-quit :before 'org-save-all-org-buffers)
  (advice-add 'org-agenda-redo :after 'org-save-all-org-buffers)) ; redo actually just refreshes

(use-package ox
  :straight nil
  :config
  (setq org-export-headline-levels -1 ; don't ever switch to enumerate for headlines
        org-export-with-tags nil
        org-export-with-smart-quotes t)) ; automatically use proper quotes when exporting

(use-package ox-html
  :straight nil
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
                "<style>#postamble .date{color:#6f6f70;} </style>")))

(use-package htmlize) ; needed fox src block fontification

(use-package ox-latex
  :straight nil
  :config
  ;; don't include TOC for latex
  (setq org-latex-toc-command "")
  ;; use the soul and csquotes packages
  (add-to-list 'org-latex-packages-alist '("" "soul"))
  (add-to-list 'org-latex-packages-alist '("" "csquotes"))
  
  ;; add filters from function section
  (add-to-list #'org-export-filter-headline-functions
             #'my/rm-org-latex-labels)
  (add-to-list #'org-export-filter-headline-functions
               #'my/org-noignore-headline)
  
  ;; define a general purpose general class and make it the default
  (add-to-list 'org-latex-classes
               '("general"
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
  (setq org-latex-default-class "general"))

;; ignore tags without the noignore headline in latex export
(defun my/org-noignore-headline (contents backend info)
  "Ignore headlines without tag `noignore'."
  (unless (string-match "\\`.*noignore.*\n" (downcase contents))
    (when (and (org-export-derived-backend-p backend 'latex)
               (string-match "\\`.*\n"
                             (downcase contents)))
      (replace-match "" nil nil contents))))

;; dont add \label when exporting
;; from https://stackoverflow.com/questions/18076328/org-mode-export-to-latex-suppress-generation-of-labels
(defun my/rm-org-latex-labels (text backend _info)
  "Remove labels auto-generated by `org-mode' export to LaTeX."
  (when (eq backend 'latex)
    (replace-regexp-in-string "\\\\label{sec:org[a-f0-9]+}\n" "" text)))

(defun my/toggle-org-latex-export-on-save ()
  "Toggle auto export to latex when saving an org buffer"
  (interactive)
  (if (memq 'org-latex-export-to-latex after-save-hook)
      (progn
        (org-latex-export-to-latex t)
        (remove-hook 'after-save-hook 'org-latex-export-to-latex t)
        (message "Disabled org latex export on save for current buffer..."))
    (add-hook 'after-save-hook 'org-latex-export-to-latex nil t)
    (message "Enabled org latex export on save for current buffer...")))

;; show emphasis markers when inside of an emphasis block
(use-package org-appear
  :demand t
  :after org
  :hook (org-mode . org-appear-mode))

;; enable org-checklist to uncheck boxes with habits
(use-package org-contrib :demand t :after org) ; we need this for org-checklist
(use-package org-checklist :demand t :after org-contrib
  :config
  (add-to-list 'org-modules 'org-checklist t))

(defun my/org-print-parent-heading ()
  "Print the name of the parent of the org element at point
The name is formatted to end in a colon and take up 24 characters
If the element has no header, return an empty string
If the parent heading has the tag \"printParentHeadingRecurse\", go up a level"
  (save-excursion
    (if (org-up-heading-safe)
        (if (member "printParentHeadingRecurse" (org-get-local-tags))
            (my/org-print-parent-heading)
          (format "%-24s" 
                  ;; (concat
                  (org-element-property :title (org-element-at-point))
                  ;; ":")
                  ))
      "")))

;; helper functions for org-agenda-custom-commands
;; from https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
;; modified to also skip entries that are scheaduled or have a deadline
(defun my/org-agenda-skip-all-siblings-but-highest-priority ()
  "Skip all but the highest priority TODO entry that is unscheduled and has no deadline."
  (let ((should-skip-entry nil)
        (priority (my/return-67.5-if-nil
                   (org-element-property :priority (org-element-at-point)))))
    (unless (my/org-agenda-is-heading-valid-for-unscheduled-tasks priority)
      (setq should-skip-entry t))
    (when (my/org-agenda-scan-for-higher-priority-siblings-below)
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
        (when (my/org-agenda-is-heading-valid-for-unscheduled-tasks priority)
          (setq should-skip-entry t))))
    (when should-skip-entry
      (or (outline-next-heading)
          (goto-char (point-max))))))

(defun my/org-agenda-is-heading-valid-for-unscheduled-tasks (priority)
  "Return t if todo state of the element at point is \"TODO\", it is not scheduled,
it has no deadline, and it's priority is >= PRIORITY"
  ;; it should be noted that in org, smallers numbers represent higher priorities
  (let ((current-heading-priority (my/return-67.5-if-nil
                                   (org-element-property :priority (org-element-at-point)))))
    (and (string= "TODO" (org-get-todo-state))
         (not (org-element-property :deadline (org-element-at-point)))
         (not (org-element-property :scheduled (org-element-at-point)))
         (<= current-heading-priority priority))))

(defun my/org-agenda-scan-for-higher-priority-siblings-below ()
  "Return t if the current heading has a sibling below it of a
higher priority"
  (let ((return-val nil)
        (priority (my/return-67.5-if-nil
                   (org-element-property :priority (org-element-at-point)))))
    (save-excursion
      (while (org-goto-sibling)
        (when (and (my/org-agenda-is-heading-valid-for-unscheduled-tasks priority)
                   (> priority (my/return-67.5-if-nil
                                (org-element-property :priority (org-element-at-point)))))
          (setq return-val t))))
    return-val))

;; TODO: see about returning org-priority-default instead
(defun my/return-67.5-if-nil (num)
  "If NUM is nil, return 67.5 Otherwise return NUM.
Org mode reads 67.5 as the priority between C and D. This
function is meant to be called with the priority of an org
heading, and if the priority is not set it will assume it's
between C and D."
  (if num
      num
    67.5))

;; align tags to the right regardless of window size
(defun my/org-keep-tags-to-right ()
  (interactive)
  (let ((buffer-modified (buffer-modified-p))
	(inhibit-message t)) ;; don't say the new column with every time
    (when (and (equal major-mode 'org-mode)
	       (org-get-buffer-tags))
      (setq org-tags-column (- 3 (window-body-width)))
      (org-align-tags t)
      (when (not buffer-modified)
	(set-buffer-modified-p nil)))))

(defhydra hydra-org (:color blue :hint nil)
    "
_a_: Agenda, _c_: Capture"
    ("a" org-agenda)
    ("c" org-capture))
  (my/add-to-global-hydra '("o" hydra-org/body "Org" :column "Misc"))

(defhydra org-mode-hydra (:color blue :hint nil)
  "
_SPC_: Jump to heading"
  ("SPC" consult-org-heading))

(use-package aggressive-indent
  :demand t
  :config
  ;; don't enable in html mode
  (add-to-list 'aggressive-indent-excluded-modes 'html-mode)

  ;; stop indenting the next line in c-like modes if ; is not entered yet
  (add-to-list
   'aggressive-indent-dont-indent-if
   '(and (derived-mode-p 'c++-mode)
         (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
                             (thing-at-point 'line)))))
  
  (global-aggressive-indent-mode 1))

(use-package comment-dwim-2
  :general
  ("M-;" 'comment-dwim-2)
  (:keymaps 'org-mode-map "M-;" 'org-comment-dwim-2))

(use-package electric
  :straight nil
  :init
  (electric-pair-mode 1)
  :config
  ;; disable <> pair
  ;; this needs to be set after electric is loaded
  (setq electric-pair-inhibit-predicate
        `(lambda (c)
           (if (char-equal c ?\<) t (,electric-pair-inhibit-predicate c)))))

(use-package iedit
  :init 
  (my/add-to-global-hydra '("i" iedit-mode "Iedit" :column "Editing")))

(use-package sudo-edit
  :general
  (:keymaps 'embark-file-map
            "s" 'sudo-edit))

(use-package undo-tree
  :init
  (setq evil-undo-system 'undo-tree)
  (global-undo-tree-mode))

(use-package yasnippet
  :defer 5
  :config
  (yas-global-mode))

(use-package yasnippet-snippets
  :demand t
  :after yasnippet)

(use-package avy
  :init 
  (setq avy-keys '(?a ?r ?s ?t ?n ?e ?i ?o))
  (my/add-to-global-hydra '("a" avy-goto-subword-1 "Avy" :column "Editing"))
  :commands avy-goto-subword-1)

(use-package ctrlf
  :demand t
  :general
  (:states
   '(motion normal visual operator)
   "/" 'ctrlf-forward-regexp
   "?" 'ctrlf-backward-regexp)
  :config
  (ctrlf-mode))

(use-package vimish-fold :demand t)

(use-package evil-vimish-fold
  :demand t
  :after vimish-fold
  :init
  ;; enable in all editing modes, not just prog-mode
  (setq evil-vimish-fold-target-modes '(prog-mode conf-mode text-mode))
  (global-evil-vimish-fold-mode)
  :general
  (:states
   '(motion normal visual)
   "z SPC" 'evil-toggle-fold
   "za" 'vimish-fold-avy
   "zn" 'evil-vimish-fold/next-fold
   "ze" 'evil-vimish-fold/previous-fold))

(use-package compile
  :straight nil
  :init
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
	        (message "No Compilation Errors!"))))))

(use-package eldoc
  :straight nil
  :init
  (global-eldoc-mode 1))

(use-package flycheck
  :defer 1
  :init
  ;; TODO: disable this again if it's too annoying
  ;; (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :config
  (global-flycheck-mode))

(use-package flyspell-correct
  :general
  (:keymaps 'flyspell-mode-map
            "C-;" 'flyspell-correct-wrapper))

(use-package lsp-mode
  :custom
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-indentation nil)
  :hook
  ((before-save . (lambda () (when (bound-and-true-p lsp-mode) (lsp-format-buffer))))
   (c++-mode . lsp)))

(use-package recentf
  :init
  (recentf-mode 1)
  :config
  ;; obey no-littering
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory))

;; save minibuffer input history
(use-package savehist
  :straight nil
  :demand t
  ;; this won't use the right file if loaded before no-littering
  :after no-littering
  :config
  (savehist-mode 1))

(use-package smart-compile)

(use-package bookmark
  :straight nil
  :init
  ;; always save bookmarks
  (setq bookmark-save-flag 1))

(use-package ebuild-mode)

(use-package package.use-mode
  :straight (package.use-mode :type git :host github :repo "C-xC-c/package.use-mode"))

(use-package magit
  :general
  (:keymaps 'magit-mode-map
            :states '(motion normal visual operator)
            "TAB" 'magit-section-cycle
            "e" 'magit-section-backward)
  ;; "n" binding gets overridden, so we have to rebind it every time we open magit
  :hook (magit-mode
         . (lambda ()
           (general-define-key
            :keymaps 'local
            :states '(motion normal visual operator)
            "n" 'magit-section-forward))))

;; add support for github and gitlab and stuff
(use-package forge :demand t :after magit)

(use-package telega
  :init
  (setq telega-old-date-format "%M.%D.%Y"))

(use-package transmission
  :init
  (setq transmission-refresh-modes
        '(transmission-mode transmission-files-mode transmission-info-mode transmission-peers-mode)))
;; replace cursor with hl-line-mode
;; :hook ((transmission-mode .       my/disable-cursor)
;;        (transmission-files-mode . my/disable-cursor)
;;        (transmission-info-mode .  my/disable-cursor)
;;        (transmission-peers-mode . my/disable-cursor)))

;; reset file-name-handler-alist
(when (boundp 'my/file-name-handler-alist)
      (setq file-name-handler-alist my/file-name-handler-alist))
