import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

RowLayout {
    spacing: Tokens.session.gap

    Repeater {
        model: Services.Session.actions

        Rectangle {
            id: button

            required property var modelData
            required property int index

            readonly property bool selected: index === Services.Session.current
            readonly property bool confirming: Services.Session.confirming === modelData.key

            implicitWidth: Tokens.session.buttonWidth
            implicitHeight: Tokens.session.buttonHeight

            radius: Tokens.side.rowRadius
            color: confirming ? Qt.alpha(Appearance.danger, 0.25) : selected ? Qt.alpha(Appearance.accent, 0.22) : Appearance.cell

            Behavior on color {
                ColorAnimation {
                    duration: Motion.fast
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                onEntered: Services.Session.current = button.index
                onClicked: Services.Session.activate(button.index)
            }

            ColumnLayout {
                anchors.centerIn: parent

                spacing: Tokens.space.tight

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter

                    text: button.modelData.icon
                    color: button.confirming ? Appearance.danger : button.selected ? Appearance.accent : Appearance.dim
                    font.pixelSize: Tokens.icon.control + 6
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: button.confirming ? "Again?" : button.modelData.label
                    color: button.confirming ? Appearance.danger : Appearance.text

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.normal
                }
            }
        }
    }
}
