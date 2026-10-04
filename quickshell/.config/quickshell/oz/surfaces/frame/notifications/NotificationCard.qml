// One notification. As a popup it times out, paused while hovered; in the
// center it stays until dismissed.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services as Services

Rectangle {
    id: root

    required property Notification notification
    property bool popup: false

    readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
    readonly property string appIcon: {
        const icon = notification?.appIcon;
        if (!icon)
            return "";
        return icon.startsWith("/") ? `file://${icon}` : Quickshell.iconPath(icon, true);
    }

    implicitHeight: content.implicitHeight + 2 * Tokens.notifications.cardPadding

    radius: Tokens.notifications.cardRadius
    color: Appearance.cell
    border.width: critical ? 1 : 0
    border.color: Appearance.danger

    Timer {
        running: root.popup && !root.critical && !hover.hovered
        interval: root.notification?.expireTimeout > 0 ? root.notification?.expireTimeout : Tokens.notifications.timeout

        onTriggered: Services.Notifications.hidePopup(root.notification)
    }

    HoverHandler {
        id: hover
    }

    MouseArea {
        anchors.fill: parent

        onClicked: Services.Notifications.activate(root.notification)
    }

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Tokens.notifications.cardPadding

        spacing: Tokens.notifications.cardPadding

        // The notification's own image (a contact photo, an album) wins over
        // the app icon.
        Item {
            Layout.alignment: Qt.AlignTop

            implicitWidth: Tokens.notifications.iconSize
            implicitHeight: Tokens.notifications.iconSize

            ClippingRectangle {
                anchors.fill: parent

                visible: image.status === Image.Ready
                radius: Tokens.notifications.cardRadius - 6
                color: "transparent"

                Image {
                    id: image

                    anchors.fill: parent

                    source: root.notification?.image
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            IconImage {
                anchors.fill: parent

                visible: image.status !== Image.Ready && root.appIcon !== ""
                source: root.appIcon
                asynchronous: true
            }

            MaterialIcon {
                anchors.centerIn: parent

                visible: image.status !== Image.Ready && root.appIcon === ""

                text: "notifications"
                color: root.critical ? Appearance.danger : Appearance.accent
                font.pixelSize: Tokens.icon.control
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true

                    text: root.notification?.appName
                    color: Appearance.faint
                    elide: Text.ElideRight

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.small
                }

                IconButton {
                    icon: "close"
                    font.pixelSize: Tokens.icon.glyph

                    onActivated: root.notification?.dismiss()
                }
            }

            Text {
                Layout.fillWidth: true

                text: root.notification?.summary
                color: Appearance.text
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large
                font.bold: true
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""

                text: root.notification?.body
                textFormat: Text.StyledText
                color: Appearance.dim
                linkColor: Appearance.accent
                elide: Text.ElideRight
                maximumLineCount: root.popup ? 3 : 8
                wrapMode: Text.Wrap

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal

                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            // The default action is the click on the card itself.
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

                visible: actions.count > 0

                spacing: Tokens.space.tight

                Repeater {
                    id: actions

                    model: (root.notification?.actions ?? []).filter(a => a.identifier !== "default")

                    Rectangle {
                        id: action

                        required property NotificationAction modelData

                        Layout.fillWidth: true

                        implicitHeight: label.implicitHeight + 10
                        radius: height / 2
                        color: actionArea.containsMouse ? Qt.alpha(Appearance.accent, 0.25) : Appearance.cell

                        Text {
                            id: label

                            anchors.centerIn: parent
                            width: parent.width - 16

                            text: action.modelData.text
                            color: Appearance.text
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter

                            font.family: Tokens.font.ui
                            font.pixelSize: Tokens.font.size.normal
                        }

                        MouseArea {
                            id: actionArea

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked: action.modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
