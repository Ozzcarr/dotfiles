// OBS's replay buffer, through the obs-replay script. OBS keeps the length in
// its profile, so it is read back rather than remembered here.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int minLength: 15
    readonly property int maxLength: 600

    // False while OBS or its websocket is down.
    property bool available: false
    property bool active: false
    property int length: 0

    function refresh(): void {
        status.running = true;
    }

    function toggle(): void {
        root.run(["obs-replay", "toggle"]);
    }

    function setLength(seconds: int): void {
        root.length = Math.max(root.minLength, Math.min(root.maxLength, seconds));
        debounce.restart();
    }

    function run(command: var): void {
        action.command = command;
        action.running = true;
    }

    // Restarting the buffer on every slider step would throw away the replay.
    Timer {
        id: debounce

        interval: 600

        onTriggered: root.run(["obs-replay", "length", String(root.length)])
    }

    Process {
        id: action

        onExited: root.refresh()
    }

    Process {
        id: status

        command: ["obs-replay", "status"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const state = JSON.parse(text);
                    root.active = state.active;
                    if (!debounce.running)
                        root.length = state.length;
                    root.available = true;
                } catch (e) {
                    root.available = false;
                    root.active = false;
                }
            }
        }
    }
}
