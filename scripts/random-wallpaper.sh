#!/bin/bash

# Wait until hyprpaper is running to continue the script
while true; do
  if hyprctl hyprpaper listactive &> /dev/null; then
    break
  else
    sleep .001
  fi
done

WALLPAPER_DIR=~/dotfiles-hyprland/wallpapers
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

# Find a wallpaper that is not the current one
WALLPAPER=$(find $WALLPAPER_DIR -type f ! -name "$(basename $CURRENT_WALL)" | shuf -n 1)

# Apply the wallpaper to all monitors
hyprctl hyprpaper reload , $WALLPAPER
