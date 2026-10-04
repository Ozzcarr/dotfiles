import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services as Services

RowLayout {
    spacing: Tokens.space.item

    Item {
        implicitWidth: Tokens.icon.control
        implicitHeight: Tokens.icon.control

        IconImage {
            anchors.fill: parent

            visible: Services.Osd.appIcon !== ""
            source: Services.Osd.appIcon ? Quickshell.iconPath(Services.Osd.appIcon, true) : ""
        }

        MaterialIcon {
            anchors.centerIn: parent

            visible: Services.Osd.appIcon === ""

            text: Services.Osd.icon
            color: Appearance.accent
            font.pixelSize: Tokens.icon.control
        }
    }

    Rectangle {
        Layout.fillWidth: true

        visible: Services.Osd.level >= 0

        implicitHeight: 6
        radius: height / 2
        color: Appearance.cell

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, Services.Osd.level))
            height: parent.height

            radius: parent.radius
            color: Appearance.accent

            Behavior on width {
                Anim {
                    duration: Motion.fast
                }
            }
        }
    }

    Text {
        Layout.fillWidth: Services.Osd.level < 0
        Layout.minimumWidth: Services.Osd.level < 0 ? 0 : 36

        text: Services.Osd.label
        color: Appearance.text
        horizontalAlignment: Services.Osd.level < 0 ? Text.AlignLeft : Text.AlignRight

        font.family: Tokens.font.mono
        font.pixelSize: Tokens.font.size.normal
    }
}
