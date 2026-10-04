pragma Singleton

import Quickshell

Singleton {
    readonly property list<string> left: ["workspaces"]
    readonly property list<string> center: ["clock"]
    readonly property list<string> right: ["tray", "status", "session"]
}
