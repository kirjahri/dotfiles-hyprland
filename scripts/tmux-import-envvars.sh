#/bin/bash

# This script was (mostly) "borrowed" from GitHub user memchr

# Wait until Hyprland is running to continue the script
while true; do
  if [[ -v HYPRLAND_INSTANCE_SIGNATURE ]]; then
    break
  else
    sleep .001
  fi
done

variables=(
  WAYLAND_DISPLAY
  DISPLAY
  USERNAME
  XDG_BACKEND
  XDG_CURRENT_DESKTOP
  XDG_SESSION_TYPE
  XDG_SESSION_ID
  XDG_SESSION_CLASS
  XDG_SESSION_DESKTOP
  XDG_SEAT
  XDG_VTNR
  HYPRLAND_CMD
  HYPRLAND_INSTANCE_SIGNATURE
  SWAYSOCK
  XCURSOR_SIZE
  _JAVA_AWT_WM_NONREPARENTING
  QT_QPA_PLATFORM
  QT_WAYLAND_DISABLE_WINDOWDECORATION
  GRIM_DEFAULT_DIR
  SSH_AUTH_SOCK
)

for v in ${variables[@]}; do
  if [[ -n ${!v} ]]; then
    tmux setenv -g $v ${!v}
  fi
done
