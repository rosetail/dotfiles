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
      '(("melpa" . 2)
        ("melpa-stable" . 1)
        ("gnu" . 0)))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
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

;; make middle click paste not move the cursor
(setq mouse-yank-at-point t)

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
(defvar sk-pacakge-loading-notice-list '(org yasnippet))

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

;; set default font
(set-frame-font "monospace-10" nil t)

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
  :custom-face
  ;; (doom-modeline-bar ((t (:background "#f99157"))))
  ;; (doom-modeline-evil-normal-state   ((t (:foreground "#99cc99"))))
  ;; (doom-modeline-evil-insert-state   ((t (:foreground "#6699cc"))))
  ;; (doom-modeline-evil-visual-state   ((t (:foreground "#66cccc"))))
  ;; (doom-modeline-evil-operator-state ((t (:foreground "#cc99cc"))))
  ;; (doom-modeline-evil-motion-state   ((t (:foreground "#ffcc66"))))
  ;; (doom-modeline-evil-replace-state  ((t (:foreground "#f99157"))))
  ;; (doom-modeline-evil-emacs-state    ((t (:foreground "#f2777a"))))
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

;; emacs renders Mononoki 2 pixels too short
;; (setq-default line-spacing 0)

(use-package modus-themes
  :ensure
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-slanted-constructs t
        modus-themes-region 'bg-only
        modus-themes-completions 'opinionated
        modus-themes-fringes 'intense
        modus-themes-org-blocks 'grayscale
        ;; modus-themes-org-blocks 'rainbow
        modus-themes-headings '((t . rainbow))
        modus-themes-bold-constructs nil)

  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;; Load the theme of your choice:
  (modus-themes-load-vivendi) ;; OR (modus-themes-load-vivendi)
  :custom
  ;; skip startup screen and go to scratch buffer
  ;; TODO: see about using general-custom
  (inhibit-startup-screen t)
  :bind ("<f5>" . modus-themes-toggle))

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
  (general-define-key
   :states '(normal insert emacs motion visual operater)
   :keymaps 'override
   "C-SPC" 'my/global-hydra)
  :demand t)

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
  :ensure t
  :config
  (global-evil-surround-mode 1))

;; TODO: actually learn these keybindings
(use-package evil-org
  :ensure t
  :after (:any (:all evil org) (:all evil org-agenda))
  :commands org-agenda
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
  :ensure nil ; don't ensure because it is built in to evil-org
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

(use-package selectrum
  :demand t
  :general ("C-x C-a" 'find-file)
  :config (selectrum-mode))

(use-package orderless
  :demand t
  :init
  (setq orderless-matching-styles '(orderless-initialism orderless-prefixes))
  :custom (completion-styles '(orderless)))

(use-package marginalia
  :demand t
  :init
  (setq marginalia-annotators
        '(marginalia-annotators-heavy
          marginalia-annotators-light))
  :config
  (marginalia-mode))

(use-package embark
  :demand t
  :after which-key
  :init
  (setq embark-action-indicator
        (lambda (map)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)
  :general
  ("M-o" 'embark-act))


(use-package consult
  :defer t
  :general
  ("M-'" 'consult-line)
  ("C-x b" 'consult-buffer))

(use-package embark-consult
  :demand t
  :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))

;; TODO: refactor this whole section
(use-package org
  :defer t
  :init
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

  :config
  ;; TODO: switch this to custom-face
  ;; (set-face-attribute 'org-block-begin-line nil :background 'unspecified)
  ;; (set-face-attribute 'org-block-end-line nil :background 'unspecified)
  (set-face-attribute 'org-block nil :extend t)
  :general
  (:keymaps 'org-mode-map
            :states 'insert
            "C-<return>" 'company-complete)
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

(use-package ox ; needed for org-export-filter-headline-function
  :ensure nil
  :after org
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
  :ensure nil
  :defer t
  :init
  (setq org-directory    "~/org"
        org-agenda-files (list "~/org/inbox.org"
                               "~/org/agenda.org"
                               ;; "~/org/projects.org"
                               )
        org-agenda-hide-tags-regexp "\\(inbox\\|project\\)"
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "|" "DONE(d)" "CANCELLED(c)"))

        ;; org-agenda-prefix-format
        ;; '((agenda . " %i %-12:c%?-12t% s")
        ;;   (todo   . " ")
        ;;   (tags   . " %i %-12:c")
        ;;   (search . " %i %-12:c"))
        org-refile-targets '((org-agenda-files :maxlevel . 9))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil

        org-capture-templates
        `(("i" "Inbox" entry  (file "inbox.org")
           "* TODO %?\n/Entered on/ %U")))
  
  (setq org-agenda-custom-commands
        '((" " "Agenda"
           ((agenda "" ((org-agenda-span 7)
                        (org-deadline-warning-days 0))) ;; week agenda
            
            (tags "inbox"
                  ((org-agenda-overriding-header "\nInbox")))

            (todo "NEXT"
                  ((org-agenda-overriding-header "\nNext Tasks")))
            
            (todo 'todo
                  ((org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'notdeadline))
                   (org-agenda-sorting-strategy '(deadline-up))
                   (org-agenda-overriding-header "\nDeadlines")))

            (tags "CLOSED>=\"<today>\""
                  ((org-agenda-overriding-header "\nCompleted today"))))

           ((org-agenda-compact-blocks t)
            ;; (org-agenda-skip-function
            ;; '(org-agenda-skip-entry-if 'todo '("HOLD")))
            ))))



  (setq org-log-done 'time)

  
  
  
  (defhydra hydra-org (:color blue :hint nil)
    "
_a_: Agenda, _c_: Capture"
    ("a" org-agenda)
    ("c" org-capture))

  (my/add-to-global-hydra '("o" hydra-org/body "Org" :column "Misc")))

(use-package company
  :defer 0.75
  :config (global-company-mode)
  :general
  ("C-<return>" 'company-complete))
(use-package company-posframe
  :after company
  :init
  (setq company-posframe-show-indicator nil
        company-posframe-show-metadata nil)
  :config (company-posframe-mode t))

(use-package smartparens
  :demand t
  :init
  ;; bind <leader>-s to smartparens hydra
  (my/add-to-global-hydra '("s" hydra-smartparens/body "Smartparens" :column "Editing"))
  
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
  (popwin-mode 1))

(use-package yasnippet
  :defer 5
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
(use-package hydra
  :custom-face 
  ;; (hydra-face-red      ((t (:foreground "#f2777a"))))
  ;; (hydra-face-blue     ((t (:foreground "#6699cc"))))
  ;; (hydra-face-amaranth ((t (:foreground "#f99157"))))
  ;; (hydra-face-teal     ((t (:foreground "#66cccc"))))
  ;; (hydra-face-pink     ((t (:foreground "#cc99cc"))))
  )

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
;;   (my/add-to-global-hydra '("r" hydra-quickrun/body "Quickrun" :column "Tools"))

(use-package undo-tree
  :demand t
  :config
  (global-undo-tree-mode)
  :custom
  (evil-undo-system 'undo-tree))

(use-package minimap
  :defer t
  :init (setq minimap-window-location 'right))

;; reset file-name-handler-alist
(when (boundp 'my/file-name-handler-alist)
      (setq file-name-handler-alist my/file-name-handler-alist))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(zerodark-theme zenburn-theme yasnippet-snippets yaml-mode whitespace-cleanup-mode which-key-posframe visual-regexp-steroids use-package undo-tree ujelly-theme twilight-theme twilight-bright-theme tree-sitter-langs transient-posframe telephone-line tao-theme sublimity srcery-theme spacemacs-theme spaceline spacegray-theme solarized-theme snow smart-compile smart-comment slime-company skewer-mode selectrum scheme-complete region-bindings-mode rainbow-mode rainbow-delimiters projectile pretty-hydra popwin polymode poet-theme phoenix-dark-pink-theme phoenix-dark-mono-theme parrot paredit page-break-lines ox-twbs outline-minor-faces origami org-ref orderless nyx-theme notmuch nord-theme nix-sandbox nix-haskell-mode naquadah-theme multiple-cursors moe-theme modus-themes mips-mode minimap mingus metalheart-theme meghanada markdown-preview-eww marginalia magit magic-latex-buffer lsp-mode lispyville latex-preview-pane kaolin-themes java-imports ivy-prescient ivy-bibtex horizon-theme hl-todo highlight-numbers highlight-escape-sequences haskell-snippets hacker-typer groovy-mode gradle-mode general fvwm-mode flyspell-correct-popup flyspell-correct-ivy flymd flx flatland-theme fish-mode fireplace f3 expand-region evil-vimish-fold evil-surround evil-smartparens evil-org evil-goggles evil-god-state evil-collection evil-colemak-basics ess eshell-syntax-highlighting eshell-outline esh-help embark-consult ebib dracula-theme doom-themes doom-modeline direnv darktooth-theme cyberpunk-theme ctrlf consult-flycheck company-posframe comment-dwim-2 color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized chocolate-theme bubbleberry-theme benchmark-init base16-theme badwolf-theme ayu-theme auctex apropospriate-theme ample-theme alect-themes aggressive-indent 0blayout)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
