#!/bin/bash

# This is a script to autostart some applications like picom
# or merge some Xresources or change the wallpaper, or in This
# case is necesary to start sxhkd

#  NOTE: This is an example file, you can change it with your stuff

xsetroot -cursor_name left_ptr
picom -b

# notification manager (I include configuration for dunst)
dunst &

# Wallpaper
feh --bg-fill $HOME/.config/wallpapers/aquarium.png

# don't remove this please
sxhkd &

# generate the updates
bash $HOME/.config/bspwm/scripts/gen-updates.sh &

# notify-send "Welcome Lord $USER"
