eval (dircolors -c ~/.dircolors)
# direnv hook fish | source

set -x fish_color_autosuggestion brblack
set -x fish_color_command brgreen
set -x fish_color_comment black
set -x fish_color_cwd brmagenta
set -x fish_color_cwd_root brred
set -x fish_color_end bryellow
set -x fish_color_error brred
set -x fish_color_escape bryellow
set -x fish_color_history_current \x2d\x2dbold
set -x fish_color_host normal
set -x fish_color_match \x2d\x2dbackground\x3dblue
set -x fish_color_normal normal
set -x fish_color_operator yellow
set -x fish_color_param brblue
set -x fish_color_quote brgreen
set -x fish_color_redirection bryellow
set -x fish_color_search_match bryellow\x1e\x2d\x2dbackground\x3dblack
set -x fish_color_selection white\x1e\x2d\x2dbold\x1e\x2d\x2dbackground\x3dblack
set -x fish_color_status brred
set -x fish_color_user green
set -x fish_color_valid_path brgreen
set -x fish_greeting
set -x fish_key_bindings fish_default_key_bindings
set -x fish_pager_color_completion \x1d
set -x fish_pager_color_description brgreen
set -x fish_pager_color_prefix white\x1e\x2d\x2dbold\x1e\x2d\x2dunderline
set -x fish_pager_color_progress brblack

set -x LESS_TERMCAP_mb (set_color magenta)
set -x LESS_TERMCAP_md (set_color --bold blue)
set -x LESS_TERMCAP_me (set_color normal)
set -x LESS_TERMCAP_se (set_color normal)
set -x LESS_TERMCAP_so (set_color -r)
set -x LESS_TERMCAP_ue (set_color normal)
set -x LESS_TERMCAP_us (set_color green)

set -x BORG_REMOTE_PATH "/share/homes/rose/bin/borg"
set -x _JAVA_OPTIONS "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel" $_Java_OPTIONS
set -x _JAVA_AWT_WM_NONREPARENTING "true"
set -x COLORTERM "truecolor"
set -x PATH ~/bin $PATH
set -x BROWSER "qutebrowser"
set -x EDITOR "em"
set -x GPG_TTY (tty)

alias ee 'emacsclient -a emacs $PWD'
alias mountdisk 'udisksctl mount -b'
alias umountdisk 'udisksctl unmount -b'
alias cat 'bat'

# if not set -q $stdenv
#	echo "stdenv set"
#	# source $stdenv/setup
# end

function ls
	command ls --color=auto -N $argv
end

function l
	command ls --color=auto -N $argv
end

function ll
	command ls --color=auto -lhN $argv
end

function la --description 'alias ll ls -A'
	command ls --color=auto -AN $argv
end

function lla --description 'alias ll ls -lhA'
	command ls --color=auto -lhAN $argv
end

function fish_prompt --description 'Write out the prompt'
	if test -z $WINDOW
		# printf '%s%s%s@%s%s %s%s%s ❯ ' (set_color --bold green) (whoami) (set_color normal) (set_color brblue) (hostname|cut -d . -f 1) (set_color $fish_color_cwd) (prompt_pwd) (set_color brblack)
		printf '%s%s%s >%s ' (set_color --bold magenta) (prompt_pwd) (set_color brblack) (set_color normal)
	else
   printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color yellow) (whoami) (set_color purple) (hostname|cut -d . -f 1) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
 end
end
function fish_prompt; end

function fish_mode_prompt --description 'Displays the current mode'
	# Do nothing if not in vi mode
	# if set -q __fish_vi_key_bindings
	switch $fish_bind_mode
		case default
			set_color --bold blue
			echo (prompt_pwd)
		case insert
			set_color --bold magenta
			echo (prompt_pwd)
		case visual
			set_color --bold green
			echo (prompt_pwd)
		case replace_one
			set_color --bold yellow
			echo (prompt_pwd)
	end
	set_color brblack
	echo " >"
	set_color normal
	echo -n ' '
	# end
end

function hybrid_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
	for mode in default insert visual
		fish_default_key_bindings -M $mode
	end
	fish_vi_key_bindings --no-erase
	bind e up-or-search
	bind n down-or-search
	bind -M default i forward-char
	bind -M visual i forward-char
	bind -m insert u force-repaint
	bind -m insert U beginning-of-line force-repaint
	bind f forward-char forward-word backward-char
	bind f forward-bigword backward-char
	bind N end-of-line delete-char

	bind t forward-jump
	bind T backward-jump
	bind j forward-jump and backward-char
	bind J backward-jump and forward-char

	bind -M insert \ce up-or-search
	bind -M insert \ct end-of-line

end
set -g fish_key_bindings hybrid_bindings
