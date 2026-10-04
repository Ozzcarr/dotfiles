// The laptop battery, and a notification at each low threshold while it
// drains. Desktops have none, so `present` stays false and nothing fires.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device?.isLaptopBattery ?? false
    readonly property int charge: Math.round((device?.percentage ?? 0) * 100)
    readonly property bool draining: present && UPower.onBattery

    // [percent, urgency, message], lowest last.
    readonly property var thresholds: [[15, "normal", "Battery low"], [5, "critical", "Battery almost empty, plug in now"]]

    // The lowest threshold already warned about in this discharge.
    property int warned: 101

    function check(): void {
        if (!root.draining)
            return;

        for (const [percent, urgency, message] of root.thresholds) {
            if (root.charge <= percent && root.warned > percent) {
                root.warned = percent;
                Quickshell.execDetached(["notify-send", "-u", urgency, "-a", "Battery", message, `${root.charge}% left`]);
            }
        }
    }

    onChargeChanged: root.check()
    onDrainingChanged: {
        if (!root.draining)
            root.warned = 101;
        root.check();
    }
}
