pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Number of processes holding gamemode on; the NixOS config registers
    // every fullscreen window as one.
    property int clients: 0
    readonly property bool active: clients > 0

    Process {
        id: query

        command: ["busctl", "--user", "get-property", "com.feralinteractive.GameMode", "/com/feralinteractive/GameMode", "com.feralinteractive.GameMode", "ClientCount"]

        // Prints "i <count>"; prints nothing when gamemode isn't installed.
        stdout: StdioCollector {
            onStreamFinished: root.clients = Number(text.trim().split(" ")[1]) || 0
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: query.running = true
    }
}
