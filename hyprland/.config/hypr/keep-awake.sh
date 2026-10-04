#!/usr/bin/env bash
# Holds an idle inhibitor in its own unit, so stopping the unit releases it.
set -euo pipefail

if systemctl --user is-active -q keep-awake; then
  systemctl --user stop keep-awake
  qs -c oz ipc call osd flash bedtime "Keep awake off"
else
  systemd-run --user -q --unit=keep-awake \
    systemd-inhibit --what=idle --who="Keep awake" --why=Manual sleep infinity
  qs -c oz ipc call osd flash coffee "Keep awake on"
fi
