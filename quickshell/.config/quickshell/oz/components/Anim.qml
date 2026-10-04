// The shell's standard motion: `Behavior on width { Anim {} }`.
import QtQuick
import qs.config

NumberAnimation {
    duration: Motion.normal
    easing.type: Easing.Bezier
    easing.bezierCurve: Motion.curve
}
