// The notification center, or just the popups while it is closed.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    property bool center: false
    // Room for the whole panel; the list scrolls past it.
    property int maxHeight: Tokens.side.maxHeight

    spacing: Tokens.side.gap

    RowLayout {
        id: header

        Layout.fillWidth: true

        visible: root.center

        spacing: Tokens.space.item

        Text {
            Layout.fillWidth: true

            text: "Notifications"
            color: Appearance.text

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.title
            font.bold: true
        }

        IconButton {
            icon: Services.Notifications.dnd ? "notifications_off" : "notifications"
            tint: Services.Notifications.dnd ? Appearance.accent : Appearance.dim
            font.pixelSize: Tokens.icon.control - 2

            onActivated: Services.Notifications.toggleDnd()
        }

        IconButton {
            visible: Services.Notifications.hasNotifications

            icon: "clear_all"
            font.pixelSize: Tokens.icon.control - 2

            onActivated: Services.Notifications.clearAll()
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.space.item
        Layout.bottomMargin: Tokens.space.item

        visible: root.center && !Services.Notifications.hasNotifications

        text: Services.Notifications.dnd ? "Nothing new. Do not disturb is on." : "Nothing new"
        color: Appearance.faint
        horizontalAlignment: Text.AlignHCenter

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.normal
    }

    ListView {
        Layout.fillWidth: true

        implicitHeight: Math.min(contentHeight, root.maxHeight - (header.visible ? header.implicitHeight + root.spacing : 0))
        visible: count > 0

        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        spacing: Tokens.side.gap

        model: ScriptModel {
            values: root.center ? Services.Notifications.all : Services.Notifications.popups
        }

        delegate: NotificationCard {
            required property var modelData

            width: ListView.view.width

            notification: modelData
            popup: !root.center
        }

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Motion.normal
            }
        }

        displaced: Transition {
            Anim {
                property: "y"
            }
        }
    }
}
