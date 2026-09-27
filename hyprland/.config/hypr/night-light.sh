#!/usr/bin/env bash
# hyprsunset has no toggle of its own, so flip it on the presence of the process.
set -euo pipefail

here=$(dirname "$(readlink -f "$0")")

notify() {
  notify-send -h boolean:transient:true -i "$here/night-light-$1.svg" \
    "Night light" "$2"
}

if pgrep -x hyprsunset >/dev/null; then
  pkill -x hyprsunset
  notify off Disabled
else
  hyprsunset &
  notify on Enabled
fi
