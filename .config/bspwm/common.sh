#!/bin/bash

ROOT=$(dirname $0)

# This script setups the commonly options
# using bspc to affect bspwm

function setopt () {
  local opt=$1
  local val=$2
  bspc config "$opt" "$val"
}

# borders and gaps
setopt border_width 0
setopt window_gap 12

# behaviour stuff
setopt split_ratio 0.52
setopt borderless_monocle true
setopt gapless_monocle true
setopt single_monocle true

# pointer
setopt focus_follows_pointer true
setopt pointer_follows_focus true
setopt pointer_follows_monitor true

# plank
bspc rule -a Plank layer=above manage=on border=off
