// A level from 0 to 1 with an icon button in front, usually mute. Drag, click
// or scroll to change it; the owner applies `moved` and feeds `value` back.
import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    property real value: 0
    property string icon: ""
    property bool muted: false
    // Shown after the track instead of the percentage, like "4000K".
    property string valueText: ""
    // Outlined, for keyboard focus.
    property bool highlighted: false

    signal moved(real value)
    signal iconClicked

    implicitHeight: 32

    Rectangle {
        anchors.fill: parent

        visible: root.highlighted
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: Appearance.accent
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.tight
        anchors.rightMargin: Tokens.space.item

        spacing: Tokens.space.item

        IconButton {
            icon: root.icon
            tint: root.muted ? Appearance.danger : Appearance.dim
            font.pixelSize: Tokens.icon.control - 2

            onActivated: root.iconClicked()
        }

        Item {
            id: track

            Layout.fillWidth: true

            implicitHeight: 20

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width
                height: 6
                radius: height / 2
                color: Appearance.cell

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.value))
                    height: parent.height

                    radius: parent.radius
                    color: root.muted ? Appearance.faint : Appearance.accent
                }
            }

            MouseArea {
                anchors.fill: parent

                function moveTo(x: real): void {
                    root.moved(Math.max(0, Math.min(1, x / track.width)));
                }

                onPressed: mouse => moveTo(mouse.x)
                onPositionChanged: mouse => moveTo(mouse.x)
            }

            WheelHandler {
                onWheel: event => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
            }
        }

        Text {
            Layout.preferredWidth: 44

            text: root.valueText || `${Math.round(root.value * 100)}%`
            color: Appearance.dim
            horizontalAlignment: Text.AlignRight

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }
}
