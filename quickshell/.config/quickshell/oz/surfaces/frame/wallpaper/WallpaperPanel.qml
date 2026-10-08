// A grid of the wallpapers; the current one is marked, the selected one ringed.
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services as Services

Flickable {
    id: root

    readonly property int count: Services.Wallpaper.files.length
    readonly property int columns: Math.max(1, Math.min(count, Tokens.wallpaper.columns))
    readonly property int cellHeight: Tokens.wallpaper.thumbHeight + Tokens.wallpaper.labelHeight
    readonly property int shownRows: Math.max(1, Math.min(Math.ceil(count / columns), Tokens.wallpaper.rows))

    implicitWidth: columns * Tokens.wallpaper.thumbWidth + (columns - 1) * Tokens.wallpaper.gap
    implicitHeight: shownRows * cellHeight + (shownRows - 1) * Tokens.wallpaper.gap

    contentHeight: grid.implicitHeight
    clip: true
    interactive: contentHeight > height
    boundsBehavior: Flickable.StopAtBounds

    // Keeps the selection in view.
    Connections {
        target: Services.Wallpaper

        function onSelectedChanged(): void {
            const row = Math.floor(Services.Wallpaper.selected / root.columns);
            const top = row * (root.cellHeight + Tokens.wallpaper.gap);
            if (top < root.contentY)
                root.contentY = top;
            else if (top + root.cellHeight > root.contentY + root.height)
                root.contentY = top + root.cellHeight - root.height;
        }
    }

    Grid {
        id: grid

        columns: root.columns
        spacing: Tokens.wallpaper.gap

        Repeater {
            model: Services.Wallpaper.files

            Item {
                id: cell

                required property string modelData
                required property int index

                readonly property bool selected: index === Services.Wallpaper.selected
                readonly property bool current: modelData === Services.Wallpaper.path

                width: Tokens.wallpaper.thumbWidth
                height: root.cellHeight

                ClippingRectangle {
                    id: thumb

                    width: parent.width
                    height: Tokens.wallpaper.thumbHeight

                    radius: Tokens.side.rowRadius
                    color: Appearance.cell

                    Image {
                        anchors.fill: parent

                        source: `file://${cell.modelData}`
                        sourceSize.width: width
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Rectangle {
                    anchors.fill: thumb

                    radius: thumb.radius
                    color: "transparent"
                    border.width: cell.selected ? 2 : 0
                    border.color: Appearance.accent
                }

                RowLayout {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: Math.min(implicitWidth, parent.width)
                    height: Tokens.wallpaper.labelHeight

                    spacing: Tokens.space.tight

                    MaterialIcon {
                        visible: cell.current

                        text: "check_circle"
                        color: Appearance.accent
                    }

                    Text {
                        Layout.fillWidth: true

                        text: Services.Wallpaper.title(cell.modelData)
                        color: cell.current ? Appearance.accent : cell.selected ? Appearance.text : Appearance.dim
                        elide: Text.ElideRight

                        font.family: Tokens.font.ui
                        font.pixelSize: Tokens.font.size.normal
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: Services.Wallpaper.selected = cell.index
                    onClicked: Services.Wallpaper.apply(cell.index)
                }
            }
        }
    }
}
