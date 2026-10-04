// Every Hyprland bind that has a description, so binds.lua is the only source.
import QtQuick
import Quickshell.Io

Mode {
    id: root

    property var binds: []

    name: "binds"
    prefix: "?"
    short: "keys"
    label: "Keybinds"
    icon: "keyboard"
    placeholder: "Search keybinds"

    results: Launcher.rank(root.binds.map((bind, i) => ({
                    key: `bind:${i}`,
                    title: bind.description,
                    hint: bind.keys,
                    glyph: "keyboard",
                    keepOpen: true,
                    run: () => {}
                })), [["title", 1], ["hint", 0.8]])

    onOpened: query.running = true

    // Hyprland's modmask bits, in the order binds are written.
    function format(bind: var): string {
        const mods = [[64, "Super"], [8, "Alt"], [4, "Ctrl"], [1, "Shift"]].filter(([bit]) => bind.modmask & bit).map(([, name]) => name);
        const key = bind.key || `code:${bind.keycode}`;
        return [...mods, key.length === 1 ? key.toUpperCase() : key].join(" + ");
    }

    Process {
        id: query

        command: ["hyprctl", "binds", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.binds = JSON.parse(text).filter(bind => bind.has_description).map(bind => ({
                                description: bind.description,
                                keys: root.format(bind)
                            }));
                } catch (e) {
                    root.binds = [];
                }
            }
        }
    }
}
