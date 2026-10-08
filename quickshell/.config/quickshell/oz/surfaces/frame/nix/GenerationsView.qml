// The system generations. Enter or a click diffs one against the current
// generation, or against the one marked with Space or a right click.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ListView {
    id: root

    readonly property var nix: Services.Nix

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    spacing: 2

    model: nix.generations
    currentIndex: nix.generation

    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

    delegate: Rectangle {
        id: row

        required property var modelData
        required property int index

        readonly property bool selected: index === root.nix.generation
        readonly property bool marked: index === root.nix.marked

        width: ListView.view.width
        height: Tokens.nix.rowHeight

        radius: Tokens.side.rowRadius
        color: selected && root.nix.inView ? Qt.alpha(Appearance.accent, 0.22) : area.containsMouse || selected ? Qt.alpha(Appearance.text, 0.05) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.space.item
            anchors.rightMargin: Tokens.space.item

            spacing: Tokens.space.item

            MaterialIcon {
                text: row.marked ? "flag" : row.modelData.current ? "radio_button_checked" : "radio_button_unchecked"
                color: row.marked || row.modelData.current ? Appearance.accent : Appearance.faint
            }

            Text {
                Layout.preferredWidth: 40

                text: row.modelData.number
                color: Appearance.text

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.normal
                font.bold: true
            }

            Text {
                Layout.preferredWidth: 120

                text: Qt.formatDateTime(row.modelData.date, "yyyy-MM-dd HH:mm")
                color: Appearance.dim

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.small
            }

            Text {
                Layout.fillWidth: true

                text: row.modelData.version
                color: Appearance.dim
                elide: Text.ElideRight

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.small
            }

            Text {
                text: row.modelData.kernel
                color: Appearance.faint

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.small
            }

            Pill {
                visible: row.modelData.current || row.modelData.next

                color: Qt.alpha(Appearance.accent, 0.15)

                Text {
                    text: row.modelData.current && row.modelData.next ? "current" : row.modelData.current ? "running" : "next boot"
                    color: Appearance.accent

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.small
                }
            }
        }

        MouseArea {
            id: area

            anchors.fill: parent

            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: event => {
                root.nix.generation = row.index;
                if (event.button === Qt.RightButton)
                    root.nix.mark(row.index);
                else
                    root.nix.diff();
            }
        }
    }
}
