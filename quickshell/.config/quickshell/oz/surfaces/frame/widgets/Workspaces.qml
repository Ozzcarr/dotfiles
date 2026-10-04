import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.config

RowLayout {
    id: root

    required property var screen

    readonly property var monitor: Hyprland.monitorFor(screen)

    Layout.alignment: Qt.AlignVCenter

    spacing: Tokens.space.tight

    // Dispatches are Lua: Hyprland runs a Lua config, and the classic
    // "workspace N" syntax (which HyprlandWorkspace.activate() sends) fails.
    Repeater {
        model: ScriptModel {
            // Negative ids are special workspaces.
            values: [...Hyprland.workspaces.values].filter(ws => ws.monitor === root.monitor && ws.id > 0).sort((a, b) => a.id - b.id)
        }

        Rectangle {
            id: cell

            required property HyprlandWorkspace modelData

            readonly property bool focused: modelData.focused

            Layout.alignment: Qt.AlignVCenter

            implicitWidth: Tokens.workspace.size
            implicitHeight: Tokens.workspace.size

            radius: Tokens.radius.cell
            color: modelData.urgent ? Appearance.danger : Appearance.cell

            Rectangle {
                anchors.fill: parent

                radius: parent.radius
                opacity: cell.focused ? 1 : 0

                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0
                        color: Appearance.accent
                    }

                    GradientStop {
                        position: 1
                        color: Appearance.accentAlt
                    }
                }

                Behavior on opacity {
                    Anim {}
                }
            }

            Text {
                anchors.centerIn: parent

                text: cell.modelData.id
                color: cell.focused ? Appearance.onAccent : Appearance.dim

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.small
                font.bold: cell.focused
            }

            MouseArea {
                anchors.fill: parent

                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${cell.modelData.id} })`)
            }
        }
    }

    WheelHandler {
        onWheel: event => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${event.angleDelta.y > 0 ? "e-1" : "e+1"}" })`)
    }
}
