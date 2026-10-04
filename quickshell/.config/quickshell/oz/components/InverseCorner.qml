// A square with a quarter circle cut out of it, used to round inner corners
// and to blend pods into the rail. `bite` names the corner that is cut.
import QtQuick
import QtQuick.Shapes
import qs.config

Shape {
    id: root

    enum Bite {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }

    property int bite: InverseCorner.Bite.BottomRight
    property int size: Tokens.frame.radius
    property color fill: Appearance.panel

    implicitWidth: size
    implicitHeight: size

    preferredRendererType: Shape.CurveRenderer

    // The path cuts the bottom right; Qt rotates clockwise.
    rotation: switch (bite) {
    case InverseCorner.Bite.BottomRight:
        0;
        break;
    case InverseCorner.Bite.BottomLeft:
        90;
        break;
    case InverseCorner.Bite.TopLeft:
        180;
        break;
    default:
        270;
    }

    ShapePath {
        fillColor: root.fill
        strokeWidth: 0

        startX: 0
        startY: 0

        PathLine {
            x: root.size
            y: 0
        }

        PathArc {
            x: 0
            y: root.size

            radiusX: root.size
            radiusY: root.size

            // Clockwise picks the other center and draws a solid quarter circle.
            direction: PathArc.Counterclockwise
        }

        PathLine {
            x: 0
            y: 0
        }
    }
}
