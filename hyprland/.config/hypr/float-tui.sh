#!/usr/bin/env bash
# Launches $2 in a floating kitty window titled $1, sized to 70% of whatever
# monitor it opens on. Hyprland's percentage windowrules don't reliably apply
# to kitty's own initial size request, so size/position are asserted directly
# via dispatch after the window maps.
set -euo pipefail

title="$1"
shift

kitty --title "$title" -e "$@" &

for _ in $(seq 1 20); do
  sleep 0.05
  win_json=$(hyprctl clients -j | jq -r --arg t "$title" '[.[] | select(.title == $t)][0]')
  [ "$win_json" != "null" ] && break
done

mon_id=$(echo "$win_json" | jq -r '.monitor')
# width/height are reported pre-rotation; swap them for 90/270 degree transforms
# (odd transform values) so a rotated (portrait) monitor sizes correctly.
read -r mon_w mon_h < <(hyprctl monitors -j | jq -r --argjson m "$mon_id" '
  .[] | select(.id == $m) |
  if (.transform % 2) == 1 then "\(.height) \(.width)" else "\(.width) \(.height)" end
')

new_w=$(( mon_w * 70 / 100 ))
new_h=$(( mon_h * 70 / 100 ))

hyprctl dispatch resizewindowpixel exact "$new_w" "$new_h",title:"$title"
hyprctl dispatch centerwindow
