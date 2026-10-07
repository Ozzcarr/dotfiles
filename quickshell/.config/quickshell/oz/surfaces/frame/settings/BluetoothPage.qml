// Paired devices first, then whatever a scan finds.
import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.config

ColumnLayout {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: [...(adapter?.devices.values ?? [])].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

    function describe(device: var): string {
        const battery = device.batteryAvailable ? ` · ${Math.round(device.battery * 100)}%` : "";
        if (device.connected)
            return `Connected${battery}`;
        if (device.pairing)
            return "Pairing…";
        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting…";
        return device.paired ? "Paired" : "Not paired";
    }

    // BlueZ names devices with theme icon names; these are their Material twins.
    function glyph(device: var): string {
        const icon = device.icon ?? "";
        if (icon.startsWith("audio"))
            return "headphones";
        if (icon === "input-mouse")
            return "mouse";
        if (icon === "input-keyboard")
            return "keyboard";
        if (icon === "input-gaming")
            return "sports_esports";
        if (icon.startsWith("phone"))
            return "smartphone";
        return "bluetooth";
    }

    // Stop a scan left running when the page closes.
    Component.onDestruction: {
        if (root.adapter?.discovering)
            root.adapter.discovering = false;
    }

    spacing: Tokens.space.tight

    Text {
        Layout.fillWidth: true
        Layout.margins: Tokens.space.item

        visible: root.adapter === null

        text: "No Bluetooth adapter"
        color: Appearance.faint
        horizontalAlignment: Text.AlignHCenter

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.normal
    }

    ListRow {
        visible: root.adapter !== null

        icon: root.adapter?.enabled ? "bluetooth" : "bluetooth_disabled"
        title: "Bluetooth"
        subtitle: root.adapter?.enabled ? "On" : "Off"
        selected: root.adapter?.enabled ?? false

        onClicked: root.adapter.enabled = !root.adapter.enabled
    }

    ListRow {
        visible: root.adapter?.enabled ?? false

        icon: root.adapter?.discovering ? "bluetooth_searching" : "search"
        title: root.adapter?.discovering ? "Searching…" : "Search for devices"
        selected: root.adapter?.discovering ?? false

        onClicked: root.adapter.discovering = !root.adapter.discovering
    }

    SectionLabel {
        visible: root.adapter?.enabled && root.devices.length > 0

        text: "Devices"
    }

    Repeater {
        model: root.adapter?.enabled ? root.devices : []

        ListRow {
            required property var modelData

            icon: root.glyph(modelData)
            title: modelData.name || modelData.address
            subtitle: root.describe(modelData)
            selected: modelData.connected
            actionIcon: modelData.paired ? "delete" : ""

            onClicked: {
                if (modelData.connected)
                    modelData.disconnect();
                else if (modelData.paired)
                    modelData.connect();
                else
                    modelData.pair();
            }
            onAction: modelData.forget()
        }
    }
}
