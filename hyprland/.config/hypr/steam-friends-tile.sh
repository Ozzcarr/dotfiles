#!/usr/bin/env bash
# Keep Steam's friends list tiled to the left of the main Steam window at a
# fixed width. Hyprland window rules can't size or place *tiled* windows
# (size/move only apply to floating ones), so react to events instead.

WIDTH=${1:-420}
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

fixup() {
  local clients friends ws tiled visible state prev batch
  clients=$(hyprctl clients -j) || return

  friends=$(jq -r '[.[] | select(.class == "steam" and .initialTitle == "Friends List" and .floating == false)][0].address // empty' <<<"$clients")
  [ -n "$friends" ] || return
  ws=$(jq -r --arg a "$friends" '.[] | select(.address == $a) | .workspace.name' <<<"$clients")

  # Nothing to place it next to yet.
  tiled=$(jq --arg ws "$ws" '[.[] | select(.workspace.name == $ws and .floating == false)] | length' <<<"$clients")
  [ "$tiled" -ge 2 ] || return

  # focuswindow would drag a hidden (special) workspace into view.
  visible=$(hyprctl monitors -j | jq -r --arg ws "$ws" 'any(.[]; .activeWorkspace.name == $ws or .specialWorkspace.name == $ws)')
  [ "$visible" = "true" ] || return

  # "swapwindow l" happily reaches onto the monitor to the left, so only ask for
  # it when there really is a neighbour to swap with on this workspace.
  state=$(jq -r --arg ws "$ws" --arg a "$friends" --argjson w "$WIDTH" '
    [.[] | select(.workspace.name == $ws and .floating == false)] as $tiled
    | ($tiled[] | select(.address == $a)) as $f
    | (if any($tiled[]; .address != $a and .at[0] < $f.at[0]) then "swap" else "keep" end)
      + " " + (if $f.size[0] == $w then "sized" else "resize" end)' <<<"$clients")

  [ "$state" = "keep sized" ] && return

  batch="dispatch focuswindow address:$friends"
  [ "${state% *}" = "swap" ] && batch="$batch ; dispatch swapwindow l"
  [ "${state#* }" = "resize" ] && batch="$batch ; dispatch resizeactive exact $WIDTH 100%"

  prev=$(hyprctl activewindow -j | jq -r '.address // empty')
  hyprctl --batch "$batch" >/dev/null
  if [ -n "$prev" ] && [ "$prev" != "$friends" ]; then
    hyprctl dispatch focuswindow "address:$prev" >/dev/null
  fi
}

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
  case "$line" in
    'openwindow>>'*',steam,'*|'activespecial>>'*)
      sleep 0.15
      fixup
      ;;
  esac
done
