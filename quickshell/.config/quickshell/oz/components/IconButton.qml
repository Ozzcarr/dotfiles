import QtQuick
import qs.config

MaterialIcon {
    id: root

    property string icon
    property color tint: Appearance.dim
    property color hoverTint: Appearance.text

    signal activated

    text: icon
    color: area.containsMouse ? hoverTint : tint

    Behavior on color {
        ColorAnimation {
            duration: Motion.fast
            easing.type: Easing.Bezier
            easing.bezierCurve: Motion.curve
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent

        hoverEnabled: true

        onClicked: root.activated()
    }
}
