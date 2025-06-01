#!/bin/bash

get_battery_state() {
  upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | cut -d ":" -f2 | xargs
}

get_battery_percentage() {
  upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o "[0-9]*"
}

battery_state=$(get_battery_state)
battery_percentage=$(get_battery_percentage)

if [[ $battery_state == "discharging" && $battery_percentage -le 25 ]]; then
  dunstify -a "low-battery" -u critical -i battery-level-10-symbolic \
    -h string:x-dunst-stack-tag:battery -h int:value:"$battery_percentage" \
    "Battery: ${battery_percentage}%" "Please plug in your computer."
  canberra-gtk-play -i battery-low -d "low-battery"
fi
