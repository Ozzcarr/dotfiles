import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    required property string icon
    required property string label
    required property int value
    required property var history
    property string detail: ""

    Layout.fillWidth: true
    Layout.fillHeight: true

    spacing: 4

    RowLayout {
        Layout.fillWidth: true

        spacing: Tokens.space.tight

        MaterialIcon {
            text: root.icon
            color: Appearance.soft
        }

        Text {
            text: root.label
            color: Appearance.text

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }

        Text {
            Layout.fillWidth: true

            text: root.detail
            color: Appearance.faint
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }

        Text {
            text: `${root.value}%`
            color: Appearance.text

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.normal
        }
    }

    Sparkline {
        Layout.fillWidth: true
        Layout.fillHeight: true

        implicitHeight: 22

        values: root.history
        capacity: Services.Sys.historyLength
        color: root.value >= 90 ? Appearance.danger : Appearance.accent
    }
}
