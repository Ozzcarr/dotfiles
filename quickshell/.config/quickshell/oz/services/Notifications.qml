// Read from swaync until the shell has its own notification daemon.
pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasNotifications: false
    property bool dnd: false

    Process {
        running: true
        command: ["swaync-client", "-swb"]

        // Each line is JSON whose "alt" reads like "dnd-notification".
        stdout: SplitParser {
            onRead: data => {
                try {
                    const alt = JSON.parse(data).alt ?? "";
                    root.hasNotifications = alt.includes("notification");
                    root.dnd = alt.startsWith("dnd");
                } catch (e) {}
            }
        }
    }
}
