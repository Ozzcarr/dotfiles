// The column that grows down out of the right pod, attached to the right rail.
// It holds the notification center or quick settings, and shows notification
// popups when neither is open.
import QtQuick
import qs.components
import qs.config
import qs.services as Services
import qs.surfaces.frame.notifications
import qs.surfaces.frame.settings

Item {
    id: root

    // "notifications", "settings", or "" when closed.
    property string panel: ""
    property bool showPopups: false

    // Size of the pod it grows from.
    required property int collapsedWidth

    readonly property string shown: panel !== "" ? panel : showPopups && Services.Notifications.popups.length > 0 ? "popups" : ""
    readonly property Item content: shown === "settings" ? settings : notifications
    readonly property int pad: Tokens.side.padding
    readonly property int contentTop: Tokens.frame.pod + pad / 2
    readonly property int contentWidth: Tokens.side.width - 2 * pad
    readonly property int maxContentHeight: Tokens.side.maxHeight - contentTop - pad

    width: shown !== "" ? Tokens.side.width : collapsedWidth
    height: shown !== "" ? Math.min(contentTop + content.implicitHeight + pad, Tokens.side.maxHeight) : Tokens.frame.pod

    visible: height > Tokens.frame.pod + 1

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
    }

    // Into the top rail on the left, into the right rail below.
    InverseCorner {
        bite: InverseCorner.Bite.BottomLeft
        size: Tokens.frame.sweep

        x: -width
        y: Tokens.frame.thickness
    }

    InverseCorner {
        bite: InverseCorner.Bite.BottomLeft

        x: root.width - Tokens.frame.thickness - width
        y: root.height
    }

    // Laid out at the final width, against the right edge, and revealed by
    // the growing shape.
    Item {
        anchors.fill: parent

        clip: true

        NotificationsPanel {
            id: notifications

            anchors.right: parent.right
            anchors.rightMargin: root.pad

            y: root.contentTop
            width: root.contentWidth

            center: root.shown === "notifications"
            maxHeight: root.maxContentHeight

            visible: opacity > 0
            opacity: root.shown === "notifications" || root.shown === "popups" ? 1 : 0

            PanelFade on opacity {}
        }

        SettingsPanel {
            id: settings

            anchors.right: parent.right
            anchors.rightMargin: root.pad

            y: root.contentTop
            width: root.contentWidth
            maxHeight: root.maxContentHeight

            visible: opacity > 0
            opacity: root.shown === "settings" ? 1 : 0

            PanelFade on opacity {}
        }
    }
}
