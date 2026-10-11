// One screen's frozen image to pick a screenshot from. Outside the target is
// dimmed: the dragged region, else the window under the cursor, else the
// whole screen.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services as Services

ShellWindow {
    id: root

    required property var modelData

    readonly property bool focused: Services.Screenshot.focusedScreen === modelData.name

    property bool hovered: false
    property point cursor: Qt.point(0, 0)
    property point anchor: Qt.point(0, 0)
    property bool dragging: false

    readonly property rect region: Qt.rect(Math.min(anchor.x, cursor.x), Math.min(anchor.y, cursor.y), Math.abs(cursor.x - anchor.x), Math.abs(cursor.y - anchor.y))

    // The window under the cursor, clipped to this screen.
    readonly property var window: {
        const x = cursor.x + modelData.x;
        const y = cursor.y + modelData.y;
        const hit = Services.Screenshot.windows.find(w => x >= w.x && x < w.x + w.width && y >= w.y && y < w.y + w.height);
        if (!hit)
            return null;
        const left = Math.max(0, hit.x - modelData.x);
        const top = Math.max(0, hit.y - modelData.y);
        return Qt.rect(left, top, Math.min(width, hit.x - modelData.x + hit.width) - left, Math.min(height, hit.y - modelData.y + hit.height) - top);
    }

    readonly property rect target: dragging ? region : hovered && window ? window : Qt.rect(0, 0, width, height)
    readonly property bool showTarget: dragging || hovered

    function shoot(): void {
        if (target.width >= 1 && target.height >= 1)
            Services.Screenshot.capture(modelData.name, target);
    }

    name: "screenshot"
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: focused ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Image {
        anchors.fill: parent

        source: `file://${Services.Screenshot.frozen(root.modelData.name)}`
        fillMode: Image.Stretch
        cache: false
    }

    // The dim, in four pieces around the target.
    Item {
        anchors.fill: parent

        readonly property rect hole: root.showTarget ? root.target : Qt.rect(0, 0, 0, 0)
        readonly property color shade: Qt.rgba(0, 0, 0, 0.45)

        Rectangle {
            width: parent.width
            height: parent.hole.y
            color: parent.shade
        }

        Rectangle {
            y: parent.hole.y + parent.hole.height
            width: parent.width
            height: parent.height - y
            color: parent.shade
        }

        Rectangle {
            y: parent.hole.y
            width: parent.hole.x
            height: parent.hole.height
            color: parent.shade
        }

        Rectangle {
            x: parent.hole.x + parent.hole.width
            y: parent.hole.y
            width: parent.width - x
            height: parent.hole.height
            color: parent.shade
        }
    }

    Rectangle {
        visible: root.showTarget

        x: root.target.x
        y: root.target.y
        width: root.target.width
        height: root.target.height

        color: "transparent"
        border.width: 2
        border.color: Appearance.accent
    }

    Pill {
        visible: root.dragging

        x: Math.min(root.target.x, root.width - width - 8)
        y: root.target.y + root.target.height + 8 + height < root.height ? root.target.y + root.target.height + 8 : root.target.y - height - 8

        color: Appearance.panel

        Text {
            text: `${Math.round(root.target.width)} × ${Math.round(root.target.height)}`
            color: Appearance.text

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }

    Pill {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        visible: root.focused && !root.dragging

        implicitHeight: Tokens.pill.height + 10
        color: Appearance.panel

        MaterialIcon {
            text: Services.Screenshot.mode === "edit" ? "edit" : "screenshot_region"
            color: Appearance.accent
        }

        Text {
            text: "Drag a region · Click a window or the screen · Esc or right click to cancel"
            color: Appearance.dim

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.CrossCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onPositionChanged: mouse => {
            root.hovered = true;
            root.cursor = Qt.point(mouse.x, mouse.y);
            if (pressed && !root.dragging && (Math.abs(mouse.x - root.anchor.x) > 4 || Math.abs(mouse.y - root.anchor.y) > 4))
                root.dragging = true;
        }

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton)
                Services.Screenshot.cancel();
            else
                root.anchor = Qt.point(mouse.x, mouse.y);
        }

        onReleased: mouse => {
            if (mouse.button !== Qt.LeftButton)
                return;
            root.shoot();
            root.dragging = false;
        }
    }

    Item {
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape)
                Services.Screenshot.cancel();
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                root.shoot();
            else
                return;
            event.accepted = true;
        }
    }
}
