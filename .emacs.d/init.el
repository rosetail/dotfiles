;;; package --- sfd
;;; Commentary:
;;; Code:


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)

;; (org-babel-load-file (expand-file-name "~/.emacs.d/custom.org"))
(add-hook 'emacs-startup-hook
		  (lambda ()
			(message "Emacs ready in %s with %d garbage collections."
					 (format "%.2f seconds"
							 (float-time
							  (time-subtract after-init-time before-init-time)))
					 gcs-done)))
(defvar last-file-name-handler-alist file-name-handler-alist)
(setq gc-cons-threshold most-positive-fixnum
	  gc-cons-percentage 0.6
	  file-name-handler-alist nil)



