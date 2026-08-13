#!/usr/bin/env bash
# Sets up a Vencord dev checkout with this list of userplugins cloned in.
# Vesktop is pointed at the resulting dist, so `pnpm watch` + Ctrl+R is the edit loop.
set -euo pipefail

VENCORD_DIR="${VENCORD_DIR:-$HOME/Vencord}"
STATE="$HOME/.config/vesktop/state.json"

PLUGIN_REPOS=(
    "Ozzcarr/vimNavigation"
)

if [ ! -d "$VENCORD_DIR" ]; then
    git clone --depth 1 https://github.com/Vendicated/Vencord.git "$VENCORD_DIR"
fi

mkdir -p "$VENCORD_DIR/src/userplugins"
for repo in "${PLUGIN_REPOS[@]}"; do
    name="$(basename "$repo")"
    dest="$VENCORD_DIR/src/userplugins/$name"
    if [ -d "$dest/.git" ]; then
        git -C "$dest" pull --ff-only
    else
        gh repo clone "$repo" "$dest"
    fi
done

cd "$VENCORD_DIR"
pnpm install --frozen-lockfile
pnpm build

# Vesktop treats a vencordDir without package.json as a broken install and
# redownloads the official Vencord release over it, silently dropping userplugins.
echo '{}' > dist/package.json

mkdir -p "$(dirname "$STATE")"
node -e '
const [file, dir] = process.argv.slice(1);
const fs = require("fs");
const state = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, "utf8")) : {};
state.vencordDir = dir;
fs.writeFileSync(file, JSON.stringify(state, null, 4) + "\n");
' "$STATE" "$VENCORD_DIR/dist"

echo
echo "Done. Restart Vesktop, then enable the plugins in Settings -> Plugins."
echo "Edit:  $VENCORD_DIR/src/userplugins/<plugin>/  (a real git repo, commit/push from there)"
echo "Watch: cd $VENCORD_DIR && pnpm watch   (then Ctrl+R in Vesktop)"
