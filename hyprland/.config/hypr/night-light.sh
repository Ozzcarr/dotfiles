#!/usr/bin/env bash
# Toggles through hyprsunset's socket instead of restarting it: a restart
# reconnects and reapplies the color matrix, which stalls games. The schedule
# in hyprsunset.conf still applies at its set times.
set -euo pipefail

# hyprsunset reports its temperature even under identity, so the on/off state
# is kept here.
state="${XDG_RUNTIME_DIR:-/tmp}/night-light"

if ! pgrep -x hyprsunset >/dev/null; then
  hyprsunset >/dev/null 2>&1 &
  disown
  for _ in $(seq 1 20); do
    hyprctl hyprsunset temperature >/dev/null 2>&1 && break
    sleep 0.05
  done
fi

# Before the first toggle, assume whatever the schedule applies right now.
if [ ! -f "$state" ]; then
  hour=$((10#$(date +%H)))
  if [ "$hour" -ge 21 ] || [ "$hour" -lt 7 ]; then echo on; else echo off; fi >"$state"
fi

if [ "$(cat "$state")" = on ]; then
  hyprctl hyprsunset identity >/dev/null
  hyprctl hyprsunset gamma 100 >/dev/null
  echo off >"$state"
  qs -c oz ipc call osd flash light_mode "Night light off"
else
  hyprctl hyprsunset temperature 4000 >/dev/null
  hyprctl hyprsunset gamma 90 >/dev/null
  echo on >"$state"
  qs -c oz ipc call osd flash nightlight "Night light on"
fi
