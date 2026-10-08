// Values marked SHARED are mirrored in hypr/config/looknfeel.lua.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property QtObject radius: QtObject {
        readonly property int cell: 5
    }

    readonly property QtObject space: QtObject {
        readonly property int pod: 12
        readonly property int item: 10
        readonly property int tight: 5
    }

    readonly property QtObject frame: QtObject {
        readonly property int thickness: 4 // SHARED
        readonly property int pod: 26 // SHARED
        readonly property int gap: 6 // SHARED
        readonly property int windowRadius: 14 // SHARED

        // Concentric with the corners of the windows inside it.
        readonly property int radius: windowRadius + gap
        readonly property int sweep: 12
    }

    readonly property QtObject opacity: QtObject {
        readonly property real panel: 0.82
        readonly property real cell: 0.55
    }

    // Even sizes, so they center on whole pixels in the pod.
    readonly property QtObject workspace: QtObject {
        readonly property int size: 18
    }

    readonly property QtObject pill: QtObject {
        readonly property int height: 20
        readonly property int padding: 7
    }

    readonly property QtObject dashboard: QtObject {
        readonly property int height: 330
        readonly property int padding: 16
        readonly property int gap: 12
        readonly property int cardRadius: 14
        readonly property int cardPadding: 14

        readonly property int calendarWidth: 280
        readonly property int systemWidth: 260
        readonly property int mediaWidth: 340
        readonly property int art: 120
        readonly property int artGap: 14
        readonly property int width: calendarWidth + mediaWidth + systemWidth + 2 * gap + 2 * padding
    }

    readonly property QtObject launcher: QtObject {
        readonly property int width: 620
        readonly property int padding: 12
        readonly property int gap: 8
        readonly property int rows: 7
        readonly property int rowHeight: 48
        readonly property int rowRadius: 12
        readonly property int inputHeight: 42
        readonly property int iconSize: 30
    }

    readonly property QtObject osd: QtObject {
        readonly property int width: 260
        readonly property int height: 28
        readonly property int padding: 14
    }

    readonly property QtObject session: QtObject {
        readonly property int buttonWidth: 92
        readonly property int buttonHeight: 84
        readonly property int gap: 8
        readonly property int padding: 14
        readonly property int width: 5 * buttonWidth + 4 * gap + 2 * padding
    }

    readonly property QtObject lock: QtObject {
        readonly property int clockSize: 112
        readonly property int fieldWidth: 320
        readonly property int fieldHeight: 46
        readonly property real blur: 1
        readonly property real dim: 0.2
    }

    // The right column: notifications and quick settings.
    readonly property QtObject side: QtObject {
        readonly property int width: 400
        readonly property int padding: 12
        readonly property int gap: 8
        readonly property int maxHeight: 680
        readonly property int rowHeight: 40
        readonly property int rowRadius: 12
    }

    readonly property QtObject notifications: QtObject {
        readonly property int cardRadius: 14
        readonly property int cardPadding: 12
        readonly property int iconSize: 36
        // For notifications that don't set their own timeout.
        readonly property int timeout: 6000
    }

    readonly property QtObject icon: QtObject {
        readonly property int glyph: 15
        readonly property int tray: 14
        readonly property int control: 22
    }

    readonly property QtObject motion: QtObject {
        readonly property list<real> bezier: [0.2, 0.0, 0.0, 1.0] // SHARED
        readonly property int fast: 150
        readonly property int normal: 250
    }

    readonly property QtObject font: QtObject {
        readonly property string ui: "Inter"
        readonly property string mono: "Maple Mono NF"
        readonly property string icon: "Material Symbols Rounded"

        readonly property QtObject size: QtObject {
            readonly property int small: 10
            readonly property int normal: 12
            readonly property int large: 14
            readonly property int title: 16
            readonly property int display: 34
        }
    }
}
