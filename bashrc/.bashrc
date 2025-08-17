export PATH="$HOME/.tmuxifier/bin:$PATH"

nopad() {
  local sock="$KITTY_LISTEN_ON"
  if [[ -z "$sock" ]]; then
    # fallback: try to detect socket if not in env
    sock=$(kitty @ ls 2>/dev/null | grep -o 'unix:[^"]*' | head -n1)
  fi

  kitty @ set-spacing padding=0
  "$@"
  kitty @ set-spacing padding=default
}

nvim() { nopad command nvim "$@"; }
yazi() { nopad command yazi "$@"; }

eval "$(tmuxifier init -)"
eval "$(starship init bash)"

alias term='basename "$(cat "/proc/$PPID/comm")"'

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

. "$HOME/.local/share/../bin/env"
