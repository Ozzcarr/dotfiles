pragma Singleton

import QtQuick
import Quickshell
import qs.generated
import qs.services as Services

Singleton {
    readonly property color text: Scheme.base05
    readonly property color dim: Qt.rgba(text.r + (panel.r - text.r) * 0.35, text.g + (panel.g - text.g) * 0.35, text.b + (panel.b - text.b) * 0.35, 1)
    readonly property color faint: Qt.rgba(text.r + (panel.r - text.r) * 0.55, text.g + (panel.g - text.g) * 0.55, text.b + (panel.b - text.b) * 0.55, 1)

    readonly property color accent: Services.Wallpaper.accent
    readonly property color accentAlt: Services.Wallpaper.accentAlt
    readonly property color onAccent: Scheme.base00

    // The accent pulled toward dim. Inline because wrapping it in a function
    // made the binding render black.
    readonly property color soft: Qt.rgba(dim.r + (accent.r - dim.r) * 0.6, dim.g + (accent.g - dim.g) * 0.6, dim.b + (accent.b - dim.b) * 0.6, 1)

    readonly property color warning: Scheme.base0A
    readonly property color danger: Scheme.base08

    // Opaque: the frame applies Tokens.opacity.panel once to the whole layer.
    readonly property color panel: Scheme.base01
    readonly property color cell: Qt.alpha(Scheme.base02, Tokens.opacity.cell)
}
