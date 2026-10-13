// A section of the top rail that drops down to hold widgets. A pod that meets
// a side rail (`joinsLeft`/`joinsRight`) keeps that side square.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config

Item {
    id: root

    required property list<string> widgets

    required property var registry

    property bool joinsLeft: false
    property bool joinsRight: false

    property int padding: Tokens.space.pod
    property int spacing: Tokens.space.item

    // Whole pixels, or the edges against the rail and corners blur into a
    // seam under fractional scaling.
    implicitWidth: Math.ceil(row.implicitWidth) + padding * 2
    implicitHeight: Tokens.frame.pod

    Rectangle {
        anchors.fill: parent

        color: Appearance.panel

        bottomLeftRadius: root.joinsLeft ? 0 : Tokens.frame.sweep
        bottomRightRadius: root.joinsRight ? 0 : Tokens.frame.sweep
    }

    InverseCorner {
        visible: !root.joinsLeft

        bite: InverseCorner.Bite.BottomLeft
        size: Tokens.frame.sweep

        x: -width
        y: Tokens.frame.thickness
    }

    InverseCorner {
        visible: !root.joinsRight

        bite: InverseCorner.Bite.BottomRight
        size: Tokens.frame.sweep

        x: root.width
        y: Tokens.frame.thickness
    }

    RowLayout {
        id: row

        // Centered on the whole pod, rail included, so top and bottom padding match.
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding

        spacing: root.spacing

        Repeater {
            model: root.widgets

            Loader {
                required property string modelData

                // A widget with nothing to show sets `shown` false, so it gives
                // up its width and spacing slot. Not `item.visible`, which
                // follows the Loader's own and would never come back.
                visible: item?.shown ?? true

                sourceComponent: root.registry[modelData] ?? null
            }
        }
    }
}
