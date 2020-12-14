(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(setq package-archive-priorities
      '(("melpa-stable" . 2)
        ("gnu" . 1)
        ("melpa" . 0)))

(setq-default line-spacing 4)
(require 'use-package)
(setq use-package-always-ensure t)

(setq evil-want-keybinding nil)

(use-package which-key)
(use-package highlight-numbers)
(use-package popwin)
(use-package auctex :defer t :ensure t)
(use-package page-break-lines)
(use-package key-chord)
(use-package swiper)
(use-package counsel)
(use-package nix-mode)
(use-package nix-sandbox)
(use-package direnv)
(use-package prescient)
(use-package ivy-prescient)
(use-package magit)
(use-package doom-modeline)
(use-package yaml-mode)
(use-package sublimity)
(use-package ivy-bibtex)
(use-package flyspell-correct-popup)
;; (use-package helm-core)
(use-package origami)
(use-package mips-mode)
;; (use-package evil-mu4e)
(use-package evil-colemak-basics)
(use-package smartparens)
(use-package visual-regexp-steroids)
(use-package fish-mode)
(use-package evil-vimish-fold)
(use-package groovy-mode)
(use-package gradle-mode)
(use-package meghanada)
(use-package yasnippet-snippets)
(use-package rainbow-mode)
(use-package fvwm-mode)
(use-package markdown-mode)
(use-package markdown-preview-eww)
(use-package flymd)
(use-package hacker-typer)
(use-package ess)
(use-package pdf-tools)
(use-package ebib)
(use-package htmlize)
(use-package ox-twbs)
(use-package polymode)
(use-package f3)
(use-package telephone-line)
(use-package base16-theme)
(use-package scheme-complete)
(use-package java-imports)
(use-package aggressive-indent)
(use-package avy)
(use-package benchmark-init)
(use-package smart-comment)
(use-package evil-god-state)
(use-package expand-region)
(use-package fireplace)
(use-package haskell-snippets)
(use-package highlight-escape-sequences)
(use-package iedit)
(use-package latex-preview-pane)
(use-package magic-latex-buffer)
(use-package mingus)
(use-package paredit)
;; (use-package perspective)
(use-package skewer-mode)

(use-package benchmark-init
  :ensure t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;; (setq base16-theme-256-color-source 'base16-shell)


(use-package nix-haskell-mode
  :hook (haskell-mode . nix-haskell-mode))
(use-package general)

(use-package evil
  :init
  (setq-default cursor-in-non-selected-windows nil)
  :config
  (general-define-key
   :keymaps 'global-map
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

  (general-define-key
   :keymaps '(ivy-mode-map ivy-minibuffer-map)
   "C-e" 'ivy-previous-line)


  ;; (general-define-key
  ;;  :keymaps 'mu4e-headers-mode-map
  ;;  "RET" 'mu4e-headers-view-message)
  
  (general-translate-key nil '(motion normal visual operator)
	"u" "i"
	"U" "I"
	"I" "L"
	"i" "l")
  
  ;; (general-swap-key nil '(insert motion normal visual operator override)
  ;; 	"C-e" "C-p"
  ;; 	"M-e" "M-p")

  (evil-mode 1))

(use-package evil-collection
  :after evil
  :init
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
	  (kbd "C-j") (kbd "C-e")))


  ;; called after evil-collection makes its keybindings
  (add-hook 'evil-collection-setup-hook #'my-hjkl-rotation)
  (setq evil-collection-setup-minibuffer t
		evil-collection-company-use-tng nil)

  :config
  (require 'smtpmail)
  (evil-collection-define-key 'insert 'ivy-minibuffer-map
    (kbd "C-n") 'ivy-next-line
	(kbd "C-e") 'ivy-previous-line
	(kbd "M-e") 'ivy-previous-history-element)
  (evil-collection-init))

(use-package notmuch
  :defer t
  :init
  (setq message-send-mail-function
		(lambda ()
		  (if (y-or-n-p "Send Mail?")
			  (message-send-mail-with-sendmail))))

  ;; (add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
  (setq send-mail-function 'sendmail-send-it
		sendmail-program "/usr/bin/msmtp"
		mail-specify-envelope-from t
		message-sendmail-envelope-from 'header
		mail-envelope-from 'header
		user-full-name  "Rose Osterheld")
  ;; message-signature
  ;; (concat
  ;;  "Thank you,\n"
  ;;  "Rose Osterheld"))

  (defun notmuch-update ()
	(interactive)
	(message "Updating...")
	(message
	 (replace-regexp-in-string
	  "\n$" "" 
	  (shell-command-to-string "sh -c \"notmuch new 2>/dev/null | tail -n1\"")))
	(notmuch-refresh-all-buffers))

  :config
  (general-define-key
   :keymaps 'global-map
   "C-x m" (lambda ()
			 (interactive)
			 (notmuch-search "tag:inbox"))
   "C-x M" 'notmuch-search)
  (general-define-key
   :keymaps 'notmuch-search-mode-map
   :states 'normal
   "u" 'notmuch-update
   "r" 'notmuch-refresh-all-buffers)
  (general-define-key
   :keymaps 'notmuch-show-mode-map
   :states 'normal
   "M-n" 'notmuch-show-next-thread-show
   "M-e" 'notmuch-show-previous-thread-show
   "N" 'notmuch-show-next-message
   "E" 'notmuch-show-previous-message
   "a" 'notmuch-show-archive-thread
   "u" 'notmuch-update)
  (general-define-key
   :keymaps 'notmuch-tree-mode-map
   :states 'normal
   "RET" 'notmuch-tree-show-message))

(use-package org
  :defer t
  :init
  ;; (setq org-emphasis-regexp-components '("[:print:][:cntrl:]" "[:print:][:cntrl:]" "[:blank:]" "." 1))
  ;; (setq org-export-filter-final-output-functions '(org-remove-headlines))
  ;; (setq org-export-filter-final-output-functions nil)
  (defun org-keep-tags-to-right ()
	(interactive)
	(let ((buffer-modified (buffer-modified-p))
		  (inhibit-message t)) ;; don't say the new column with every time
	(when (and (equal major-mode 'org-mode)
			   (org-get-buffer-tags))
	  (setq org-tags-column (- 14 (window-body-width)))
	  (org-set-tags 4 t)
	  (when (not buffer-modified)
		(set-buffer-modified-p nil)))))


  (add-hook 'window-configuration-change-hook 'org-keep-tags-to-right)
  (add-hook 'focus-in-hook 'org-keep-tags-to-right)
  (add-hook 'focus-out-hook 'org-keep-tags-to-right)

  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)))
  (add-hook 'org-mode-hook
			(lambda ()
			  (visual-line-mode)
			  (org-indent-mode 1)))
  (setq org-tags-column -60)
  (setq org-ellipsis " ▼")

  :config
  (general-define-key
   :keymaps 'org-mode-map
   "C-,"		'previous-important-buffer
   "C-c b"		'ebib-insert-citation
   "C-c ["		'ebib-insert-bibtex-key
   "C-c w"		'org-writing-setup
   "C-c l"		'view-pdf-export)
  ;; "<C-return>"	'company-complete)

  (defadvice org-edit-src-code (around set-buffer-file-name activate compile)
	(let ((file-name (buffer-file-name))) ;; (1)
	  ad-do-it                            ;; (2)
	  (setq buffer-file-name file-name))) ;; (3)

  (defun org-ignore-headline (contents backend info)
    "Ignore headlines with tag `ignore'."
    (when (and (org-export-derived-backend-p backend 'latex 'html 'ascii)
			   (string-match "\\`.*ignore.*\n"
                             (downcase contents)))
	  (replace-match "" nil nil contents)))

  (require 'ox)
  (add-to-list 'org-export-filter-headline-functions 'org-ignore-headline)
  
  (org-add-link-type
   "ebib" 'ebib
   (lambda (args key format)
     (when  (eq format 'latex)
	   (if (equal args "<>")
		   (format "\\autocite{%s}" key)
         (format "\\autocite[%s]{%s}" (substring args 2) key)))))

  (defun ebib-load-current-bib ()
	(interactive)
	(ebib "./references.bib"))

  (defun view-pdf-export ()
	(interactive)
	(start-process "latexmk" "*latexmk*" "latexmk" "-pvc" "-f" "-interiction=nonstopmode" "-pdf" (concat (file-name-nondirectory (file-name-sans-extension (buffer-file-name))) ".tex")))

  (defun org-writing-setup ()
	(interactive)
	(flyspell-mode)
	(flyspell-buffer)
	(auto-fill-mode))

  :defer t)

(use-package evil-org
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook
   'evil-org-mode-hook
   (lambda ()
	 (evil-org-set-key-theme)

	 (general-define-key
	  :keymaps 'evil-org-mode-map
	  :states '(motion normal visual operator)
	  "g i" 'org-down-element
	  "U"   'evil-org-insert-line)
	 (general-define-key
	  :keymaps 'org-agenda-mode-map
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
	  "U"   'org-agenda-clock-in)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))


;; (persp-mode 1)
(which-key-mode 1)
(display-time-mode 1)
;; (semantic-mode 1)
(highlight-numbers-mode 1)
(setq highlight-numbers-generic-regexp "\\_<-?[[:digit:]]+?\\_>\\|#\\_<-?[a-f0-9]+?\\_>\\|\\_<-?0x[a-f0-9]+?\\_>")
(column-number-mode 1)
(setq auto-window-vscroll nil)

(setq initial-scratch-message
	  (format
	   ";; %s\n\n"
	   (replace-regexp-in-string
        "\n" "\n;; " ; comment each line
        (replace-regexp-in-string
         "\n$" ""    ; remove trailing linebreak
         (shell-command-to-string "fortune")))))

(defun erc-global-notify (matched-type nick msg)
  (interactive)
  (when (eq matched-type 'current-nick)
    (shell-command
     (concat "notify-send \""
             (car (split-string nick "!"))
             " mentioned you on irc\n\" \""
             msg
             "\""))))
;; (add-hook 'erc-text-matched-hook 'erc-global-notify)



(require 'popwin)
(popwin-mode 1)
(add-to-list 'auto-mode-alist '("sxhkdrc" . conf-mode))
(setq mouse-yank-at-point t
	  backup-directory-alist
	  `((".*" . ,temporary-file-directory))
	  auto-save-file-name-transforms
	  `((".*" ,temporary-file-directory t)))


(require 'tex)
(require 'reftex)
(add-hook 'prog-mode-hook  'prog-mode-setup)
(add-hook 'conf-mode-hook  'prog-mode-setup)
(add-hook 'text-mode-hook  'visual-line-mode)
(add-hook 'LateX-mode-hook  'visual-line-mode)
(add-hook 'LaTeX-mode-hook
		  '(lambda () (setq TeX-command-default "Latexmk")))
;; (add-hook 'LaTeX-mode-hook 'latex-preview-pane-mode)
;; (setq TeX-auto-save t)
(setq TeX-parse-self t)


(defun tex-preview-buffer-and-clear ()
  (interactive)
  (start-process "math clean up" "*math clean up*" "math-cleanup" "prepare")
  ;; (concat "sh -c \"mkdir -p " (file-name-directory (buffer-file-name)) ".auto/math_prev; "
  ;; "touch " (file-name-directory (buffer-file-name)) ".auto/math_prev/dummy; "
  ;; "mv " (file-name-directory (buffer-file-name)) ".auto/math_prev/* .\" > /dev/null"))
  (preview-buffer)
  (start-process "math clean up" "*math clean up*" "math-cleanup"))
;; (async-shell-command "sh -c \"mv *.prv preview.fmt prv* _region_* .auto/math_prev\""))

(defun my-latex-hook ()
  (local-set-key (kbd "C-c b") 'tex-preview-buffer-and-clear))

(add-hook 'LaTeX-mode-hook (lambda ()
							 (push 
							  '("Latexmk" "latexmk -pvc -interaction=nonstopmode %t" TeX-run-TeX nil t
								:help "Make pdf output using latexmk.")
							  TeX-command-list)))

(add-hook 'LaTeX-mode-hook 'my-latex-hook)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)


(defun prog-mode-setup ()
  ;; (linum-mode 1)
  (display-line-numbers-mode)
  (highlight-numbers-mode 1))
(require 'popwin)

(defun popwin-term:term ()
  (interactive)
  (popwin:display-buffer-1
   (or (get-buffer "*terminal<1>*")
	   (save-window-excursion
         (call-interactively 'eshell)))))
(add-hook 'term-mode-hook (lambda ()
                            (yas-minor-mode 0)
                            (local-unset-key (kbd "TAB"))))
;;                             (local-set-key (kbd "ESC") (term-send-raw-string "\e"))))
;; :default-config-keywords '(:position :top)))
(require 'flyspell)
(eval-after-load "flyspell"
  (lambda ()
	(add-hook 'text-mode-hook 'flyspell-mode)
    (define-key flyspell-mode-map (kbd "C-.") (next-important-buffer))
    (define-key flyspell-mode-map (kbd "C-,") (previous-important-buffer))))

(require 'bibtex)
(define-key bibtex-mode-map (kbd "C-c C-j") 'fix-bibtex-format)

(add-hook 'geiser-mode-hook
		  (lambda ()
            (local-set-key (kbd "C-,") 'previous-important-buffer)))

;; (use-package abbrev
;;   :diminish abbrev-mode)

(global-page-break-lines-mode)
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


(use-package company
  :init
  ;; (require 'company-clang)
  (global-company-mode)
  ;; (setq company-clang-insert-arguments nil)
  (setq company-backends
        '((company-files          ; files & directory
		   company-keywords       ; keywords
		   company-yasnippet
		   company-capf
		   company-dabbrev-code)))

  ;; (add-hook 'c-mode-hook
  ;;            (lambda ()
  ;;              (setq company-backends
  ;;                    '((company-files          ; files & directory
  ;;                       company-c-headers
  ;;                       company-keywords       ; keywords
  ;;                       company-yasnippet
  ;;                       company-irony
  ;;                       company-dabbrev-code)))))

  ;; (eval-after-load 'company
  ;;   '(add-to-list 'company-backends 'company-irony))
  (add-hook 'c-mode-hook
			(lambda ()
			  (add-to-list (make-local-variable 'company-backends)
						   'company-irony
						   ;; 'company-c-headers
						   ))) 
  (add-hook 'emacs-lisp-mode-hook
			(lambda ()
			  (add-to-list (make-local-variable 'company-backends)
						   'company-elisp)))

  ;; (autoload 'js2-mode)
  (add-hook 'js2-mode-hook
			(lambda ()
			  (tern-mode t)
			  (add-to-list (make-local-variable 'company-backends)
						   'company-tern)))



  :bind ([(control return)] . company-complete)
  :diminish company-mode
  )

(defun erc-highlight-nick-better ()
  (let ((nick-regexp "[0-9A-Za-z-|`_'^]*"))
    (erc-highlight-nick-better--highlight-regexp
     '(:inherit 'font-lock-function-name-face)
     (concat
	  "^<" nick-regexp "> "
	  "\\(" nick-regexp "\\)"
	  ": "))
    (erc-highlight-nick-better--highlight-regexp
     '(:foreground "#cd5542" :weight bold)
     (concat
	  "^\\* "
	  "\\(" nick-regexp "\\) "))))


(defun erc-highlight-nick-better--highlight-regexp (face regexp)
  (save-excursion
    (goto-char (point-min))
    (let ((inhibit-read-only t))
	  (while (re-search-forward regexp nil t)
        (let ((tagged-nick (match-string 1))
			  (tagged-nick-begining (match-beginning 1))
			  (tagged-nick-end (match-end 1)))
		  (when (member tagged-nick (erc-get-channel-nickname-list))
            (set-text-properties
             tagged-nick-begining
             tagged-nick-end
             `(font-lock-face ,face))))))))

(autoload 'flycheck "prog-mode")
(use-package flycheck
  :defer t
  :init
  (setq flycheck-executable-find
		(lambda (cmd) (direnv-update-environment default-directory)(executable-find cmd)))
  (add-hook 'after-init-hook #'global-flycheck-mode)
  ;; (eval-after-load 'flycheck
  ;; '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
  ;; (flycheck-disable-checker 'emacs-lisp-checkdoc)
  ;; (add-hook 'c-mode-hook
  ;; (lambda () (setq flycheck-clang-include-path
  ;; (list (expand-file-name "~/linux/include/")
  ;; (expand-file-name "~/linux/arch/x86/include")
  ;; (expand-file-name "~/qmk_firmware/keyboard/ergodox_ez/")))
  ;; ))
  :config
  (flycheck-define-checker proselint
	"A linter for prose."
	:command ("proselint" source-inplace)
	:error-patterns
	((warning line-start (file-name) ":" line ":" column ": "
			  (id (one-or-more (not (any " "))))
			  (message) line-end))
	:modes (text-mode markdown-mode gfm-mode latex-mode))

  (add-to-list 'flycheck-checkers 'proselint)
  :diminish flycheck-mode)

(use-package ivy
  :bind
  ("C-x 8 RET"  . counsel-unicode-char)
  ("M-x"		. counsel-M-x)
  ("C-x C-f"	. counsel-find-file)
  ("C-h f"		. counsel-describe-function)
  ("C-h v"		. counsel-describe-variable)
  ("M-X"		. execute-extended-command)
  ("M-'"		. swiper)
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

;; (require 'helm)
;; (require 'helm-config)
;; (use-package helm
;;   :init
;;   (setq helm-boring-buffer-regexp-list
;;         (quote
;;          (  "\\Minibuf.+\\*"
;;             "\\` "
;;             ;; "\\*helm.+\\*"
;;             ;; "\*[[:upper:]].*\\*"
;;             "\*helm.*\\*"
;;             "\*Compilation.*\\*"
;;             "\*Shell.*\\*"
;;             "\*Messages.*\\*"
;;             ;; "\\*[\([[:upper]]\|helm\)].+\\*"
;;             )))
;;   (setq helm-autoresize-max-height 20
;;         helm-autoresize-min-height 0
;;         ;; helm-move-to-line-cycle-in-source t
;;         helm-M-x-fuzzy-match t
;;         helm-mode-fuzzy-match t
;;         helm-completion-in-region-fuzzy-match t
;;         helm-split-window-in-side-p t)

;;   :config
;;   (helm-mode 1)
;;   (helm-autoresize-mode 1)
;;   (helm-flx-mode 1)
;;   ;; (helm-fuzzier-mode 1)
;;   :bind
;;   ("M-x"     . helm-M-x)
;;   ("C-x C-f" . helm-find-files)
;;   ("M-X"     . execute-extended-command)
;;   ("M-Y"   . helm-show-kill-ring)
;;   ("M-'"     . helm-swoop)
;;   :diminish helm-mode
;;   :defer t)

(use-package hideshow
  :bind ("C-c h" . hs-toggle-hiding)
  :config (hs-minor-mode)
  :diminish hs-minor-mode)

;; (use-package irony
;;   :init
;;   :config
;;   (add-hook 'c++-mode-hook 'irony-mode)
;;   (add-hook 'c-mode-hook 'irony-mode)
;;   (add-hook 'objc-mode-hook 'irony-mode)
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(require 'key-chord)
(use-package key-chord
  :init
  ;; (setq key-chord-two-keys-delay 0.05)
  ;; (key-chord-define-global " i" (lookup-key global-map (kbd "C-c")))
  ;; (key-chord-define-global " l" (lookup-key global-map (kbd "C-c")))
  ;; (key-chord-define-global " r" (lookup-key global-map (kbd "C-c")))
  ;; (key-chord-define-global " s" (lookup-key global-map (kbd "C-c")))

  ;; ;; (key-chord-define-global " s" (lookup-key global-map (kbd "C-x")))
  ;; (key-chord-define-global " k" (lookup-key global-map (kbd "C-x")))
  ;; (key-chord-define-global " e" (lookup-key global-map (kbd "C-x")))
  ;; (key-chord-define-global " d" (lookup-key global-map (kbd "C-x")))

  ;; (key-chord-define-global "sd" 'popwin-term:term)
  ;; (key-chord-define-global "nm" 'smart-compile)
  ;; (key-chord-define-global "m," 'smart-run)
  ;; (key-chord-define-global "as" 'ace-jump-word-mode)
  ;; (key-chord-define-global "fg" 'comment-dwim-2)
  ;; (key-chord-define-global "k;" 'kill-buffer-and-window)
  ;; (key-chord-define-global "kl" 'kill-buffer)
  ;; (key-chord-define-global "op" 'other-window)
  ;; (key-chord-define-global "oi" (other-window -1))
  ;; (key-chord-define-global "df" 'duplicate-line)
  ;; (key-chord-define-global "qw" 'neotree-toggle)
  ;; (key-chord-define-global ",." 'popwin:close-popup-window)
  ;; (key-chord-define-global "jl" 'avy-goto-subword-1)
  ;; (key-chord-define-global "jk" 'helm-mini)
  
  :bind (("C-."     . next-important-buffer)
         ("C-c SPC" . avy-goto-subword-1)
         ("C-c a"   . avy-goto-subword-1)
         ;; ("C-c n"   . helm-mini)
         ("C-,"     . previous-important-buffer)
         ("C-;"     . iedit-mode)
         ("C-c M"   . smart-run)
         ("C-c TAB" . indent-whole-buffer)
         ("C-o"     . new-empty-line-below)
         ("C-S-o"   . new-empty-line-above)
         ("C-c f"   . comment-dwim-2)
         ("C-c h"   . hs-toggle-hiding)
         ("C-c k"   . kill-buffer)
         ("C-c p"   . popwin:close-popup-window)
         ("C-c d"   . duplicate-line)
         ("C-c s"   . popwin-term:term)
         ("C-x C-a" . counsel-find-file)
         ;; ("C-'"     . helm-flyspell-correct)
		 ;; ("C-'"		. flyspell-correct-wrapper)
         ("C-="     . er/expand-region)
         ("M-;"     . smart-comment))
  ;; ("C-c SPC" . set-rectangular-region-anchor))
  :config
  (key-chord-mode 1))

(fset 'duplicate-line
	  [C-S-backspace ?\C-y ?\C-y ?\C-p])

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

(add-hook 'js2-mode-hook 'skewer-mode)
(add-hook 'css-mode-hook 'skewer-css-mode)
(add-hook 'html-mode-hook 'skewer-html-mode)

(setq scroll-margin 2)
(setq scroll-conservatively 10000
      scroll-preserve-screen-position t)

;; (setq load-path (append (list (expand-file-name
;; "/usr/local/lilypond/usr/share/emacs/site-lisp")) load-path))
;; (autoload 'LilyPond-mode "lilypond-mode" "LilyPond Editing Mode" t)
;; (add-to-list 'auto-mode-alist '("\\.ly$" . LilyPond-mode))
;; (add-to-list 'auto-mode-alist '("\\.ily$" . LilyPond-mode))
;; (require 'lilypond-mode)

(defun lilypond-play ()
  (interactive)
  (compile (concat
            "timidity \""
            (file-name-sans-extension (buffer-file-name))
            ".midi\"")))
(add-hook 'LilyPond-mode-hook (lambda () (local-set-key (kbd "C-c <return>") 'lilypond-play)))

;; (use-package projectile
;;   :init
;;   (require 'projectile)
;;   (setq projectile-enable-caching t))

(use-package region-bindings-mode
  :bind
  (:map region-bindings-mode-map
		("d" . delete-region)
		("w" . kill-ring-save)
		("k" . kill-region))
  :config
  (region-bindings-mode-enable))

(use-package multiple-cursors
  ;; :after region-bindings-mode
  :bind
  ("C->" . mc/mark-next-lines)
  ("C-<" . mc/mark-previous-lines)
  (:map region-bindings-mode-map
		("a" . mc/mark-all-like-this)
		("M-n" . mc/mark-next-like-this)
		("M-p" . mc/mark-previous-like-this)
		;; ("m" . mc/mark-next-like-this-extended)
		("M-f" . mc/mark-all-like-this-in-defun)
		("." . mc/unmark-next-like-this)
		("," . mc/unmark-previous-like-this)
		(">" . mc/skip-to-next-like-this)
		("<" . mc/skip-to-previous-like-this)
		("M-r" . mc/mark-all-in-region)
		("M-j" . mc/insert-numbers)
		("M-l" . mc/insert-letters)))

(use-package slime
  :init
  (setq inferior-lisp-program "sbcl")
  :config
  (slime-setup)
  :defer t)

(use-package slime-company
  :config
  (slime-setup '(slime-fancy slime-company))
  :after slime)

(use-package flyspell-correct-ivy
  :defer t
  :bind ("C-'" . flyspell-correct-wrapper)
  :init
  (setq flyspell-correct-interface #'flyspell-correct-ivy))

(use-package smart-compile
  :bind ("C-c m" . smart-compile))

;; (use-package hes
;;   :config
;;   (hes-mode 1)
;;   :diminish which-key-mode)

(use-package undo-tree
  :config (global-undo-tree-mode 1)
  :diminish undo-tree-mode)

(use-package whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode)
  :diminish whitespace-cleanup-mode)

(use-package yasnippet
  :defer t
  :config (yas-global-mode 1)
  :diminish yas-minor-mode)

(use-package spaceline
  :init
  (require 'spaceline-config)
  (spaceline-spacemacs-theme)
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state)
  :config
  (spaceline-toggle-minor-modes-off))
;; (set-face-attribute 'spaceline-evil-motion nil :background "#ae81ff")
;; (set-face-attribute 'spaceline-evil-emacs nil :background "#fb4933")
;; (set-face-attribute 'spaceline-evil-insert nil :background "#d3869b")
;; (set-face-attribute 'spaceline-evil-normal nil :background "#83a598")
;; (set-face-attribute 'spaceline-evil-replace nil :background "#fabd2f")
;; (set-face-attribute 'spaceline-evil-visual nil :background "#fe8019"))

(use-package direnv
  :config
  (direnv-mode))

