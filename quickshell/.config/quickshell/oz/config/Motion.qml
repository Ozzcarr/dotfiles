pragma Singleton

import Quickshell

Singleton {
    readonly property int fast: Tokens.motion.fast
    readonly property int normal: Tokens.motion.normal

    // Easing.Bezier takes the control points followed by the (1, 1) endpoint.
    readonly property var curve: [...Tokens.motion.bezier, 1, 1]
}
