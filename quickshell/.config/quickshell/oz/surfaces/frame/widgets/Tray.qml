// Right click opens the item's menu; menu-only items open it on any click.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.components
import qs.config

Pill {
    id: root

    property bool expanded: false

    visible: SystemTray.items.values.length > 0

    // Hidden when closed, or its spacing slot pushes the chevron off center.
    Item {
        Layout.alignment: Qt.AlignVCenter

        visible: implicitWidth > 0

        implicitWidth: root.expanded ? icons.implicitWidth : 0
        implicitHeight: icons.implicitHeight

        clip: true

        Behavior on implicitWidth {
            Anim {}
        }

        RowLayout {
            id: icons

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            spacing: Tokens.space.tight

            Repeater {
                model: SystemTray.items

                MouseArea {
                    id: entry

                    required property SystemTrayItem modelData

                    Layout.alignment: Qt.AlignVCenter

                    implicitWidth: Tokens.icon.tray
                    implicitHeight: Tokens.icon.tray

                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                    onClicked: event => {
                        const item = entry.modelData;
                        if (event.button === Qt.RightButton || item.onlyMenu) {
                            if (item.hasMenu)
                                menu.open();
                        } else if (event.button === Qt.MiddleButton) {
                            item.secondaryActivate();
                        } else {
                            item.activate();
                        }
                    }

                    IconImage {
                        anchors.fill: parent

                        source: entry.modelData.icon
                    }

                    QsMenuAnchor {
                        id: menu

                        menu: entry.modelData.menu

                        anchor.item: entry
                        anchor.edges: Edges.Bottom
                        anchor.gravity: Edges.Bottom
                    }
                }
            }
        }
    }

    IconButton {
        icon: root.expanded ? "chevron_right" : "chevron_left"

        onActivated: root.expanded = !root.expanded
    }
}
