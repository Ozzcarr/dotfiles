//@ pragma ShellId oz
//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services as Services
import qs.surfaces.frame
import qs.surfaces.lock

ShellRoot {
    // Start the samplers at launch so the dashboard opens with history. A bare
    // reference to a singleton doesn't create it; reading a property does.
    readonly property var sampling: [Services.Sys.cpu, Services.Gpu.utilization]

    // Idle runs on its own: locking, screens off and lock before sleep.
    readonly property int idle: Services.Idle.lockAfter

    // The polkit agent registers for the session as soon as it exists.
    readonly property bool polkit: Services.Polkit.registered

    Variants {
        model: Quickshell.screens

        Frame {}
    }

    SessionLock {}

    IpcHandler {
        target: "shell"

        function reload(): void {
            Quickshell.reload(true);
        }
    }
}
