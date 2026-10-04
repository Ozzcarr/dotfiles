pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var status: null

    readonly property bool failed: !!status?.error
    readonly property int count: (status?.packages?.length ?? 0) + (status?.added?.length ?? 0)

    function parse(): void {
        try {
            root.status = JSON.parse(cache.text());
        } catch (e) {
            root.status = null;
        }
    }

    function check(): void {
        Quickshell.execDetached(["systemctl", "--user", "start", "nix-update-check.service"]);
    }

    FileView {
        id: cache

        path: `${Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache"}/nix-update/status.json`
        blockLoading: true
        watchChanges: true
        printErrors: false

        onFileChanged: {
            reload();
            root.parse();
        }

        Component.onCompleted: root.parse()
    }
}
