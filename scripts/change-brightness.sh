#!/bin/bash

get_brightness() {
  declare -i current_brightness
  current_brightness=$(brightnessctl g)
  max_brightness=$(brightnessctl m)
  current_brightness=$(( current_brightness * 100 ))
  echo $(( current_brightness / max_brightness ))
}

send_brightness_notification() {
  brightness=$(get_brightness)

  dunstify -a "change-brightness" -u low -i display-brightness-symbolic \
    -h string:x-dunst-stack-tag:brightness -h int:value:"$brightness" -t 2000 \
    "Brightness: ${brightness}%"
}

case $1 in
  --brightness-up)
    brightnessctl s 5%+
    send_brightness_notification
    ;;
  --brightness-down)
    brightnessctl s 5%-
    send_brightness_notification
    ;;
esac
