// EasyEffects' noise removal preset, switched by the noise-mode script, which
// keeps the current preset in the runtime dir.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool deep: state.text().trim() === "deep"

    function refresh(): void {
        state.reload();
    }

    function toggle(): void {
        Quickshell.execDetached(["noise-mode", "toggle"]);
        settle.restart();
    }

    // The script finishes after the call returns; read its state once it has.
    Timer {
        id: settle

        interval: 400

        onTriggered: root.refresh()
    }

    FileView {
        id: state

        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/noise-mode`
        printErrors: false
    }
}
