(defun toggle-org-latex-export-on-save ()
  (interactive)
  (if (memq 'org-latex-export-to-latex after-save-hook)
	  (progn
		(remove-hook 'after-save-hook 'org-latex-export-to-latex t)
		(message "Disabled org latex export on save for current buffer..."))
	(add-hook 'after-save-hook 'org-latex-export-to-latex nil t)
	(message "Enabled org latex export on save for current buffer...")))


(defun next-important-buffer ()
  (interactive)
  (switch-important-buffers (buffer-name) nil))

(defun previous-important-buffer ()
  (interactive)
  (switch-important-buffers (buffer-name) t))

;; (when (get-buffer "*scratch* (main)")
;;   (kill-buffer "*scratch* (main)"))
;; (when (get-buffer "*scratch*  (main)")
;;   (kill-buffer "*scratch*  (main)"))

(defun switch-important-buffers (name direction)
  (if direction
	  (previous-buffer)
	(next-buffer))

  (when (or (string-match-p "*scratch*.*(main)" (buffer-name))
			(string-match-p "\*helm.*\\*"     (buffer-name))
			(string-match-p "\*Compil.*\\*"   (buffer-name))
			(string-match-p "\*Help.*\\*"     (buffer-name))
			(string-match-p "\*Messages.*\\*" (buffer-name))
			(string-match-p "\*Calendar.*\\*" (buffer-name))
			(string-match-p "\*Flycheck.*\\*" (buffer-name))
			(string-match-p "\*JDEE.*\\*"     (buffer-name))
			(string-match-p "\*Latex.*\\*"    (buffer-name))
			(string-match-p "\*pdflatex.*\\*" (buffer-name))
			(string-match-p "\*.* output\\*"  (buffer-name))
			(string-match-p "\*pdflatex\\*"   (buffer-name))
			(string-match-p "\*latexmk\\*"    (buffer-name))
			(string-match-p "\*ebib.*\\*"     (buffer-name))
			(string-match-p "\*fix latex\\*"  (buffer-name))
			(string-match-p "\*direnv\\*"     (buffer-name))
			(string-match-p "\*Org.*\\*"      (buffer-name))
			(string-match-p "\*meghanada.*\\*" (buffer-name)))
	(if (equal name (buffer-name))
		(message "No other important buffers")
	  (switch-important-buffers name direction))))

(defun mu4e-render-message-as-markdown ()
  (interactive)
  (defvar link-regexp (concat
					   "\\["            ; open bracket
					   "\\([^]]+?\\)"   ; title
					   "\\(\\]\\)"      ; close bracket
					   "\\((\\)"        ; open paren
					   "\\([^)]+?\\)"   ; url
					   "\\()\\)"))      ; close paren

  (defvar bold-regexp "\\(\\*\\*\\)\\(\\(.\\|\n\\)*?\\)\\(\\*\\*\\)")
  (defvar italic-regexp "\\(_\\)\\(\\(.\\|\n\\)+?\\)\\(_\\)")
  (defvar trash-regexp (concat
						"\\(^\\("
						"|\\|"
						" \\|"
						"\\[\\](.*?)"
						"\\)+\n?\\)"))

  (save-excursion
	(let ((inhibit-read-only t)
		  (search-invisible nil)
		  (isearch-invisible nil))

	  (goto-char (point-min))
	  (while (re-search-forward link-regexp nil t)

		(make-button (match-beginning 1) (match-end 1)
					 'action `(lambda (button)
								(browse-url ,(match-string 4))))
		(add-text-properties (match-beginning 0) (match-beginning 1) '(invisible t))
		(add-text-properties (match-beginning 2) (match-end 2) '(invisible t))
		(add-text-properties (match-beginning 3) (match-end 3) '(invisible t))
		(add-text-properties (match-beginning 4) (match-end 4) '(invisible t))
		(add-text-properties (match-beginning 5) (match-end 5) '(invisible t)))

	  (goto-char (point-min))
	  (while (re-search-forward bold-regexp nil t)

		(add-text-properties (match-beginning 1) (match-end 1) '(invisible t))
		(add-text-properties (match-beginning 4) (match-end 4) '(invisible t))
		(let ((bold-overlay (make-overlay (match-beginning 2) (match-end 2))))
		  (overlay-put bold-overlay 'font-lock-face '(:weight bold))))

	  (goto-char (point-min))
	  (while (re-search-forward italic-regexp nil t)

		(add-text-properties (match-beginning 1) (match-end 1) '(invisible t))
		(add-text-properties (match-beginning 4) (match-end 4) '(invisible t))
		(let ((emph-overlay (make-overlay (match-beginning 2) (match-end 2))))
		  (overlay-put emph-overlay 'font-lock-face '(:slant italic))))

	  (goto-char (point-min))
	  (while (re-search-forward trash-regexp nil t)

		(add-text-properties (match-beginning 1) (match-end 1) '(invisible t)))


	  (flush-lines "^---\\(|---\\)*\\s-*$" (point-min) (point-max))


	  (goto-char (point-min))
	  (while (re-search-forward "\n\\s-*\n\\s-*\\(\n\\s-\\)*" nil t)
		(replace-match "\n\n"))
	  (fill-region (point-min) (point-max)))))

;; (add-hook 'mu4e-view-mode-hook 'mu4e-render-message-as-markdown)

(defun fix-bibtex-format ()
  (interactive)
  (save-excursion
	(remove-unneeded-info)
	(downcase-entries)
	(fix-brackets)
	;; (fix-urls) ; adding \url doesn't work
	(fix-commas)
	(add-keys-and-annotations)))

(defun remove-unneeded-info ()
  (goto-char (point-min))
  (flush-lines "^\\(Abstract\\|ISSN\\|Keywords\\) = "))

(defun downcase-entries ()
  (goto-char (point-min))
  (while (re-search-forward "^[A-z]+ = " nil t)
	(replace-match (concat "\t" (downcase (match-string 0))) t nil)))

(defun fix-brackets ()
  (goto-char (point-min))
  (while (re-search-forward "^\t[A-z]+ = \\({\\).*\\(},$\\)" nil t)
	(replace-match "\"" t nil nil 1)
	(replace-match "\"," t nil nil 2)))

(defun fix-urls ()
  (goto-char (point-min))
  (while (re-search-forward "^\turl = \"\\(\\)[^\\\\url].*\\(\\)\",$" nil t)
	(replace-match "\\url{" t t nil 1)
	(replace-match "}" t t nil 2)))

(defun fix-commas ()
  (goto-char (point-min))
  (while (re-search-forward "^\t[A-z]+ = .*\\(,\\)\n}" nil t)
	(replace-match "" t nil nil 1)))

(defun add-keys-and-annotations ()
  "Asks the user for a new key"
  (goto-char (point-min))
  (let ((case-fold-search nil))
	(while (re-search-forward "^@[A-z]+{\\([A-Z0-9]+\\),$" nil t)

	  (let ((match (match-string 1))
			(key (get-default-key)))

		;; I have to do this because emacs lisp can't break out of loops
		(re-search-backward "^@[A-z]+{\\([A-Z0-9]+\\),$" nil t)

		(highlight-regexp match)
		(replace-match (read-string (concat "New key (default " key "): ") nil t key) t t nil 1)
		(unhighlight-regexp match))

	  (when (y-or-n-p "Add annotation? ")
		(re-search-forward "^\t[A-z]+ = .*\\(\\)\n}" nil t)
		(goto-char (match-beginning 1))
		(replace-match ",\n\tannotation = \"\"" t nil nil 1)))
	(message "No more keys to replace")))


(defun get-default-key ()
  (let ((author)
		(year))

	(save-excursion
	  (re-search-forward "\tauthor = \"\\([A-z]+.\\)*," nil t)
	  (setq author (buffer-substring (match-beginning 1) (match-end 1))))

	(save-excursion
	  (re-search-forward "\tyear = \"[0-9]*\\([0-9][0-9]\\)" nil t)
	  (setq year (buffer-substring (match-beginning 1) (match-end 1))))

	(concat author year)))

(defun increment-number-or-char-at-point ()
  "Increment number or character at point."
  (interactive)
  (let ((nump  nil))
	(save-excursion
	  (skip-chars-backward "0123456789")
	  (when (looking-at "[0123456789]+")
		(replace-match (number-to-string (1+ (string-to-number (match-string 0)))))
		(setq nump  t)))
	(unless nump
	  (save-excursion
		(condition-case nil
			(let ((chr  (1+ (char-after))))
			  (unless (characterp chr) (error "Cannot increment char by one"))
			  (delete-char 1)
			  (insert chr))
		  (error (error "No character at point")))))))

(defun smart-run ()
  "This doc-string BUFFER-NAME should make flycheck shut up."
  (interactive)
  (let ((file (file-name-nondirectory (buffer-file-name)))
		(file-sans (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))))
	(cond ((string= major-mode "c-mode") (async-shell-command (concat"./" file-sans)))
		  ((string= major-mode "c++-mode") (async-shell-command (concat"./" file-sans)))
		  ((string= major-mode "java-mode") (async-shell-command (concat "java " file-sans)))
		  (t (shell-command (concat "./" file)))
		  )))

;; (require 'cl-lib)



;; (defmacro switch-important-buffers (direction name)
;;   ,@direction
;;   (if (and (or (string-match-p "\*helm.*\\*"     (buffer-name))
;;                (string-match-p "\*Compil.*\\*"   (buffer-name))
;;                (string-match-p "\*Help.*\\*"     (buffer-name))
;;                (string-match-p "\*Messages.*\\*" (buffer-name))
;;                (string-match-p "\*Flycheck.*\\*" (buffer-name))
;;                (string-match-p "\*JDEE.*\\*"     (buffer-name))
;;                (string-match-p "\*Latex.*\\*"    (buffer-name))
;;                (string-match-p "\*pdflatex.*\\*" (buffer-name))
;;                (string-match-p "\*.* output\\*"  (buffer-name))
;;                (string-match-p "\*Org.*\\*"      (buffer-name)))
;;            (not (eq (buffer-name) name)))
;;       (switch-important-buffers ,direction ,name)))



;; (defun previous-important-buffer (name)
;;   "Switch to the previous important buffer."
;;   (interactive)
;;   (previous-buffer)
;;   (if (and (or (string-match-p "\*helm.*\\*"     (buffer-name))
;;                (string-match-p "\*Compil.*\\*"   (buffer-name))
;;                (string-match-p "\*Help.*\\*"     (buffer-name))
;;                (string-match-p "\*Messages.*\\*" (buffer-name))
;;                (string-match-p "\*Flycheck.*\\*" (buffer-name))
;;                (string-match-p "\*JDEE.*\\*"     (buffer-name))
;;                (string-match-p "\*Latex.*\\*"    (buffer-name))
;;                (string-match-p "\*pdflatex.*\\*" (buffer-name))
;;                (string-match-p "\*.* output\\*"  (buffer-name))
;;                (string-match-p "\*Org.*\\*"      (buffer-name)))
;;            (not (eq (buffer-name) name)))
;;       (previous-important-buffer name)))


(defun other-window-backwards ()
  "Hi."
  (interactive)
  (other-window -1))

(defun indent-whole-buffer()
  (interactive)
  (save-excursion
	(mark-whole-buffer)
	(indent-for-tab-command)))

(defun new-empty-line-below ()
  "Emulates vi's o key."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun new-empty-line-above ()
  "Emulates vi's O key."
  (interactive)
  (move-beginning-of-line nil)
  (newline)
  (previous-line)
  (indent-for-tab-command))

;; (defun smart-beginning-of-line ()
;;   "Go to the first non-whitespace char or the first char in a line."
;;   (interactive)
;;   (let ((currentPoint (point)))
;;  (back-to-indentation)
;;  (if (= currentPoint (point))
;; (move-beginning-of-line nil))))

;; (defun duplicate-line ()
;;   "This puts the current line in the kill ring without killing it."
;;   (interactive)
;;   (save-excursion
;;  (move-beginning-of-line nil)
;;  (set-mark-command nil)
;;  (next-line)
;;  (kill-ring-save (region-beginning) (region-end))
;;  (yank)))

(defun save-line-or-region-to-kill-ring ()
  "This puts the current line in the kill ring without killing it."
  (interactive)
  (if (use-region-p)
	  (kill-ring-save (region-beginning) (region-end)))
  (save-excursion
	(move-beginning-of-line nil)
	(set-mark-command nil)
	(next-line)
	(kill-ring-save (region-beginning) (region-end))))

(defun arduino-template-makefile ()
  "Create an arduino-mk template."
  (interactive)
  (shell-command "cp /usr/local/share/Makefile $PWD"))

(defun cut-here ()
  "Insert cut-here line."
  (interactive)
  (insert "--8<---------------cut-here-------------8<--"))
