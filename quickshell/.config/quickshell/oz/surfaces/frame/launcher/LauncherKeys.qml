// The real search field. It lives in the frame's keyboard surface, which only
// exists while a panel is open; the launcher shows a mirror of it.
import QtQuick
import qs.config
import qs.services as Services
import qs.services.launcher

TextInput {
    id: root


    focus: true
    text: Launcher.query

    onTextEdited: {
        if (Launcher.mode.name === "apps" && text.length === 1 && Launcher.switchByPrefix(text))
            clear();
        else
            Launcher.query = text;
    }

    onCursorPositionChanged: Launcher.cursor = cursorPosition
    onSelectionStartChanged: Launcher.selectionStart = selectionStart
    onSelectionEndChanged: Launcher.selectionEnd = selectionEnd

    Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier;
        const rows = Tokens.launcher.rows;

        switch (event.key) {
        case Qt.Key_Escape:
            Services.Panels.close();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            Launcher.activate(Launcher.current);
            break;
        case Qt.Key_Down:
        case Qt.Key_Tab:
            Launcher.move(1);
            break;
        case Qt.Key_Up:
        case Qt.Key_Backtab:
            Launcher.move(-1);
            break;
        case Qt.Key_PageUp:
            Launcher.move(-rows);
            break;
        case Qt.Key_PageDown:
            Launcher.move(rows);
            break;
        case Qt.Key_K:
        case Qt.Key_P:
            if (!ctrl)
                return;
            Launcher.move(-1);
            break;
        case Qt.Key_J:
        case Qt.Key_N:
            if (!ctrl)
                return;
            Launcher.move(1);
            break;
        case Qt.Key_Backspace:
            if (text !== "" || Launcher.mode.name === "apps")
                return;
            Launcher.begin("apps");
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
