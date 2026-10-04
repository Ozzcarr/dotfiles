#!/usr/bin/env bash
# Holds an idle inhibitor in its own unit, so stopping the unit releases it.
set -euo pipefail

notify() {
  notify-send -u low -h boolean:transient:true "Keep awake" "$1"
}

if systemctl --user is-active -q keep-awake; then
  systemctl --user stop keep-awake
  notify Disabled
else
  systemd-run --user -q --unit=keep-awake \
    systemd-inhibit --what=idle --who="Keep awake" --why=Manual sleep infinity
  notify Enabled
fi
