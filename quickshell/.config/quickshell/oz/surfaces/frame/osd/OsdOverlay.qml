// The on-screen display on its own, for when a fullscreen window covers the
// frame. It sits on the overlay layer, above the game, and takes no input.
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config

ShellWindow {
    id: root

    name: "osd"

    anchors.top: true
    margins.top: Tokens.osd.padding

    implicitWidth: Tokens.osd.width
    implicitHeight: Tokens.osd.height + 2 * Tokens.osd.padding

    exclusionMode: ExclusionMode.Ignore
    mask: Region {}

    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: pill

        anchors.fill: parent

        radius: Tokens.frame.radius
        color: Appearance.panel
        opacity: 0

        Component.onCompleted: opacity = Tokens.opacity.panel

        Behavior on opacity {
            Anim {
                duration: Motion.fast
            }
        }

        OsdPanel {
            anchors.fill: parent
            anchors.margins: Tokens.osd.padding
        }
    }
}
