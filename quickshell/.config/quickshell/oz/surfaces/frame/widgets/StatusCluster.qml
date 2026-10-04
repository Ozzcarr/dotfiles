import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import qs.components
import qs.config
import qs.services as Services

RowLayout {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wired: Networking.devices.values.find(d => d.type !== DeviceType.Wifi && d.connected) ?? null
    readonly property bool online: !!wifi || !!wired

    readonly property bool btConnected: Bluetooth.devices.values.some(d => d.connected)

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery ?? false
    readonly property int charge: Math.round((battery?.percentage ?? 0) * 100)
    readonly property bool draining: hasBattery && UPower.onBattery

    readonly property bool micMuted: Services.Vesktop.micMuted
    readonly property bool alerting: micMuted || Services.Audio.muted || Services.Notifications.hasNotifications || Services.Notifications.dnd

    Layout.alignment: Qt.AlignVCenter

    spacing: Tokens.space.tight

    Pill {
        visible: Services.GameMode.active

        MaterialIcon {
            text: "sports_esports"
            color: Appearance.accent
        }
    }

    Pill {
        visible: root.alerting

        MaterialIcon {
            visible: root.micMuted

            text: "mic_off"
            color: Appearance.danger
        }

        MaterialIcon {
            visible: Services.Audio.muted

            text: "volume_off"
            color: Appearance.danger
        }

        MaterialIcon {
            visible: Services.Notifications.hasNotifications && !Services.Notifications.dnd

            text: "notifications_active"
            color: Appearance.accent
        }

        MaterialIcon {
            visible: Services.Notifications.dnd

            text: "notifications_off"
            color: Appearance.faint
        }
    }

    Pill {
        MaterialIcon {
            text: root.wifi ? "wifi" : root.wired ? "lan" : "wifi_off"
            color: root.online ? Appearance.soft : Appearance.danger
        }

        MaterialIcon {
            visible: !!Bluetooth.defaultAdapter?.enabled

            text: root.btConnected ? "bluetooth_connected" : "bluetooth"
            color: root.btConnected ? Appearance.soft : Appearance.dim
        }

        MaterialIcon {
            visible: root.hasBattery

            text: !root.draining ? "battery_charging_full" : root.charge > 60 ? "battery_6_bar" : root.charge > 30 ? "battery_4_bar" : root.charge > 15 ? "battery_2_bar" : "battery_alert"
            color: root.draining && root.charge <= 15 ? Appearance.danger : root.draining && root.charge <= 30 ? Appearance.warning : Appearance.soft
        }

        Text {
            visible: root.draining

            Layout.alignment: Qt.AlignVCenter

            text: `${root.charge}%`
            color: Appearance.dim

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }
}
