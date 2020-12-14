#!/bin/bash
#xsetroot -xcf /nix/store/xvn47c6hgpy8mdiyz739aimdx2j7ghmj-adwaita-icon-theme-3.34.3/share/icons/Adwaita/cursors/left_ptr 48
# feh --bg-fill /home/rose/.background.jpg &
emacs --bg-daemon &
xrdb -merge ~/.Xresources
setxkbmap us -variant colemak
xmodmap -e "keycode 105 = Alt_R"
xmodmap -e "keycode 108 = Control_R"
xmodmap -e "add Control = Control_R"
battery-monitor &
picom -b
#xss-lock -l lock &
sleep 0.5
xcape -e 'Alt_L=Escape' &
xcape -e 'Control_R=Escape' &
polybar main &
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
# sh -c "feh --no-fehbg --bg-fill '/home/rose/.background.png')"
~/.fehbg
exec dbus-launch --exit-with-session /usr/bin/xmonad
