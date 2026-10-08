import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

Rectangle {
    id: root

    required property var modelData
    required property int index

    readonly property var nix: Services.Nix
    readonly property bool selected: index === nix.action
    readonly property bool confirming: nix.confirming === modelData.key
    readonly property bool running: nix.running === modelData.key
    readonly property bool blocked: nix.running !== "" && !running

    Layout.fillWidth: true
    implicitHeight: Tokens.nix.rowHeight

    radius: Tokens.side.rowRadius
    color: {
        if (confirming)
            return Qt.alpha(Appearance.danger, 0.22);
        if (selected)
            return Qt.alpha(Appearance.accent, nix.inView ? 0.1 : 0.22);
        return area.containsMouse ? Appearance.cell : "transparent";
    }

    Behavior on color {
        ColorAnimation {
            duration: Motion.fast
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.item
        anchors.rightMargin: Tokens.space.item

        spacing: Tokens.space.item

        MaterialIcon {
            text: root.modelData.icon
            color: root.confirming ? Appearance.danger : root.running || root.selected ? Appearance.accent : root.blocked ? Appearance.faint : Appearance.dim
            font.pixelSize: Tokens.icon.control - 4
        }

        Text {
            Layout.fillWidth: true

            text: root.confirming ? "Again to confirm" : root.modelData.label
            color: root.confirming ? Appearance.danger : root.blocked ? Appearance.faint : Appearance.text
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }

        Text {
            text: root.modelData.alias
            color: Appearance.faint

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            root.nix.inView = false;
            root.nix.action = root.index;
            root.nix.start(root.modelData.key);
        }
    }
}
