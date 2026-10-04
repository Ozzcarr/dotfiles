// Runs the search as a shell command; Shift+Enter keeps it in a terminal.
import Quickshell

Mode {
    name: "run"
    prefix: ">"
    short: "run"
    label: "Run"
    icon: "terminal"
    placeholder: "Run a command"
    emptyHint: "Type a shell command"

    results: {
        const command = Launcher.query.trim();
        if (!command)
            return [];

        return [
            {
                key: "run",
                title: command,
                subtitle: "Enter runs it, Shift+Enter in a terminal",
                glyph: "terminal",
                run: alt => alt ? Quickshell.execDetached([Launcher.terminal, "--hold", "sh", "-c", command]) : Launcher.exec(command)
            }
        ];
    }
}
