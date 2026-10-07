// A mirrored text field: shows text typed in the keyboard surface, with a
// caret while it is the field being typed into.
import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    required property string label
    property string text: ""
    property bool active: false

    Layout.fillWidth: true
    implicitHeight: Tokens.side.rowHeight

    radius: Tokens.side.rowRadius
    color: Appearance.cell
    border.width: active ? 1 : 0
    border.color: Appearance.accent

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.item
        anchors.rightMargin: Tokens.space.item

        spacing: Tokens.space.item

        Text {
            Layout.preferredWidth: 70

            text: root.label
            color: Appearance.faint

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }

        Text {
            Layout.fillWidth: true

            text: root.text + (root.active ? "▏" : "")
            color: Appearance.text
            elide: Text.ElideLeft

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }
    }
}
