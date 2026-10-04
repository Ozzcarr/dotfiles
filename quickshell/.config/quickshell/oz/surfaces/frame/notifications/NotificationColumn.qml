// Grows down out of the right pod, attached to the right rail. Shows popups as
// they arrive, or the whole history when the notification center is open.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config
import qs.services as Services

Item {
    id: root

    // The notification center is open on this screen.
    property bool open: false
    property bool showPopups: false

    // Size of the pod it grows from.
    required property int collapsedWidth

    readonly property var notifications: open ? Services.Notifications.all : showPopups ? Services.Notifications.popups : []
    readonly property bool active: open || notifications.length > 0
    readonly property int pad: Tokens.notifications.padding
    readonly property int contentTop: Tokens.frame.pod + pad / 2

    width: active ? Tokens.notifications.width : collapsedWidth
    height: active ? Math.min(contentTop + content.implicitHeight + pad, Tokens.notifications.maxHeight) : Tokens.frame.pod

    visible: height > Tokens.frame.pod + 1

    Behavior on width {
        Anim {}
    }

    Behavior on height {
        Anim {}
    }

    // Swallows clicks on empty parts, which would otherwise reach the
    // full-screen close handler behind it.
    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent

        color: Appearance.panel

        bottomLeftRadius: Tokens.frame.radius
    }

    // Into the top rail on the left, into the right rail below.
    InverseCorner {
        bite: InverseCorner.Bite.BottomLeft
        size: Tokens.frame.sweep

        x: -width
        y: Tokens.frame.thickness
    }

    InverseCorner {
        bite: InverseCorner.Bite.BottomLeft

        x: root.width - Tokens.frame.thickness - width
        y: root.height
    }

    // Laid out at the final width, against the right edge, and revealed by
    // the growing shape.
    Item {
        anchors.fill: parent

        clip: true

        ColumnLayout {
            id: content

            anchors.right: parent.right
            anchors.rightMargin: root.pad

            y: root.contentTop
            width: Tokens.notifications.width - 2 * root.pad

            spacing: Tokens.notifications.gap

            RowLayout {
                Layout.fillWidth: true

                visible: root.open

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

                visible: root.open && !Services.Notifications.hasNotifications

                text: Services.Notifications.dnd ? "Nothing new. Do not disturb is on." : "Nothing new"
                color: Appearance.faint
                horizontalAlignment: Text.AlignHCenter

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }

            ListView {
                Layout.fillWidth: true

                implicitHeight: Math.min(contentHeight, Tokens.notifications.maxHeight - root.contentTop - 2 * root.pad)
                visible: count > 0

                clip: true
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                spacing: Tokens.notifications.gap

                model: ScriptModel {
                    values: root.notifications
                }

                delegate: NotificationCard {
                    required property var modelData

                    width: ListView.view.width

                    notification: modelData
                    popup: !root.open
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
    }
}
