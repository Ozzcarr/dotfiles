#!/usr/bin/env bash
# Sets up a Vencord dev checkout that builds the userplugins in this directory.
# Vesktop is pointed at the resulting dist, so `pnpm watch` + Ctrl+R is the edit loop.
set -euo pipefail

VENCORD_DIR="${VENCORD_DIR:-$HOME/Vencord}"
PLUGIN_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.config/vesktop/state.json"

if [ ! -d "$VENCORD_DIR" ]; then
    git clone --depth 1 https://github.com/Vendicated/Vencord.git "$VENCORD_DIR"
fi

mkdir -p "$VENCORD_DIR/src/userplugins"
for plugin in "$PLUGIN_SRC"/*/; do
    name="$(basename "$plugin")"
    ln -sfn "${plugin%/}" "$VENCORD_DIR/src/userplugins/$name"
done

cd "$VENCORD_DIR"
pnpm install --frozen-lockfile
pnpm build

# Vesktop treats a vencordDir without package.json as a broken install and
# redownloads the official Vencord release over it, silently dropping userplugins.
echo '{}' > dist/package.json

if [ -f "$STATE" ]; then
    tmp="$(mktemp)"
    jq --arg dir "$VENCORD_DIR/dist" '.vencordDir = $dir' "$STATE" > "$tmp" && mv "$tmp" "$STATE"
else
    mkdir -p "$(dirname "$STATE")"
    printf '{\n    "vencordDir": "%s"\n}\n' "$VENCORD_DIR/dist" > "$STATE"
fi

echo
echo "Done. Restart Vesktop, then enable the plugins in Settings -> Plugins."
echo "Edit loop:  cd $VENCORD_DIR && pnpm watch   (then Ctrl+R in Vesktop)"
