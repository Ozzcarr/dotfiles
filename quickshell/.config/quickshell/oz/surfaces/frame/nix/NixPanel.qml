// NixOS: rebuild operations on the left, and on the right pending updates,
// the generations, or the output of the last operation or diff.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

RowLayout {
    id: root

    readonly property var nix: Services.Nix
    readonly property var current: nix.generations.find(gen => gen.current) ?? null

    spacing: Tokens.space.pod

    ColumnLayout {
        Layout.preferredWidth: Tokens.nix.actionsWidth
        Layout.fillHeight: true

        spacing: 2

        Text {
            Layout.bottomMargin: Tokens.space.tight

            text: "NixOS"
            color: Appearance.text

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.title
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            Layout.bottomMargin: Tokens.space.item

            text: root.current ? `Generation ${root.current.number} · ${root.current.version}` : ""
            color: Appearance.faint
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }

        Repeater {
            model: root.nix.operations

            OperationRow {}
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.fillWidth: true

            text: "Tab views · ←→ side · Enter runs"
            color: Appearance.faint
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: Tokens.space.item

        RowLayout {
            Layout.fillWidth: true

            spacing: Tokens.space.tight

            Repeater {
                model: [
                    { key: "updates", label: Services.Updates.count > 0 ? `Updates · ${Services.Updates.count}` : "Updates" },
                    { key: "generations", label: "Generations" },
                    { key: "output", label: "Output" }
                ]

                Rectangle {
                    id: tab

                    required property var modelData

                    readonly property bool active: root.nix.view === modelData.key

                    implicitWidth: label.implicitWidth + 2 * Tokens.space.pod
                    implicitHeight: Tokens.pill.height + 8

                    radius: height / 2
                    color: active ? Qt.alpha(Appearance.accent, root.nix.inView ? 0.22 : 0.12) : tabArea.containsMouse ? Appearance.cell : "transparent"

                    Text {
                        id: label

                        anchors.centerIn: parent

                        text: tab.modelData.label
                        color: tab.active ? Appearance.accent : Appearance.dim

                        font.family: Tokens.font.ui
                        font.pixelSize: Tokens.font.size.normal
                        font.bold: tab.active
                    }

                    MouseArea {
                        id: tabArea

                        anchors.fill: parent

                        hoverEnabled: true

                        onClicked: root.nix.view = tab.modelData.key
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialIcon {
                visible: root.nix.running !== ""

                text: "progress_activity"
                color: Appearance.accent

                RotationAnimation on rotation {
                    running: root.nix.running !== ""
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }

            Text {
                text: {
                    if (root.nix.running !== "")
                        return `${root.nix.operation(root.nix.running).label}…`;
                    if (root.nix.result === "failed")
                        return `${root.nix.operation(root.nix.last).label} failed`;
                    if (root.nix.result === "success")
                        return `${root.nix.operation(root.nix.last).label} finished`;
                    return "";
                }
                color: root.nix.result === "failed" && root.nix.running === "" ? Appearance.danger : Appearance.dim

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Tokens.side.rowRadius
            color: Appearance.cell

            StackLayout {
                anchors.fill: parent
                anchors.margins: Tokens.space.item

                currentIndex: root.nix.views.indexOf(root.nix.view)

                UpdatesView {}

                GenerationsView {}

                OutputView {}
            }
        }
    }
}
