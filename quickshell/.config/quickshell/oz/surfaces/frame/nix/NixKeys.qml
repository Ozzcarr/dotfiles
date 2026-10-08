// Keyboard for the NixOS panel, in the frame's keyboard surface. Up and down
// move in the focused side, left and right switch sides, Tab switches views.
// Enter runs an operation, diffs a generation or checks for updates again;
// Space marks a generation to diff against. In the updates and output views,
// up and down scroll.
import QtQuick
import qs.services as Services

Item {
    readonly property var nix: Services.Nix

    function vertical(delta: int): void {
        if (!nix.inView)
            nix.moveAction(delta);
        else if (nix.view === "generations")
            nix.moveGeneration(delta);
        else
            nix.scroll(delta * 3);
    }

    focus: true

    Component.onCompleted: nix.reset()

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Escape:
            if (nix.confirming !== "")
                nix.confirming = "";
            else
                Services.Panels.close();
            break;
        case Qt.Key_Up:
        case Qt.Key_K:
            vertical(-1);
            break;
        case Qt.Key_Down:
        case Qt.Key_J:
            vertical(1);
            break;
        case Qt.Key_PageUp:
            nix.scroll(-15);
            break;
        case Qt.Key_PageDown:
            nix.scroll(15);
            break;
        case Qt.Key_Left:
        case Qt.Key_H:
            nix.inView = false;
            break;
        case Qt.Key_Right:
        case Qt.Key_L:
            nix.inView = true;
            nix.confirming = "";
            break;
        case Qt.Key_Tab:
            nix.cycleView(1);
            break;
        case Qt.Key_Backtab:
            nix.cycleView(-1);
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            if (!nix.inView)
                nix.start(nix.operations[nix.action].key);
            else if (nix.view === "generations")
                nix.diff();
            else if (nix.view === "updates")
                Services.Updates.check();
            break;
        case Qt.Key_Space:
            if (nix.inView && nix.view === "generations")
                nix.mark(nix.generation);
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
