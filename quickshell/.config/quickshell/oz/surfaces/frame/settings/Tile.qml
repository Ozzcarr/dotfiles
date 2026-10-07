// A quick settings toggle. Clicking it toggles; the arrow, when there is one,
// opens that setting's page.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

Rectangle {
    id: root

    required property string icon
    required property string label
    property string detail: ""
    property bool active: false
    property bool expandable: false

    signal toggled
    signal expanded

    implicitHeight: 52

    radius: Tokens.side.rowRadius
    color: active ? Qt.alpha(Appearance.accent, 0.22) : Appearance.cell
    border.width: nav.focused ? 1 : 0
    border.color: Appearance.accent

    Behavior on color {
        ColorAnimation {
            duration: Motion.fast
        }
    }

    NavTarget {
        id: nav

        expandable: root.expandable

        onActivated: root.toggled()
        onExpanded: root.expanded()
    }

    MouseArea {
        anchors.fill: parent

        onClicked: root.toggled()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.item + 2
        anchors.rightMargin: Tokens.space.item

        spacing: Tokens.space.item

        MaterialIcon {
            text: root.icon
            color: root.active ? Appearance.accent : Appearance.dim
            font.pixelSize: Tokens.icon.control - 2
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            spacing: 0

            Text {
                Layout.fillWidth: true

                text: root.label
                color: Appearance.text
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
                font.bold: true
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""

                text: root.detail
                color: Appearance.faint
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.small
            }
        }

        IconButton {
            visible: root.expandable

            icon: "chevron_right"
            font.pixelSize: Tokens.icon.control - 2

            onActivated: root.expanded()
        }
    }
}
