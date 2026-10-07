// Keyboard for quick settings, in the frame's keyboard surface. Arrows or hjkl
// move and adjust, Enter acts, Delete forgets, Esc and Backspace step back.
// While the Wi-Fi prompt is open, typing goes into it instead.
import QtQuick
import qs.services as Services

TextInput {
    id: root

    readonly property var wifi: Services.Wifi
    readonly property var nav: Services.SettingsNav
    readonly property bool typing: wifi.prompting !== null

    function back(): void {
        if (Services.Panels.page !== "")
            Services.Panels.page = "";
        else
            Services.Panels.close();
    }

    focus: true
    text: wifi.field === "identity" ? wifi.identity : wifi.password

    onTextEdited: {
        if (!root.typing)
            return;
        if (wifi.field === "identity")
            wifi.identity = text;
        else
            wifi.password = text;
    }

    Keys.onPressed: event => {
        if (root.typing) {
            switch (event.key) {
            case Qt.Key_Escape:
                wifi.cancel();
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
                wifi.submit();
                break;
            case Qt.Key_Tab:
            case Qt.Key_Backtab:
                if (wifi.enterprise)
                    wifi.field = wifi.field === "identity" ? "password" : "identity";
                break;
            default:
                return;
            }
            event.accepted = true;
            return;
        }

        switch (event.key) {
        case Qt.Key_Escape:
        case Qt.Key_Backspace:
            root.back();
            break;
        case Qt.Key_Up:
        case Qt.Key_K:
        case Qt.Key_Backtab:
            nav.move(-1);
            break;
        case Qt.Key_Down:
        case Qt.Key_J:
        case Qt.Key_Tab:
            nav.move(1);
            break;
        case Qt.Key_Left:
        case Qt.Key_H:
            if (!nav.step(-1))
                root.back();
            break;
        case Qt.Key_Right:
        case Qt.Key_L:
            nav.step(1);
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:
            if (!nav.activate())
                nav.move(1);
            break;
        case Qt.Key_Delete:
        case Qt.Key_X:
            nav.secondary();
            break;
        }
        // Nothing reaches the hidden field unless the prompt is open.
        event.accepted = true;
    }
}
