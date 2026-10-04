// The wallpaper script calls `qs -c oz ipc call wallpaper changed`. The symlink
// isn't watched: it gets replaced rather than written, which watchers miss.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.generated

Singleton {
    id: root

    property string path: ""

    // Falls back to the scheme when the wallpaper has nothing vivid.
    readonly property color accent: picked.length > 0 ? picked[0] : Scheme.base0E
    readonly property color accentAlt: picked.length > 1 ? picked[1] : Scheme.base0D

    property list<color> picked: []

    function refresh(): void {
        resolve.running = true;
    }

    // Two vivid colors with distinct hues, brightened for the dark frame. A
    // single-hue wallpaper gets a light-to-deep gradient of that hue.
    function pick(colors: list<color>): void {
        const vivid = [...colors].filter(c => c.hslSaturation > 0.25 && c.hslLightness > 0.15 && c.hslLightness < 0.9).sort((a, b) => score(b) - score(a));

        if (vivid.length === 0) {
            root.picked = [];
            return;
        }

        const first = lift(vivid[0]);
        const other = vivid.find(c => hueDistance(c, vivid[0]) > 0.08);
        const second = other ? lift(other) : Qt.hsla(first.hslHue, first.hslSaturation, first.hslLightness - 0.14, 1);

        root.picked = [first, second];
    }

    function score(c: color): real {
        return c.hslSaturation * (1 - Math.abs(c.hslLightness - 0.55) * 1.4);
    }

    function hueDistance(a: color, b: color): real {
        const d = Math.abs(a.hslHue - b.hslHue);
        return Math.min(d, 1 - d);
    }

    function lift(c: color): color {
        return Qt.hsla(c.hslHue, Math.max(c.hslSaturation, 0.55), Math.min(Math.max(c.hslLightness, 0.68), 0.82), 1);
    }

    function hex(c: color): string {
        return c.toString().slice(1, 7);
    }

    function pushAccent(): void {
        const lua = `hl.config({ general = { col = { active_border = { colors = { "rgb(${hex(accent)})", "rgb(${hex(accentAlt)})" }, angle = 45 } } } })`;
        Quickshell.execDetached(["hyprctl", "eval", lua]);

        // Read by firefox/chrome/JS/wallpaper-accent.sys.mjs.
        accentFile.setText(JSON.stringify({
            replace: Scheme.base0E.toString(),
            accent: accent.toString(),
            accentAlt: accentAlt.toString()
        }));
    }

    // Coalesced: pushing on each change raced two hyprctl calls.
    onAccentChanged: Qt.callLater(pushAccent)
    onAccentAltChanged: Qt.callLater(pushAccent)

    Component.onCompleted: refresh()

    // The quantizer needs the real path; the symlink path never changes.
    Process {
        id: resolve

        command: ["readlink", "-f", `${Quickshell.env("HOME")}/.cache/current-wallpaper`]

        stdout: StdioCollector {
            onStreamFinished: root.path = text.trim()
        }
    }

    ColorQuantizer {
        source: root.path ? `file://${root.path}` : ""
        depth: 3
        rescaleSize: 128

        onColorsChanged: root.pick(colors)
    }

    // A config reload resets the border to the static colors.
    Connections {
        target: Hyprland

        function onRawEvent(event): void {
            if (event.name === "configreloaded")
                root.pushAccent();
        }
    }

    FileView {
        id: accentFile

        path: `${Quickshell.env("HOME")}/.cache/oz-accent.json`
        atomicWrites: true
        printErrors: false
    }

    IpcHandler {
        target: "wallpaper"

        function changed(): void {
            root.refresh();
        }
    }
}
