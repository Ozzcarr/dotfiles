// Keyboard for the wallpaper picker, in the frame's keyboard surface.
import QtQuick
import qs.config
import qs.services as Services

Item {
    readonly property int columns: Math.max(1, Math.min(Services.Wallpaper.files.length, Tokens.wallpaper.columns))

    focus: true

    Component.onCompleted: Services.Wallpaper.scan()

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            Services.Panels.close();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            Services.Wallpaper.apply(Services.Wallpaper.selected);
            break;
        case Qt.Key_Left:
        case Qt.Key_H:
        case Qt.Key_Backtab:
            Services.Wallpaper.move(-1);
            break;
        case Qt.Key_Right:
        case Qt.Key_L:
        case Qt.Key_Tab:
            Services.Wallpaper.move(1);
            break;
        case Qt.Key_Up:
        case Qt.Key_K:
            Services.Wallpaper.move(-columns);
            break;
        case Qt.Key_Down:
        case Qt.Key_J:
            Services.Wallpaper.move(columns);
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
