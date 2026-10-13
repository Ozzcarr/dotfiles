// Gaming bits (OBS replay buffer, gamemode) only exist on the desktop.
pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    readonly property string name: hostname.text().trim()
    readonly property bool gaming: name !== "laptop"

    FileView {
        id: hostname

        path: "/etc/hostname"
        blockLoading: true
    }
}
