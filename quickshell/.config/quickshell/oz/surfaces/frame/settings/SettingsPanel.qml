// Quick settings: the overview, or one of its pages.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    // Room for the whole panel; the page scrolls past it.
    property int maxHeight: Tokens.side.maxHeight
    readonly property string page: Services.Panels.page
    readonly property var titles: ({
            "": "Quick settings",
            audio: "Sound",
            wifi: "Wi-Fi",
            bluetooth: "Bluetooth",
            nightlight: "Night light"
        })

    spacing: Tokens.side.gap

    // These can change outside the shell.
    onVisibleChanged: {
        if (visible) {
            Services.Toggles.refresh();
            Services.Audio.refreshSource();
        }
    }

    RowLayout {
        id: header

        Layout.fillWidth: true

        spacing: Tokens.space.tight

        IconButton {
            visible: root.page !== ""

            icon: "arrow_back"
            font.pixelSize: Tokens.icon.control - 2

            onActivated: Services.Panels.page = ""
        }

        Text {
            Layout.fillWidth: true

            text: root.titles[root.page] ?? ""
            color: Appearance.text

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.title
            font.bold: true
        }
    }

    Flickable {
        id: flick

        Layout.fillWidth: true

        implicitHeight: Math.min(contentHeight, root.maxHeight - header.implicitHeight - root.spacing)
        contentHeight: pageLoader.implicitHeight
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds

        // Keeps the keyboard focus in view.
        Connections {
            target: Services.SettingsNav

            function onCurrentChanged(): void {
                const item = Services.SettingsNav.current?.parent;
                if (!item)
                    return;
                const top = item.mapToItem(pageLoader, 0, 0).y;
                if (top < flick.contentY)
                    flick.contentY = top;
                else if (top + item.height > flick.contentY + flick.height)
                    flick.contentY = top + item.height - flick.height;
            }
        }

        Loader {
            id: pageLoader

            width: parent.width

            sourceComponent: {
                switch (root.page) {
                case "audio":
                    return audioPage;
                case "wifi":
                    return wifiPage;
                case "bluetooth":
                    return bluetoothPage;
                case "nightlight":
                    return nightLightPage;
                default:
                    return overview;
                }
            }
        }
    }

    Component {
        id: overview

        Overview {}
    }

    Component {
        id: audioPage

        AudioPage {}
    }

    Component {
        id: wifiPage

        WifiPage {}
    }

    Component {
        id: bluetoothPage

        BluetoothPage {}
    }

    Component {
        id: nightLightPage

        NightLightPage {}
    }
}
