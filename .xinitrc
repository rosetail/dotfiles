# #!/bin/bash
# # feh --bg-fill /home/rose/.background.jpg &
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
xrdb -merge ~/.Xresources
emacs --bg-daemon &
xsetroot -cursor_name left_ptr
unclutter --timeout 1 -b --ignore-scrolling
setxkbmap us -variant colemak
xmodmap -e "keycode 105 = Alt_R"
xmodmap -e "keycode 108 = Control_R"
xmodmap -e "add Control = Control_R"
battery-monitor &
picom -b
#xss-lock -l lock &
# sleep 0.5
xcape -e 'Alt_L=Escape' &
xcape -e 'Control_R=Escape' &
polybar main &
# sh -c "feh --no-fehbg --bg-fill '/home/rose/.background.png')"
~/.fehbg
exec dbus-launch --exit-with-session /usr/bin/xmonad
