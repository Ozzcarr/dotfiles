// The panel that grows out of the center pod. It morphs between the sizes of
// whatever it holds, so switching panels reshapes it instead of closing one
// and opening another. Sits behind the pod in the frame layer, so the clock
// stays on top as the header.
import QtQuick
import qs.components
import qs.config
import qs.surfaces.frame.dashboard
import qs.surfaces.frame.launcher
import qs.surfaces.frame.osd
import qs.surfaces.frame.session

Item {
    id: root

    // "dashboard", "launcher", "session", "osd", or "" when closed.
    property string panel: ""

    // Size of the pod it grows from.
    required property int collapsedWidth
    property int maxWidth: Tokens.dashboard.width

    readonly property bool expanded: height > Tokens.frame.pod + 1
    readonly property int contentTop: Tokens.frame.pod + Tokens.dashboard.padding / 2

    width: {
        switch (panel) {
        case "dashboard":
            return Math.min(Tokens.dashboard.width, maxWidth);
        case "launcher":
            return Tokens.launcher.width;
        case "session":
            return Tokens.session.width;
        case "osd":
            return Tokens.osd.width;
        default:
            return collapsedWidth;
        }
    }

    height: {
        switch (panel) {
        case "dashboard":
            return Tokens.dashboard.height;
        case "launcher":
            return contentTop + launcher.implicitHeight + Tokens.launcher.padding;
        case "session":
            return contentTop + Tokens.session.buttonHeight + Tokens.session.padding;
        case "osd":
            return contentTop + Tokens.osd.height + Tokens.dashboard.padding / 2;
        default:
            return Tokens.frame.pod;
        }
    }

    visible: expanded

    Behavior on width {
        Anim {}
    }

    Behavior on height {
        Anim {}
    }

    // Swallows clicks on empty parts, which would otherwise reach the
    // full-screen close handler behind it.
    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent

        color: Appearance.panel

        bottomLeftRadius: Tokens.frame.radius
        bottomRightRadius: Tokens.frame.radius
    }

    InverseCorner {
        bite: InverseCorner.Bite.BottomLeft
        size: Tokens.frame.sweep

        x: -width
        y: Tokens.frame.thickness
    }

    InverseCorner {
        bite: InverseCorner.Bite.BottomRight
        size: Tokens.frame.sweep

        x: root.width
        y: Tokens.frame.thickness
    }

    // Contents are laid out at their final size, centered, and revealed by the
    // growing shape. Switching cross-fades them while the shape morphs.
    Item {
        anchors.fill: parent

        clip: true

        Loader {
            anchors.horizontalCenter: parent.horizontalCenter

            y: root.contentTop
            width: Tokens.dashboard.width - 2 * Tokens.dashboard.padding
            height: Tokens.dashboard.height - y - Tokens.dashboard.padding

            active: root.expanded
            visible: opacity > 0
            opacity: root.panel === "dashboard" ? 1 : 0

            PanelFade on opacity {}

            sourceComponent: Dashboard {}
        }

        LauncherPanel {
            id: launcher

            anchors.horizontalCenter: parent.horizontalCenter

            y: root.contentTop
            width: Tokens.launcher.width - 2 * Tokens.launcher.padding

            visible: opacity > 0
            opacity: root.panel === "launcher" ? 1 : 0

            PanelFade on opacity {}
        }

        SessionPanel {
            anchors.horizontalCenter: parent.horizontalCenter

            y: root.contentTop

            visible: opacity > 0
            opacity: root.panel === "session" ? 1 : 0

            PanelFade on opacity {}
        }

        OsdPanel {
            anchors.horizontalCenter: parent.horizontalCenter

            y: root.contentTop
            width: Tokens.osd.width - 2 * Tokens.osd.padding
            height: Tokens.osd.height

            visible: opacity > 0
            opacity: root.panel === "osd" ? 1 : 0

            PanelFade on opacity {}
        }
    }
}
