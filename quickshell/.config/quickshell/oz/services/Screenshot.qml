// Screenshots. Every screen is frozen first, so what you pick from is exactly
// what gets saved, menus and hover states included. Drag for a region, click
// for the window under the cursor, or the whole screen where there is none.
// The shot is saved, copied, and announced with actions to open or edit it;
// "edit" opens swappy straight away instead.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property string saveDir: `${Quickshell.env("HOME")}/Pictures/Screenshots`

    // True while the overlays are up; "save" or "edit".
    property bool active: false
    property string mode: "save"
    property string stamp: ""
    // The screen that takes the keyboard: where the cursor was.
    property string focusedScreen: ""

    // Windows on the visible workspaces, frontmost first, in global
    // coordinates: [{ x, y, width, height }].
    property var windows: []
    // Monitor name → scale, to crop the physical-pixel frozen images.
    property var scales: ({})

    function frozen(screen: string): string {
        return `${root.runtimeDir}/oz-screenshot-${screen}-${root.stamp}.png`;
    }

    function start(mode: string): void {
        if (root.active || freezer.running)
            return;
        Panels.close();
        root.mode = mode;
        root.focusedScreen = Panels.focusedScreen;
        root.stamp = String(Date.now());
        freezer.command = ["sh", "-c", `
            stamp=$1; shift
            for o in "$@"; do grim -l 0 -o "$o" "$XDG_RUNTIME_DIR/oz-screenshot-$o-$stamp.png" & done
            wait
            printf '{"clients":%s,"monitors":%s}' "$(hyprctl -j clients)" "$(hyprctl -j monitors)"`, "sh", root.stamp, ...Quickshell.screens.map(s => s.name)];
        freezer.running = true;
    }

    function cancel(): void {
        root.active = false;
        root.cleanup();
    }

    // `rect` is in the screen's own logical coordinates.
    function capture(screen: string, rect: rect): void {
        const scale = root.scales[screen] ?? 1;
        const crop = `${Math.round(rect.width * scale)}x${Math.round(rect.height * scale)}+${Math.round(rect.x * scale)}+${Math.round(rect.y * scale)}`;
        const out = `${root.saveDir}/Screenshot_${Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss")}.png`;
        root.active = false;

        Quickshell.execDetached(["sh", "-c", `
            frozen=$1 crop=$2 out=$3 mode=$4
            mkdir -p "$(dirname "$out")"
            magick "$frozen" -crop "$crop" +repage "$out"
            status=$?
            rm -f "$XDG_RUNTIME_DIR"/oz-screenshot-*.png
            if [ $status -ne 0 ]; then
                notify-send -a Screenshot -u critical "Screenshot failed" "Couldn't crop the frozen screen"
                exit 1
            fi
            wl-copy --type image/png < "$out"
            if [ "$mode" = edit ]; then exec swappy -f "$out"; fi
            action=$(notify-send -a Screenshot -i camera-photo -h "string:image-path:$out" \\
                -A open=Open -A edit=Edit "Screenshot saved" "Copied to the clipboard")
            case $action in
                open) xdg-open "$out" ;;
                edit) swappy -f "$out" ;;
            esac`, "sh", root.frozen(screen), crop, out, root.mode]);
    }

    function cleanup(): void {
        Quickshell.execDetached(["sh", "-c", 'rm -f "$XDG_RUNTIME_DIR"/oz-screenshot-*.png']);
    }

    Process {
        id: freezer

        stdout: StdioCollector {
            onStreamFinished: {
                let state;
                try {
                    state = JSON.parse(text);
                } catch (e) {
                    root.cleanup();
                    return;
                }

                const shown = [];
                for (const m of state.monitors)
                    shown.push(m.activeWorkspace.id, m.specialWorkspace.id);
                // Special workspaces, then floating windows, draw above the rest.
                const layer = c => (c.workspace.id < 0 ? 0 : 2) + (c.floating ? 0 : 1);
                root.windows = state.clients.filter(c => c.mapped && !c.hidden && shown.includes(c.workspace.id)).sort((a, b) => layer(a) - layer(b) || a.focusHistoryID - b.focusHistoryID).map(c => ({
                            x: c.at[0],
                            y: c.at[1],
                            width: c.size[0],
                            height: c.size[1]
                        }));
                const scales = {};
                for (const m of state.monitors)
                    scales[m.name] = m.scale;
                root.scales = scales;
                root.active = true;
            }
        }
    }

    IpcHandler {
        target: "screenshot"

        function region(): void {
            root.start("save");
        }

        function edit(): void {
            root.start("edit");
        }
    }
}
