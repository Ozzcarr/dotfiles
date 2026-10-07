// The first page: levels, toggles and the power profile.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import qs.components
import qs.config
import qs.services as Services
import qs.services.launcher

ColumnLayout {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property var wifiNetwork: Services.Wifi.networks.find(n => n.connected) ?? null

    function openPage(page: string): void {
        Services.Panels.page = page;
    }

    spacing: Tokens.side.gap

    SettingsSlider {
        Layout.fillWidth: true

        icon: muted ? "volume_off" : "volume_up"
        muted: Services.Audio.muted
        value: Services.Audio.output?.audio?.volume ?? 0

        onMoved: value => Services.Audio.setVolume(Services.Audio.output, value)
        onIconClicked: Services.Audio.toggleMute(Services.Audio.output)
    }

    SettingsSlider {
        Layout.fillWidth: true

        icon: muted ? "mic_off" : "mic"
        muted: Services.Audio.sourceMuted
        value: Services.Audio.sourceVolume

        onMoved: value => Services.Audio.setSourceVolume(value)
        onIconClicked: Services.Audio.toggleSourceMute()
    }

    SettingsSlider {
        Layout.fillWidth: true

        visible: Services.Brightness.available

        icon: "brightness_medium"
        value: Services.Brightness.percent / 100

        onMoved: value => Services.Brightness.set(Math.round(value * 100))
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4

        columns: 2
        rowSpacing: Tokens.side.gap
        columnSpacing: Tokens.side.gap

        Tile {
            Layout.fillWidth: true

            icon: "volume_up"
            label: "Sound"
            detail: Services.Audio.output === Services.Audio.sink ? Services.Audio.label(Services.Audio.output) : `${Services.Audio.label(Services.Audio.output)} via Easy Effects`
            active: !Services.Audio.muted
            expandable: true

            onToggled: Services.Audio.toggleMute(Services.Audio.output)
            onExpanded: root.openPage("audio")
        }

        Tile {
            Layout.fillWidth: true

            visible: Services.Wifi.device !== null

            icon: Services.Wifi.enabled ? "wifi" : "wifi_off"
            label: "Wi-Fi"
            detail: !Services.Wifi.enabled ? "Off" : root.wifiNetwork?.name ?? "Not connected"
            active: Services.Wifi.enabled
            expandable: true

            onToggled: Services.Wifi.setEnabled(!Services.Wifi.enabled)
            onExpanded: root.openPage("wifi")
        }

        Tile {
            Layout.fillWidth: true

            visible: root.adapter !== null

            icon: root.adapter?.enabled ? "bluetooth" : "bluetooth_disabled"
            label: "Bluetooth"
            detail: !root.adapter?.enabled ? "Off" : root.connectedDevices.map(d => d.name).join(", ") || "On"
            active: root.adapter?.enabled ?? false
            expandable: true

            onToggled: root.adapter.enabled = !root.adapter.enabled
            onExpanded: root.openPage("bluetooth")
        }

        Tile {
            Layout.fillWidth: true

            icon: Services.Notifications.dnd ? "notifications_off" : "notifications"
            label: "Do not disturb"
            active: Services.Notifications.dnd

            onToggled: Services.Notifications.toggleDnd()
        }

        Tile {
            Layout.fillWidth: true

            icon: "nightlight"
            label: "Night light"
            detail: Services.NightLight.enabled ? `${Services.NightLight.temperature}K` : ""
            active: Services.NightLight.enabled
            expandable: true

            onToggled: Services.NightLight.toggle()
            onExpanded: root.openPage("nightlight")
        }

        Tile {
            Layout.fillWidth: true

            icon: "coffee"
            label: "Keep awake"
            active: Services.Toggles.keepAwake

            onToggled: Services.Toggles.toggleKeepAwake()
        }

        Tile {
            Layout.fillWidth: true

            icon: "graphic_eq"
            label: "Noise removal"
            detail: Services.Toggles.noiseDeep ? "Deep" : "Light"
            active: Services.Toggles.noiseDeep

            onToggled: Services.Toggles.toggleNoise()
        }

        Tile {
            Layout.fillWidth: true

            icon: "desktop_windows"
            label: "Displays"
            detail: "hyprmoncfg"

            onToggled: {
                Services.Panels.close();
                Quickshell.execDetached([Launcher.terminal, "--title", "hyprmoncfg", "-e", "hyprmoncfg"]);
            }
        }
    }

    // Power profile, as segments; Left and Right switch between them.
    Item {
        id: power

        readonly property var profiles: [
            {
                profile: PowerProfile.PowerSaver,
                icon: "eco",
                label: "Saver"
            },
            {
                profile: PowerProfile.Balanced,
                icon: "balance",
                label: "Balanced"
            },
            ...(PowerProfiles.hasPerformanceProfile ? [
                    {
                        profile: PowerProfile.Performance,
                        icon: "speed",
                        label: "Performance"
                    }
                ] : [])
        ]

        function shift(delta: int): void {
            const at = power.profiles.findIndex(p => p.profile === PowerProfiles.profile);
            PowerProfiles.profile = power.profiles[Math.max(0, Math.min(power.profiles.length - 1, at + delta))].profile;
        }

        Layout.fillWidth: true
        Layout.topMargin: 4

        implicitHeight: segments.implicitHeight

        NavTarget {
            id: powerNav

            steps: true

            onActivated: power.shift(1)
            onStepped: delta => power.shift(delta)
        }

        RowLayout {
            id: segments

            anchors.fill: parent

            spacing: Tokens.space.tight

            Repeater {
                model: power.profiles

                Rectangle {
                    id: segment

                    required property var modelData

                    readonly property bool current: PowerProfiles.profile === modelData.profile

                    Layout.fillWidth: true

                    implicitHeight: 34
                    radius: Tokens.side.rowRadius
                    color: current ? Qt.alpha(Appearance.accent, 0.22) : Appearance.cell
                    border.width: current && powerNav.focused ? 1 : 0
                    border.color: Appearance.accent

                    MouseArea {
                        anchors.fill: parent

                        onClicked: PowerProfiles.profile = segment.modelData.profile
                    }

                    RowLayout {
                        anchors.centerIn: parent

                        spacing: Tokens.space.tight

                        MaterialIcon {
                            text: segment.modelData.icon
                            color: segment.current ? Appearance.accent : Appearance.dim
                        }

                        Text {
                            text: segment.modelData.label
                            color: segment.current ? Appearance.text : Appearance.dim

                            font.family: Tokens.font.ui
                            font.pixelSize: Tokens.font.size.normal
                        }
                    }
                }
            }
        }
    }
}
