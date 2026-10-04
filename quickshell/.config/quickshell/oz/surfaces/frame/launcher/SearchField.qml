import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services.launcher

Rectangle {
    id: root

    readonly property bool inMode: Launcher.mode.name !== "apps"

    implicitHeight: Tokens.launcher.inputHeight

    radius: Tokens.launcher.rowRadius
    color: Appearance.cell

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.launcher.padding
        anchors.rightMargin: Tokens.launcher.padding

        spacing: Tokens.space.item

        MaterialIcon {
            visible: !root.inMode

            text: "search"
            font.pixelSize: Tokens.icon.control - 2
        }

        // The current mode, as a chip; Backspace on an empty search leaves it.
        Pill {
            visible: root.inMode

            implicitHeight: Tokens.pill.height + 4
            color: Qt.alpha(Appearance.accent, 0.18)

            MaterialIcon {
                text: Launcher.mode.icon
                color: Appearance.accent
            }

            Text {
                text: Launcher.mode.label
                color: Appearance.accent

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
                font.bold: true
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextInput {
                id: mirror

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                readOnly: true
                cursorVisible: true
                clip: true

                text: Launcher.query
                cursorPosition: Launcher.cursor
                color: Appearance.text
                selectionColor: Qt.alpha(Appearance.accent, 0.35)
                selectedTextColor: Appearance.text

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large

                cursorDelegate: Rectangle {
                    width: 2
                    radius: 1
                    color: Appearance.accent
                }

                function syncSelection(): void {
                    if (Launcher.selectionStart !== Launcher.selectionEnd)
                        select(Launcher.selectionStart, Launcher.selectionEnd);
                    else
                        deselect();
                }

                onTextChanged: syncSelection()

                Connections {
                    target: Launcher

                    function onSelectionStartChanged(): void {
                        mirror.syncSelection();
                    }

                    function onSelectionEndChanged(): void {
                        mirror.syncSelection();
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 4

                visible: Launcher.query === ""

                text: Launcher.mode.placeholder
                color: Appearance.faint

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large
            }
        }

        // Prefixes that switch modes, shown until you start typing.
        Row {
            visible: !root.inMode && Launcher.query === ""

            spacing: Tokens.space.item

            Repeater {
                model: Launcher.modes.filter(m => m.prefix !== "")

                Text {
                    required property var modelData

                    text: `${modelData.prefix} ${modelData.short}`
                    color: Appearance.faint

                    font.family: Tokens.font.mono
                    font.pixelSize: Tokens.font.size.small
                }
            }
        }
    }
}
