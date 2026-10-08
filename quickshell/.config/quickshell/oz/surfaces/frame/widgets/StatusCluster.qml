import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.components
import qs.config
import qs.services as Services

RowLayout {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var wired: Networking.devices.values.find(d => d.type !== DeviceType.Wifi && d.connected) ?? null
    readonly property bool online: !!wifi || !!wired

    readonly property bool btConnected: Bluetooth.devices.values.some(d => d.connected)

    readonly property bool hasBattery: Services.Battery.present
    readonly property int charge: Services.Battery.charge
    readonly property bool draining: Services.Battery.draining

    readonly property bool micMuted: Services.Vesktop.micMuted
    readonly property bool deafened: Services.Vesktop.deafened

    Layout.alignment: Qt.AlignVCenter

    spacing: Tokens.space.tight

    // A rebuild in progress. Click opens the NixOS panel.
    Pill {
        visible: Services.Nix.running !== ""

        TapHandler {
            onTapped: Services.Panels.open("nix", Services.Panels.focusedScreen, "")
        }

        MaterialIcon {
            text: "progress_activity"
            color: Appearance.accent

            RotationAnimation on rotation {
                running: Services.Nix.running !== ""
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }
    }

    Pill {
        visible: Services.GameMode.active

        MaterialIcon {
            text: "sports_esports"
            color: Appearance.accent
        }
    }

    // Alerts, then the bell. Click opens the notification center; right click
    // toggles do not disturb.
    Pill {
        TapHandler {
            onTapped: Services.Panels.toggle("notifications", Services.Panels.focusedScreen)
        }

        TapHandler {
            acceptedButtons: Qt.RightButton

            onTapped: Services.Notifications.toggleDnd()
        }

        MaterialIcon {
            visible: root.micMuted

            text: "mic_off"
            color: Appearance.danger
        }

        MaterialIcon {
            visible: root.deafened

            text: "headset_off"
            color: Appearance.danger
        }

        MaterialIcon {
            visible: Services.Audio.muted

            text: "volume_off"
            color: Appearance.danger
        }

        MaterialIcon {
            text: Services.Notifications.dnd ? "notifications_off" : Services.Notifications.hasNotifications ? "notifications_active" : "notifications"
            color: Services.Notifications.dnd ? Appearance.faint : Services.Notifications.hasNotifications ? Appearance.accent : Appearance.dim
        }
    }

    // Connections and battery. Click opens quick settings.
    Pill {
        TapHandler {
            onTapped: Services.Panels.toggle("settings", Services.Panels.focusedScreen)
        }

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
