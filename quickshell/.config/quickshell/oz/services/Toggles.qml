// The script-backed toggles: noise mode and keep awake. Each script keeps its
// own state, which is read back here after every change.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string hyprDir: `${Quickshell.env("HOME")}/dotfiles/hyprland/.config/hypr`
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")

    readonly property bool noiseDeep: noiseState.text().trim() === "deep"
    property bool keepAwake: false

    function refresh(): void {
        noiseState.reload();
        keepAwakeQuery.running = true;
    }

    function run(command: string): void {
        Quickshell.execDetached(["sh", "-c", command]);
        settle.restart();
    }

    function toggleNoise(): void {
        root.run("noise-mode toggle");
    }

    function toggleKeepAwake(): void {
        root.run(`${root.hyprDir}/keep-awake.sh`);
    }

    // The scripts finish after the call returns; read their state once they have.
    Timer {
        id: settle

        interval: 400

        onTriggered: root.refresh()
    }

    FileView {
        id: noiseState

        path: `${root.runtimeDir}/noise-mode`
        printErrors: false
    }

    Process {
        id: keepAwakeQuery

        command: ["systemctl", "--user", "is-active", "-q", "keep-awake"]

        onExited: code => root.keepAwake = code === 0
    }
}
