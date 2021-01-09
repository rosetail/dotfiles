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
(setq gc-cons-threshold 402653184
	  gc-cons-percentage 0.6
	  file-name-handler-alist nil)



(load-file (expand-file-name "~/.emacs.d/functions.el"))
(load-file (expand-file-name "~/.emacs.d/config.el"))



(put 'upcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)
(autoload 'LilyPond-mode "lilypond-mode")

(setq load-path (append (list (expand-file-name
							   "/usr/local/lilypond/usr/share/emacs/site-lisp")) load-path))
(autoload 'LilyPond-mode "lilypond-mode" "LilyPond Editing Mode" t)
(add-to-list 'auto-mode-alist '("\\.ly$" . LilyPond-mode))
(add-to-list 'auto-mode-alist '("\\.ily$" . LilyPond-mode))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#2d2d2d" :foreground "#d3d0c8" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :foundry "CYRE" :family "Inconsolata"))))
 '(erc-current-nick-face ((t (:inherit font-lock-keyword-face))))
 '(erc-nick-default-face ((t (:inherit font-lock-function-name-face :weight normal))))
 '(erc-prompt-face ((t (:foreground "#ffcc66"))))
 '(message-cited-text-1 ((t (:foreground "#6699cc"))))
 '(message-mml ((t (:foreground "#cc99cc"))))
 '(notmuch-search-flagged-face ((t nil)))
 '(notmuch-tag-added ((t nil)))
 '(notmuch-tag-deleted ((t (:strike-through "#f2777a"))))
 '(notmuch-tag-face ((t (:foreground "#6699cc"))))
 '(notmuch-tag-flagged ((t (:foreground "#66cccc"))))
 '(notmuch-tag-unread ((t (:foreground "#f2777a" :weight bold))))
 '(notmuch-tree-match-author-face ((t (:foreground "#99cc99"))))
 '(notmuch-tree-match-tag-face ((t (:foreground "#6699cc"))))
 '(org-scheduled ((t (:inherit font-lock-type-face :foreground "#ffcc66"))))
 '(outline-2 ((t (:inherit font-lock-string-face))))
 '(outline-4 ((t (:inherit font-lock-type-face))))
 '(outline-5 ((t (:inherit font-lock-constant-face))))
 '(outline-6 ((t (:inherit font-lock-builtin-face))))
 '(outline-7 ((t (:inherit font-lock-variable-name-face))))
 '(outline-8 ((t (:inherit font-lock-comment-face)))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-auto-default "/home/rose/.emacs.d/auctex/.auto")
 '(TeX-auto-local ".build")
 '(TeX-auto-private '("/home/rose/.emacs.d/auctex/auto"))
 '(TeX-region "_region_")
 '(ansi-color-names-vector
   ["#454545" "#cd5542" "#6aaf50" "#baba36" "#5180b3" "#ab75c3" "#68a5e9" "#bdbdb3"])
 '(auth-source-save-behavior nil)
 '(auto-save-default nil)
 '(avy-background t)
 '(avy-highlight-first t)
 '(avy-keys
   '(97 115 100 102 103 104 106 107 108 110 118 105 101 109 99 111 119 114 117 116 98 120 44 122 46 121 112 113))
 '(base16-theme-256-color-source "colors")
 '(beacon-blink-when-buffer-changes nil)
 '(beacon-blink-when-window-changes nil)
 '(beacon-color "#5180b3")
 '(beacon-mode t)
 '(c-basic-offset 4)
 '(c-default-style "bsd")
 '(column-number-mode t)
 '(compilation-message-face 'default)
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#657b83")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-enabled-themes '(base16-eighties))
 '(custom-safe-themes
   '("8c1dd3d6fdfb2bee6b8f05d13d167f200befe1712d0abfdc47bb6d3b706c3434" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "7559ac0083d1f08a46f65920303f970898a3d80f05905d01e81d49bb4c7f9e39" "2a998a3b66a0a6068bcb8b53cd3b519d230dd1527b07232e54c8b9d84061d48d" "dd4628d6c2d1f84ad7908c859797b24cc6239dfe7d71b3363ccdd2b88963f336" "f984e2f9765a69f7394527b44eaa28052ff3664a505f9ec9c60c088ca4e9fc0b" "9c4acf7b5801f25501f0db26ac3eee3dc263ed51afd01f9dcfda706a15234733" "146061a7ceea4ccc75d975a3bb41432382f656c50b9989c7dc1a7bb6952f6eb4" "e1498b2416922aa561076edc5c9b0ad7b34d8ff849f335c13364c8f4276904f0" "1025e775a6d93981454680ddef169b6c51cc14cea8cb02d1872f9d3ce7a1da66" "808b47c5c5583b5e439d8532da736b5e6b0552f6e89f8dafaab5631aace601dd" "44961a9303c92926740fc4121829c32abca38ba3a91897a4eab2aa3b7634bed4" "5a39d2a29906ab273f7900a2ae843e9aa29ed5d205873e1199af4c9ec921aaab" "840db7f67ce92c39deb38f38fbc5a990b8f89b0f47b77b96d98e4bf400ee590a" "7c0495f3973b9f79251205995ccccca41262b41a86553f81efe71c0dc3a50f43" "e6a9337674f6c967311b939bb4f81aefb65a96908c3749f4dd8d4500f6d79242" "91375c6dc506913ac7488f655b5afe934f343a0b223021c349105d37748c6696" "1d3863142a1325c1d038905c82b9aaf83f7594bb6158b52ad32ed23d3a97490a" "31e9b1ab4e6ccb742b3b5395287760a0adbfc8a7b86c2eda4555c8080a9338d9" "fb44ced1e15903449772b750c081e6b8f687732147aa43cfa2e7d9a38820744b" "46720e46428c490e7b2ddeafc2112c5a796c8cf4af71bd6b758d5c19316aff06" "8e51e44e5b079b2862335fcc5ff0f1e761dc595c7ccdb8398094fb8e088b2d50" "c2efd2e2e96b052dd91940b100d86885337a37be1245167642451cf6da5b924a" "65f35d1e0d0858947f854dc898bfd830e832189d5555e875705a939836b53054" "ef403aa0588ca64e05269a7a5df03a5259a00303ef6dfbd2519a9b81e4bce95c" "a62f0662e6aa7b05d0b4493a8e245ab31492765561b08192df61c9d1c7e1ddee" "819d24b9aba8fcb446aecfb59f87d1817a6d3eb07de7fdec67743ef32194438b" "428bdd4b98d4d58cd094e7e074c4a82151ad4a77b9c9e30d75c56dc5a07f26c5" "04790c9929eacf32d508b84d34e80ad2ee233f13f17767190531b8b350b9ef22" "b0c5c6cc59d530d3f6fbcfa67801993669ce062dda1435014f74cafac7d86246" "f5f3a6fb685fe5e1587bafd07db3bf25a0655f3ddc579ed9d331b6b19827ea46" "304c39b190267e9b863c0cf9c989da76dcfbb0649cbcb89592e7c5c08348fce9" "542e6fee85eea8e47243a5647358c344111aa9c04510394720a3108803c8ddd1" "ec3e6185729e1a22d4af9163a689643b168e1597f114e1cec31bdb1ab05aa539" "ffac21ab88a0f4603969a24b96993bd73a13fe0989db7ed76d94c305891fad64" "69e7e7069edb56f9ed08c28ccf0db7af8f30134cab6415d5cf38ec5967348a3c" "45a8b89e995faa5c69aa79920acff5d7cb14978fbf140cdd53621b09d782edcf" "732ccca2e9170bcfd4ee5070159923f0c811e52b019106b1fc5eaa043dff4030" "41eb3fe4c6b80c7ad156a8c52e9dd6093e8856c7bbf2b92cc3a4108ceb385087" "0961d780bd14561c505986166d167606239af3e2c3117265c9377e9b8204bf96" "fc7fd2530b82a722ceb5b211f9e732d15ad41d5306c011253a0ba43aaf93dccc" "b67b2279fa90e4098aa126d8356931c7a76921001ddff0a8d4a0541080dee5f6" "3e34e9bf818cf6301fcabae2005bba8e61b1caba97d95509c8da78cff5f2ec8e" "a61109d38200252de49997a49d84045c726fa8d0f4dd637fce0b8affaa5c8620" "cabc32838ccceea97404f6fcb7ce791c6e38491fd19baa0fcfb336dcc5f6e23c" "c614d2423075491e6b7f38a4b7ea1c68f31764b9b815e35c9741e9490119efc0" "1d079355c721b517fdc9891f0fda927fe3f87288f2e6cc3b8566655a64ca5453" "34ed3e2fa4a1cb2ce7400c7f1a6c8f12931d8021435bad841fdc1192bd1cc7da" "b3bcf1b12ef2a7606c7697d71b934ca0bdd495d52f901e73ce008c4c9825a3aa" "f1e3641bd6cdd4bf571fc27820a2dfd2dd03c8cf0e251e04d5509632dfe6f004" "6529b7cdd025a85fe25c8abd3c99eecc0c69c83f3e377badba0857220d28a916" "8150b4a525731db1bd7657e2e04c791334fd2ff42cc7c66bf5cf9d6e62d77e7f" "527df6ab42b54d2e5f4eec8b091bd79b2fa9a1da38f5addd297d1c91aa19b616" "bc4c89a7b91cfbd3e28b2a8e9e6750079a985237b960384f158515d32c7f0490" "760ce657e710a77bcf6df51d97e51aae2ee7db1fba21bbad07aab0fa0f42f834" "3380a2766cf0590d50d6366c5a91e976bdc3c413df963a0ab9952314b4577299" "4b2679eac1095b60c2065187d713c39fbba27039d75c9c928a1f3b5d824a3b18" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "7a1190ad27c73888f8d16142457f59026b01fa654f353c17f997d83565c0fc65" "5a7830712d709a4fc128a7998b7fa963f37e960fd2e8aa75c76f692b36e6cf3c" "80930c775cef2a97f2305bae6737a1c736079fdcc62a6fdf7b55de669fbbcd13" "d9dab332207600e49400d798ed05f38372ec32132b3f7d2ba697e59088021555" "446cc97923e30dec43f10573ac085e384975d8a0c55159464ea6ef001f4a16ba" "196df8815910c1a3422b5f7c1f45a72edfa851f6a1d672b7b727d9551bb7c7ba" "6145e62774a589c074a31a05dfa5efdf8789cf869104e905956f0cbd7eda9d0e" "7220c44ef252ec651491125f1d95ad555fdfdc88f872d3552766862d63454582" "50ff65ab3c92ce4758cc6cd10ebb3d6150a0e2da15b751d7fbee3d68bba35a94" "ecfd522bd04e43c16e58bd8af7991bc9583b8e56286ea0959a428b3d7991bbd8" "8543b328ed10bc7c16a8a35c523699befac0de00753824d7e90148bca583f986" "6daa09c8c2c68de3ff1b83694115231faa7e650fdbb668bc76275f0f2ce2a437" "9be1d34d961a40d94ef94d0d08a364c3d27201f3c98c9d38e36f10588469ea57" "3be1f5387122b935a26e02795196bc90860c57a62940f768f138b02383d9a257" "36282815a2eaab9ba67d7653cf23b1a4e230e4907c7f110eebf3cdf1445d8370" "264b639ee1d01cd81f6ab49a63b6354d902c7f7ed17ecf6e8c2bd5eb6d8ca09c" "1436d643b98844555d56c59c74004eb158dc85fc55d2e7205f8d9b8c860e177f" "7f89ec3c988c398b88f7304a75ed225eaac64efa8df3638c815acc563dfd3b55" "36ca8f60565af20ef4f30783aa16a26d96c02df7b4e54e9900a5138fb33808da" "cd4d1a0656fee24dc062b997f54d6f9b7da8f6dc8053ac858f15820f9a04a679" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "16dd114a84d0aeccc5ad6fd64752a11ea2e841e3853234f19dc02a7b91f5d661" "cc71cf67745d023dd2e81f69172888e5e9298a80a2684cbf6d340973dd0e9b75" "5f2f2686307e101aeb00fe95adaa1b28b57b808f2bc8a0c1529d9118ff224c80" "3b0a350918ee819dca209cec62d867678d7dac74f6195f5e3799aa206358a983" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "eae831de756bb480240479794e85f1da0789c6f2f7746e5cc999370bbc8d9c8a" "4feee83c4fbbe8b827650d0f9af4ba7da903a5d117d849a3ccee88262805f40d" "d411730c6ed8440b4a2b92948d997c4b71332acf9bb13b31e9445da16445fe43" "4eb982b248bf818a72877ecb126a2f95d71eea24680022789b14c3dec7629c1b" "10e231624707d46f7b2059cc9280c332f7c7a530ebc17dba7e506df34c5332c4" "938d8c186c4cb9ec4a8d8bc159285e0d0f07bad46edf20aa469a89d0d2a586ea" "d320493111089afba1563bc3962d8ea1117dd2b3abb189aeebdc8c51b5517ddb" "25c242b3c808f38b0389879b9cba325fb1fa81a0a5e61ac7cae8da9a32e2811b" "5a0eee1070a4fc64268f008a4c7abfda32d912118e080e18c3c865ef864d1bea" "70f5a47eb08fe7a4ccb88e2550d377ce085fedce81cf30c56e3077f95a2909f2" "5436e5df71047d1fdd1079afa8341a442b1e26dd68b35b7d3c5ef8bd222057d1" "2623b253f65db881f35c660353f9caa6f12a5e6758a9a4d6de9b2a7c0aed5502" "78f614a58e085bd7b33809e98b6f1a5cdd38dae6257e48176ce21424ee89d058" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "1db337246ebc9c083be0d728f8d20913a0f46edc0a00277746ba411c149d7fe5" "12b4427ae6e0eef8b870b450e59e75122d5080016a9061c9696959e50d578057" "ad950f1b1bf65682e390f3547d479fd35d8c66cafa2b8aa28179d78122faa947" "badc4f9ae3ee82a5ca711f3fd48c3f49ebe20e6303bba1912d4e2d19dd60ec98" "f25c30c1de1994cc0660fa65c6703706f3dc509a342559e3b5b2102e50d83e4f" "f1cf6fc8d1eea1fb6304488424936dd59e80e8c5990732641802cb82e928deeb" "4f5bb895d88b6fe6a983e63429f154b8d939b4a8c581956493783b2515e22d6d" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "3d3e8f714e95ca3270d2958cb773df89490fc0f208094214f6402712e61467b6" default))
 '(direnv-always-show-summary nil)
 '(direnv-show-paths-in-summary t)
 '(display-line-numbers 'visual)
 '(display-line-numbers-current-absolute nil)
 '(display-line-numbers-type 'visual)
 '(display-line-numbers-width 0)
 '(display-time-default-load-average nil)
 '(display-time-format "%l:%M%p")
 '(display-time-mode t)
 '(ebib-bibtex-dialect 'biblatex)
 '(ebib-citation-commands
   '((any
	  (("cite" "\\cite%<[%A]%>{%K}")))
	 (org-mode
	  (("ebib" "[[ebib:<>%A][%K]]")))
	 (markdown-mode
	  (("text" "@%K%< [%A]%>")
	   ("paren" "[%(%<%A %>@%K%<, %A%>%; )]")
	   ("year" "[-@%K%< %A%>]")))))
 '(ebib-index-display-fields '("title"))
 '(ebib-layout 'window)
 '(ede-project-directories '("/home/rose/sketchbook/sketch_dec28a"))
 '(electric-pair-mode t)
 '(electric-pair-pairs '((34 . 34) (40 . 41) (123 . 125) (91 . 93)))
 '(enable-recursive-minibuffers t)
 '(erc-button-alist
   '(('nicknames 0 erc-button-buttonize-nicks erc-nick-popup 0)
	 (erc-button-url-regexp 0 t browse-url 0)
	 ("<URL: *\\([^<> ]+\\) *>" 0 t browse-url 1)
	 ("[`]\\([a-zA-Z][-a-zA-Z_0-9]+\\)[']" 1 t erc-button-describe-symbol 1)
	 ("\\bInfo:[\"]\\([^\"]+\\)[\"]" 0 t Info-goto-node 1)
	 ("\\b\\(Ward\\|Wiki\\|WardsWiki\\|TheWiki\\):\\([A-Z][a-z]+\\([A-Z][a-z]+\\)+\\)" 0 t
	  (lambda
		(page)
		(browse-url
		 (concat "http://c2.com/cgi-bin/wiki?" page)))
	  2)
	 ("EmacsWiki:\\([A-Z][a-z]+\\([A-Z][a-z]+\\)+\\)" 0 t erc-browse-emacswiki 1)
	 ("Lisp:\\([a-zA-Z.+-]+\\)" 0 t erc-browse-emacswiki-lisp 1)
	 ("\\bGoogle:\\([^
]+\\)" 0 t
(lambda
  (keywords)
  (browse-url
   (format erc-button-google-url keywords)))
1)
	 ("\\brfc[#: ]?\\([0-9]+\\)" 0 t
	  (lambda
		(num)
		(browse-url
		 (format erc-button-rfc-url num)))
	  1)
	 ("\\s-\\(@\\([0-9][0-9][0-9]\\)\\)" 1 t erc-button-beats-to-time 2)))
 '(erc-button-buttonize-nicks nil)
 '(erc-insert-modify-hook
   '(erc-highlight-nick-better erc-controls-highlight erc-fill erc-button-add-buttons erc-match-message erc-add-timestamp))
 '(erc-keywords nil)
 '(erc-kill-server-buffer-on-quit t)
 '(erc-lurker-hide-list '("JOIN" "NICK" "PART" "QUIT"))
 '(erc-lurker-threshold-time 900)
 '(erc-modules
   '(autojoin button completion fill irccontrols list match menu move-to-prompt netsplit networks noncommands readonly ring sound stamp spelling track))
 '(erc-nick "fasd")
 '(erc-notifications-mode nil)
 '(erc-track-exclude-types '("JOIN" "NICK" "QUIT" "333" "353"))
 '(erc-track-position-in-mode-line 'before-modes)
 '(erc-track-use-faces t)
 '(eshell-glob-case-insensitive t)
 '(eshell-send-direct-to-subprocesses t)
 '(evil-collection-key-blacklist nil)
 '(evil-collection-mode-list
   '(ag alchemist anaconda-mode arc-mode bookmark
		(buff-menu "buff-menu")
		calc calendar cider cmake-mode comint company compilation custom cus-theme daemons deadgrep debbugs debug diff-mode dired doc-view ebib edebug ediff eglot elfeed elisp-mode elisp-refs emms epa ert eshell eval-sexp-fu evil-mc eww flycheck flymake free-keys geiser ggtags git-timemachine go-mode grep help guix hackernews helm ibuffer image image-dired image+ imenu-list indium info ivy js2-mode log-view lsp-ui-imenu lua-mode kotlin-mode macrostep man magit magit-todos minibuffer mu4e mu4e-conversation neotree notmuch nov
		(occur replace)
		outline p4
		(package-menu package)
		pass
		(pdf pdf-view)
		popup proced prodigy profiler python quickrun racer realgud reftex restclient rjsx-mode robe ruby-mode rtags simple slime
		(term term ansi-term multi-term)
		tide transmission typescript-mode vc-annotate vc-dir vc-git vdiff view vlf w3m wdired wgrep which-key woman xref youtube-dl
		(ztree ztree-diff)))
 '(evil-org-key-theme
   '(navigation insert return textobjects additional todo heading calendar))
 '(evil-org-movement-bindings '((up . "e") (down . "n") (left . "h") (right . "i")))
 '(evil-org-use-additional-insert t)
 '(face-font-family-alternatives
   '(("Monospace" "Inconsolata Lgc" "courier" "fixed")
	 ("Monospace Serif" "Courier 10 Pitch" "Consolas" "Courier Std" "FreeMono" "Nimbus Mono L" "courier" "fixed")
	 ("courier" "CMU Typewriter Text" "fixed")
	 ("Sans Serif" "helv" "helvetica" "arial" "fixed")
	 ("helv" "helvetica" "arial" "fixed")))
 '(fci-rule-color "#ECEFF1")
 '(flycheck-clang-include-path '("/home/rose/linux/include/"))
 '(flycheck-disabled-checkers '(emacs-lisp-checkdoc))
 '(flycheck-python-pycompile-executable "/usr/bin/python3")
 '(geiser-autodoc-identifier-format "%s:%s")
 '(glasses-separate-parentheses-p nil)
 '(glasses-uncapitalize-p t)
 '(global-aggressive-indent-mode nil)
 '(helm-boring-buffer-regexp-list
   '("\\Minibuf.+\\*" "\\` " "*helm.*\\*" "*Compilation.*\\*" "*Shell.*\\*" "*Messages.*\\*" "*meghanada.*\\*" "\\*latexmk\\*"))
 '(helm-minibuffer-history-key "M-p")
 '(hes-mode t)
 '(highlight-changes-colors '("#d33682" "#6c71c4"))
 '(highlight-numbers-mode nil t)
 '(highlight-symbol-colors
   (--map
	(solarized-color-blend it "#fdf6e3" 0.25)
	'("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2")))
 '(highlight-symbol-foreground-color "#586e75")
 '(highlight-tail-colors
   '(("#eee8d5" . 0)
	 ("#B4C342" . 20)
	 ("#69CABF" . 30)
	 ("#69B7F0" . 50)
	 ("#DEB542" . 60)
	 ("#F2804F" . 70)
	 ("#F771AC" . 85)
	 ("#eee8d5" . 100)))
 '(hl-bg-colors
   '("#DEB542" "#F2804F" "#FF6E64" "#F771AC" "#9EA0E5" "#69B7F0" "#69CABF" "#B4C342"))
 '(hl-fg-colors
   '("#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3"))
 '(hl-sexp-background-color "#efebe9")
 '(inhibit-startup-screen t)
 '(ispell-program-name "aspell")
 '(ivy-extra-directories nil)
 '(ivy-prescient-mode t)
 '(jdee-server-dir "~/.emacs.d/jdee")
 '(magit-diff-use-overlays nil)
 '(meghanada-javac-xlint "-Xlint:-processing")
 '(menu-bar-mode nil)
 '(minimap-always-recenter nil)
 '(minimap-hide-fringes t)
 '(minimap-highlight-line nil)
 '(minimap-mode t)
 '(minimap-recenter-type 'middle)
 '(minimap-tag-only nil)
 '(minimap-window-location 'right)
 '(mu4e-alert-email-count-title "mu4e")
 '(mu4e-alert-email-notification-types '(subjects))
 '(mu4e-alert-modeline-formatter 'mu4e-alert-default-mode-line-formatter)
 '(mu4e-alert-set-window-urgency nil)
 '(mu4e-alert-style 'libnotify)
 '(mu4e-view-html-plaintext-ratio-heuristic 10000)
 '(mu4e-view-prefer-html nil)
 '(neo-theme 'arrow)
 '(notmuch-address-internal-completion '(received nil))
 '(notmuch-search-line-faces
   '(("unread" . notmuch-search-unread-face)
	 ("flagged" . notmuch-search-flagged-face)
	 ("deleted" . font-lock-comment-face)))
 '(notmuch-search-oldest-first nil)
 '(notmuch-tag-added-formats
   '((".*"
	  (notmuch-apply-face tag
						  '(:underline
							(:color "#99cc99" :style line))))))
 '(notmuch-tag-formats
   '(("unread"
	  (propertize tag 'face 'notmuch-tag-unread))
	 ("flagged"
	  (notmuch-tag-format-image-data tag
									 (notmuch-tag-star-icon))
	  (propertize tag 'face 'notmuch-tag-flagged))
	 ("inbox"
	  (propertize tag 'face
				  '(:foreground "#cc99cc")))
	 ("cockmail"
	  (propertize tag 'face
				  '(:foreground "#fe8019")))
	 ("sent"
	  (propertize tag 'face
				  '(:foreground "#b8bb26")))))
 '(nrepl-message-colors
   '("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4"))
 '(org-adapt-indentation nil)
 '(org-agenda-files '("~/todo.org"))
 '(org-babel-load-languages '((latex . t) (emacs-lisp . t)))
 '(org-checkbox-hierarchical-statistics nil)
 '(org-confirm-babel-evaluate nil)
 '(org-export-allow-bind-keywords t)
 '(org-export-backends '(html icalendar latex md odt))
 '(org-export-preserve-breaks nil)
 '(org-export-with-author nil)
 '(org-export-with-section-numbers nil)
 '(org-export-with-toc nil)
 '(org-hide-emphasis-markers t)
 '(org-hierarchical-todo-statistics nil)
 '(org-icalendar-include-todo 'all)
 '(org-indent-indentation-per-level 1)
 '(org-latex-classes
   '(("article" "\\documentclass[12pt]{article}"
	  ("\\section{%s}" . "\\section*{%s}")
	  ("\\subsection{%s}" . "\\subsection*{%s}")
	  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	  ("\\paragraph{%s}" . "\\paragraph*{%s}")
	  ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
	 ("report" "\\documentclass[11pt]{report}"
	  ("\\part{%s}" . "\\part*{%s}")
	  ("\\chapter{%s}" . "\\chapter*{%s}")
	  ("\\section{%s}" . "\\section*{%s}")
	  ("\\subsection{%s}" . "\\subsection*{%s}")
	  ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))
	 ("book" "\\documentclass[11pt]{book}"
	  ("\\part{%s}" . "\\part*{%s}")
	  ("\\chapter{%s}" . "\\chapter*{%s}")
	  ("\\section{%s}" . "\\section*{%s}")
	  ("\\subsection{%s}" . "\\subsection*{%s}")
	  ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))
 '(org-latex-default-packages-alist
   '(("AUTO" "inputenc" t nil)
	 ("T1" "fontenc" t nil)
	 ("" "fixltx2e" nil nil)
	 ("margin=1in" "geometry" nil nil)
	 ("" "graphicx" t nil)
	 ("" "soul" nil nil)
	 ("" "longtable" nil nil)
	 ("" "float" nil nil)
	 ("" "wrapfig" nil nil)
	 ("" "rotating" nil nil)
	 ("" "amsmath" t nil)
	 ("" "textcomp" t nil)
	 ("" "marvosym" t nil)
	 ("" "wasysym" t nil)
	 ("" "amssymb" t nil)
	 ("" "hyperref" nil nil)
	 ("doublespacing" "setspace" nil nil)
	 "\\setlength{\\parskip}{1em}" "\\setlength{\\parindent}{4em}" "\\setcounter{secnumdepth}{0}" "\\usepackage{titlesec}" "\\titleformat*{\\section}{\\Large\\bfseries}" "\\titleformat*{\\subsection}{\\large\\bfseries}" "\\titleformat*{\\subsubsection}{\\bfseries}" "\\titleformat*{\\paragraph}{\\bfseries}" "\\titleformat*{\\subparagraph}{\\bfseries}" "\\titlespacing\\section{0pt}{-10pt}{-10pt}" "\\titlespacing\\subsection{0pt}{-10pt}{-10pt}" "\\titlespacing\\subsubsection{0pt}{-10pt}{-10pt}"))
 '(org-latex-hyperref-template nil)
 '(org-latex-pdf-process '("latexmk -cd -outdir=auto -pdf %f"))
 '(org-latex-text-markup-alist
   '((bold . "\\textbf{%s}")
	 (code . protectedtexttt)
	 (italic . "\\emph{%s}")
	 (strike-through . "\\sout{%s}")
	 (underline . "\\ul{%s}")
	 (verbatim . protectedtexttt)))
 '(org-latex-title-command "")
 '(org-special-ctrl-a/e t)
 '(package-selected-packages
   '(nix-mode doom-modeline yaml-mode notmuch sublimity general ivy-bibtex flyspell-correct-ivy magit helm-core origami mips-mode evil-collection evil-mu4e evil-colemak-basics smartparens visual-regexp-steroids railscasts-reloaded-theme railscasts-theme fish-mode evil-vimish-fold groovy-mode gradle-mode meghanada yasnippet-snippets rainbow-mode fvwm-mode counsel swiper markdown-mode markdown-preview-eww flymd hacker-typer color-theme-sanityinc-tomorrow ess apropospriate-theme pdf-tools ebib htmlize ox-twbs polymode f3 xwidgete badger-theme telephone-line base16-theme scheme-complete java-imports 2048-game gruvbox-theme slime-company slime geiser helm-helm-commands helm-mt helm-mu helm-themes helm-unicode smart-mode-line-powerline-theme smart-mode-line smart-comment aggressive-indent ample-theme avy benchmark-init comment-dwim-2 company company-auctex company-c-headers company-irony company-ghc company-tern dmenu evil evil-god-state expand-region fireplace flx flycheck flycheck-irony ghc haskell-mode haskell-snippets helm-bibtex helm-flx helm-flyspell helm-fuzzier helm-swoop highlight-escape-sequences highlight-numbers highlight-tail iedit irony js2-mode js2-refactor key-chord latex-preview-pane lua-mode magic-latex-buffer mingus mu4e-alert multi-term multiple-cursors neotree nyan-mode page-break-lines paredit perspective popwin region-bindings-mode skewer-mode smart-compile spaceline tern undo-tree use-package which-key whitespace-cleanup-mode xkcd yasnippet))
 '(pos-tip-background-color "#eee8d5" t)
 '(pos-tip-foreground-color "#586e75" t)
 '(powerline-default-separator nil)
 '(prescient-aggressive-file-save t)
 '(prescient-persist-mode t)
 '(prescient-sort-length-enable nil)
 '(rcirc-server-alist
   '(("unix.chat" :nick "spurious_sigpoll" :user-name "spurious_sigpoll" :password "gawk63writchophealraven" :channels
	  ("#nixers"))
	 ("irc.freenode.net" :nick "spurious_sigpoll" :user-name "spurious_sigpoll" :password "gawk63writchophealraven" :channels
	  ("#emacs"))))
 '(scroll-bar-mode nil)
 '(send-mail-function 'sendmail-send-it)
 '(sendmail-program "msmtp")
 '(sentence-end-double-space nil)
 '(show-paren-mode t)
 '(smart-compile-alist
   '((emacs-lisp-mode emacs-lisp-byte-compile)
	 (html-mode browse-url-of-buffer)
	 (nxhtml-mode browse-url-of-buffer)
	 (html-helper-mode browse-url-of-buffer)
	 (octave-mode run-octave)
	 ("\\.c\\'" . "gcc -std=c99 -O2 %f -lm -o %n")
	 ("\\.[Cc]+[Pp]*\\'" . "g++ -O2 %f -lm -o %n")
	 ("\\.m\\'" . "gcc -O2 %f -lobjc -lpthread -o %n")
	 ("\\.java\\'" . "javac %f")
	 ("\\.php\\'" . "php -l %f")
	 ("\\.f90\\'" . "gfortran %f -o %n")
	 ("\\.[Ff]\\'" . "gfortran %f -o %n")
	 ("\\.cron\\(tab\\)?\\'" . "crontab %f")
	 ("\\.tex\\'" tex-file)
	 ("\\.texi\\'" . "makeinfo %f")
	 ("\\.mp\\'" . "mptopdf %f")
	 ("\\.pl\\'" . "perl %f")
	 ("\\.rb\\'" . "ruby %f")))
 '(sml/col-number-format "%c")
 '(sml/extra-filler -1)
 '(sml/line-number-format "%l")
 '(sml/modified-char "*")
 '(sml/no-confirm-load-theme t)
 '(sml/pos-id-separator "")
 '(sml/read-only-char "%")
 '(sml/theme 'respectful)
 '(smtpmail-smtp-server "smtp.openmailbox.org")
 '(smtpmail-smtp-service 587)
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(vc-annotate-background nil)
 '(vc-annotate-very-old-color nil)
 '(vr/default-replace-preview nil)
 '(vr/engine 'python)
 '(vr/match-separator-use-custom-face t)
 '(yas-also-auto-indent-first-line t))

