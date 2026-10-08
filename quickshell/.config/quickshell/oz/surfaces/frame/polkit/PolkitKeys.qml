// The real password field for the polkit prompt, in the frame's keyboard
// surface; the panel shows it as dots.
import QtQuick
import qs.services as Services

TextInput {
    focus: true
    text: Services.Polkit.password
    readOnly: Services.Polkit.checking

    onTextEdited: Services.Polkit.password = text

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            Services.Polkit.cancel();
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            Services.Polkit.submit();
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
