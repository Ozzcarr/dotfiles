// One device or network in a quick settings page.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

Rectangle {
    id: root

    required property string icon
    required property string title
    property string subtitle: ""
    property bool selected: false
    // A small trailing button, like "forget"; "" for none.
    property string actionIcon: ""

    signal clicked
    signal action

    Layout.fillWidth: true
    implicitHeight: Tokens.side.rowHeight

    radius: Tokens.side.rowRadius
    color: selected ? Qt.alpha(Appearance.accent, 0.22) : area.containsMouse ? Appearance.cell : "transparent"
    border.width: nav.focused ? 1 : 0
    border.color: Appearance.accent

    NavTarget {
        id: nav

        onActivated: root.clicked()
        onSecondaryActivated: {
            if (root.actionIcon !== "")
                root.action();
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent

        hoverEnabled: true

        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.item
        anchors.rightMargin: Tokens.space.item

        spacing: Tokens.space.item

        MaterialIcon {
            text: root.icon
            color: root.selected ? Appearance.accent : Appearance.dim
            font.pixelSize: Tokens.icon.control - 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            spacing: 0

            Text {
                Layout.fillWidth: true

                text: root.title
                color: Appearance.text
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""

                text: root.subtitle
                color: Appearance.faint
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.small
            }
        }

        IconButton {
            visible: root.actionIcon !== ""

            icon: root.actionIcon
            font.pixelSize: Tokens.icon.glyph

            onActivated: root.action()
        }
    }
}
