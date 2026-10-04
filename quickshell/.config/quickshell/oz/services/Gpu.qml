// NVIDIA only. Without nvidia-smi `available` stays false and the dashboard
// hides the row.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: utilization >= 0

    property int utilization: -1
    property int temperature: 0
    property var history: []

    Process {
        id: query

        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                const [utilization, temperature] = text.trim().split(",").map(Number);
                if (isNaN(utilization))
                    return;

                root.utilization = utilization;
                root.temperature = temperature;
                root.history = [...root.history.slice(1 - Sys.historyLength), utilization];
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: query.running = true
    }
}
