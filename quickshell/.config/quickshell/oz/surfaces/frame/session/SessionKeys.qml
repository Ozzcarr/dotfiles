// Keyboard for the session menu, in the frame's keyboard surface.
import QtQuick
import qs.services as Services

Item {
    focus: true

    Component.onCompleted: Services.Session.reset()

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            Services.Panels.close();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            Services.Session.activate(Services.Session.current);
            break;
        case Qt.Key_Left:
        case Qt.Key_H:
        case Qt.Key_Backtab:
            Services.Session.move(-1);
            break;
        case Qt.Key_Right:
        case Qt.Key_L:
        case Qt.Key_Tab:
            Services.Session.move(1);
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
