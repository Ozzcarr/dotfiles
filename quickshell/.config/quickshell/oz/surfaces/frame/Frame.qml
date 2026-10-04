// A thin frame around the screen that drops into pods where there is content.
// It reserves no space itself: gaps_out in looknfeel.lua leaves room for it.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services as Services
import qs.surfaces.frame.launcher
import qs.surfaces.frame.notifications
import qs.surfaces.frame.widgets

ShellWindow {
    id: root

    required property var modelData

    readonly property int t: Tokens.frame.thickness
    readonly property bool panelOpen: Services.Panels.screen === modelData.name
    readonly property bool launcherOpen: panelOpen && Services.Panels.panel === "launcher"

    // The notification center lives in its own column, so Drop can show the
    // on-screen display meanwhile.
    readonly property string dropPanel: {
        if (panelOpen && Services.Panels.panel !== "notifications")
            return Services.Panels.panel;
        return Services.Osd.visible && Services.Panels.focusedScreen === modelData.name ? "osd" : "";
    }

    // BarLayout lists widgets by name; this maps each name to its component.
    readonly property var registry: ({
            workspaces: workspacesWidget,
            clock: clockWidget,
            tray: trayWidget,
            status: statusWidget,
            session: sessionWidget
        })

    name: "frame"
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore

    // Only the pods take input; the rest of the frame is click-through.
    mask: Region {
        Region {
            item: leftPod
        }

        Region {
            item: centerPod
        }

        Region {
            item: drop
        }

        Region {
            item: notifications
        }

        Region {
            item: rightPod
        }

        // While a panel is open the whole screen takes input, so a click
        // anywhere else can close it.
        Region {
            width: root.panelOpen ? root.width : 0
            height: root.panelOpen ? root.height : 0
        }
    }

    Component {
        id: workspacesWidget

        Workspaces {
            screen: root.screen
        }
    }

    Component {
        id: clockWidget

        Clock {
            screen: root.screen
        }
    }

    Component {
        id: trayWidget

        Tray {}
    }

    Component {
        id: statusWidget

        StatusCluster {}
    }

    Component {
        id: sessionWidget

        Session {}
    }

    MouseArea {
        anchors.fill: parent

        enabled: root.panelOpen

        onClicked: Services.Panels.close()
    }

    // Drawn opaque and made translucent as one layer, so overlapping pieces
    // don't darken where they meet.
    Item {
        anchors.fill: parent

        layer.enabled: true
        opacity: Tokens.opacity.panel

        // First, so the pods draw over the panels when they open wide.
        Drop {
            id: drop

            panel: root.dropPanel
            collapsedWidth: centerPod.width
            maxWidth: parent.width - 2 * root.t

            x: Math.round((parent.width - width) / 2)
        }

        NotificationColumn {
            id: notifications

            open: root.panelOpen && Services.Panels.panel === "notifications"
            showPopups: Services.Panels.focusedScreen === root.modelData.name
            collapsedWidth: rightPod.width

            x: parent.width - width
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: root.t
            color: Appearance.panel
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            height: root.t
            color: Appearance.panel
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            width: root.t
            color: Appearance.panel
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            width: root.t
            color: Appearance.panel
        }

        Pod {
            id: leftPod

            widgets: BarLayout.left
            registry: root.registry

            joinsLeft: true
        }

        Pod {
            id: centerPod

            widgets: BarLayout.center
            registry: root.registry

            x: Math.round((parent.width - width) / 2)
        }

        Pod {
            id: rightPod


            widgets: BarLayout.right
            registry: root.registry

            joinsRight: true

            x: parent.width - width
        }

        // Where a wide panel runs under a corner pod, round the corner
        // between the pod's bottom edge and the panel's side.
        InverseCorner {
            visible: drop.visible && drop.x < leftPod.width

            bite: InverseCorner.Bite.BottomLeft
            size: Tokens.frame.sweep

            x: drop.x - width
            y: leftPod.height
        }

        InverseCorner {
            visible: drop.visible && drop.x + drop.width > rightPod.x

            bite: InverseCorner.Bite.BottomRight
            size: Tokens.frame.sweep

            x: drop.x + drop.width
            y: rightPod.height
        }

        // Inner corners. The top two sit below the corner pods.
        InverseCorner {
            bite: InverseCorner.Bite.BottomRight

            x: root.t
            y: leftPod.height
        }

        InverseCorner {
            bite: InverseCorner.Bite.BottomLeft

            x: parent.width - root.t - width
            y: rightPod.height
        }

        InverseCorner {
            bite: InverseCorner.Bite.TopRight

            x: root.t
            y: parent.height - root.t - height
        }

        InverseCorner {
            bite: InverseCorner.Bite.TopLeft

            x: parent.width - root.t - width
            y: parent.height - root.t - height
        }
    }

    // Holds the keyboard while a panel is open. It is its own surface because
    // Hyprland gives focus back to the previous window when a focused surface
    // goes away, but not when one merely stops taking the keyboard. On demand,
    // not exclusive: Hyprland sends all pointer input to exclusive surfaces,
    // which would leave the panels unclickable.
    LazyLoader {
        active: root.panelOpen

        ShellWindow {
            name: "keys"
            screen: root.modelData

            implicitWidth: 1
            implicitHeight: 1

            exclusionMode: ExclusionMode.Ignore
            mask: Region {}

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            Loader {
                anchors.fill: parent

                focus: true
                sourceComponent: root.launcherOpen ? launcherKeys : escapeKeys
            }

            Component {
                id: launcherKeys

                LauncherKeys {}
            }

            Component {
                id: escapeKeys

                Item {
                    focus: true

                    Keys.onEscapePressed: Services.Panels.close()
                }
            }
        }
    }
}
