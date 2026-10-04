// CPU and memory, sampled from /proc.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Samples kept for the dashboard graphs, shared with Gpu.
    readonly property int historyLength: 40

    property int cpu: 0
    property var cpuHistory: []

    property int memory: 0
    property int memoryUsedMib: 0
    property int memoryTotalMib: 0
    property var memoryHistory: []

    // CPU usage is a difference between samples, so the first only primes these.
    property real previousBusy: -1
    property real previousTotal: -1

    function sampleCpu(): void {
        const line = statFile.text().split("\n")[0];
        if (!line.startsWith("cpu "))
            return;

        const fields = line.trim().split(/\s+/).slice(1).map(Number);
        const total = fields.reduce((a, b) => a + b, 0);
        const busy = total - fields[3] - fields[4]; // minus idle and iowait

        if (root.previousTotal >= 0 && total > root.previousTotal) {
            root.cpu = Math.round(100 * (busy - root.previousBusy) / (total - root.previousTotal));
            root.cpuHistory = [...root.cpuHistory.slice(1 - root.historyLength), root.cpu];
        }

        root.previousTotal = total;
        root.previousBusy = busy;
    }

    function sampleMemory(): void {
        const kib = {};
        for (const line of memFile.text().split("\n")) {
            const match = /^(\w+):\s+(\d+)/.exec(line);
            if (match)
                kib[match[1]] = Number(match[2]);
        }

        if (!kib.MemTotal)
            return;

        const used = kib.MemTotal - kib.MemAvailable;
        root.memoryTotalMib = Math.round(kib.MemTotal / 1024);
        root.memoryUsedMib = Math.round(used / 1024);
        root.memory = Math.round(100 * used / kib.MemTotal);
        root.memoryHistory = [...root.memoryHistory.slice(1 - root.historyLength), root.memory];
    }

    FileView {
        id: statFile

        path: "/proc/stat"
        blockLoading: true
    }

    FileView {
        id: memFile

        path: "/proc/meminfo"
        blockLoading: true
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            statFile.reload();
            root.sampleCpu();

            memFile.reload();
            root.sampleMemory();
        }
    }
}
