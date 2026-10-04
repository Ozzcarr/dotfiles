// Evaluates the search with qalc, which also converts units and currencies.
import QtQuick
import Quickshell.Io

Mode {
    id: root

    property string answer: ""

    name: "calc"
    prefix: "="
    short: "calc"
    label: "Calculator"
    icon: "calculate"
    placeholder: "Calculate"
    emptyHint: "Type an expression, like 4 * 12 or 3 ft to cm"

    results: Launcher.query.trim() ? [
        {
            key: "calc",
            title: root.answer || "…",
            subtitle: "Enter to copy",
            glyph: "calculate",
            run: () => Launcher.copy(root.answer)
        }
    ] : []

    onOpened: root.answer = ""

    // Waits for a pause in typing rather than running qalc on every key.
    Timer {
        id: debounce

        interval: 120

        onTriggered: {
            const expression = Launcher.query.trim();
            if (!expression) {
                root.answer = "";
                return;
            }
            qalc.command = ["qalc", "-t", expression];
            qalc.running = true;
        }
    }

    Connections {
        target: Launcher

        function onQueryChanged(): void {
            if (Launcher.mode === root)
                debounce.restart();
        }
    }

    Process {
        id: qalc

        stdout: StdioCollector {
            onStreamFinished: root.answer = text.trim()
        }
    }
}
