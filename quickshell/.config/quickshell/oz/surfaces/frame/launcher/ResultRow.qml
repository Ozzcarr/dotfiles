import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services.launcher

Item {
    id: root

    required property var modelData
    required property int index

    readonly property bool selected: index === Launcher.current
    readonly property bool confirming: Launcher.confirming !== "" && Launcher.confirming === modelData.key
    readonly property string iconPath: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""

    implicitWidth: ListView.view?.width ?? 0
    implicitHeight: Tokens.launcher.rowHeight

    Rectangle {
        anchors.fill: parent

        radius: Tokens.launcher.rowRadius
        color: root.selected ? Appearance.cell : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Motion.fast
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.launcher.padding
        anchors.rightMargin: Tokens.launcher.padding

        spacing: Tokens.launcher.padding

        Item {
            implicitWidth: Tokens.launcher.iconSize
            implicitHeight: Tokens.launcher.iconSize

            IconImage {
                anchors.fill: parent

                visible: root.iconPath !== ""
                source: root.iconPath
                asynchronous: true
            }

            MaterialIcon {
                anchors.centerIn: parent

                visible: root.iconPath === ""

                text: root.modelData.glyph ?? "apps"
                color: root.selected ? Appearance.accent : Appearance.dim
                font.pixelSize: Tokens.icon.control
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0

            spacing: 0

            Text {
                Layout.fillWidth: true

                text: root.modelData.title
                color: Appearance.text
                elide: Text.ElideRight
                maximumLineCount: 1

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large
            }

            Text {
                Layout.fillWidth: true

                visible: text !== ""

                text: root.modelData.subtitle ?? ""
                color: root.confirming ? Appearance.danger : Appearance.faint
                elide: Text.ElideRight
                maximumLineCount: 1

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.small
            }
        }

        Text {
            visible: text !== ""

            text: root.modelData.hint ?? ""
            color: Appearance.dim

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: Launcher.current = root.index
        onClicked: Launcher.activate(root.index)
    }
}
