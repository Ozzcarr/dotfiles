// The internal panel's backlight, through brightnessctl. Desktops have none,
// so `available` stays false there.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: max > 0
    readonly property int percent: max > 0 ? Math.round(100 * current / max) : 0

    property int current: 0
    property int max: 0

    function refresh(): void {
        query.running = true;
    }

    function set(percent: int): void {
        apply.command = ["brightnessctl", "-c", "backlight", "-m", "set", `${Math.max(1, Math.min(100, percent))}%`];
        apply.running = true;
    }

    // brightnessctl -m prints "device,class,current,percent,max".
    function read(text: string): void {
        const fields = text.trim().split(",");
        if (fields.length < 5)
            return;
        root.current = Number(fields[2]);
        root.max = Number(fields[4]);
    }

    Process {
        id: query

        running: true
        command: ["brightnessctl", "-c", "backlight", "-m"]

        stdout: StdioCollector {
            onStreamFinished: root.read(text)
        }
    }

    Process {
        id: apply

        stdout: StdioCollector {
            onStreamFinished: root.read(text)
        }
    }
}
