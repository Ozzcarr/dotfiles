//@ pragma ShellId oz
//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services as Services
import qs.surfaces.frame

ShellRoot {
    // Start the samplers at launch so the dashboard opens with history. A bare
    // reference to a singleton doesn't create it; reading a property does.
    readonly property var sampling: [Services.Sys.cpu, Services.Gpu.utilization]

    Variants {
        model: Quickshell.screens

        Frame {}
    }

    IpcHandler {
        target: "shell"

        function reload(): void {
            Quickshell.reload(true);
        }
    }
}
