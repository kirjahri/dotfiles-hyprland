#!/bin/bash

get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

get_mute() {
  pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

send_volume_notification() {
  volume=$(get_volume)
  mute=$(get_mute)

  if [[ $mute == "yes" ]]; then
    dunstify -a "change-volume" -u low -i audio-volume-muted-symbolic \
      -h string:x-dunst-stack-tag:volume -h int:value:"$volume" -t 2000 \
      "Volume: Mute"
  else
    dunstify -a "change-volume" -u low -i audio-volume-high-symbolic \
      -h string:x-dunst-stack-tag:volume -h int:value:"$volume" -t 2000 \
      "Volume: ${volume}%"
  fi

  canberra-gtk-play -i audio-volume-change -d "change-volume"
}

case $1 in
  --volume-up)
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
    send_volume_notification
    ;;
  --volume-down)
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
    send_volume_notification
    ;;
  --volume-mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    send_volume_notification
    ;;
esac
