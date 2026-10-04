// Installed applications, ranked by match and by how often and recently
// each was launched from here.
import QtQuick
import Quickshell
import Quickshell.Io

Mode {
    id: root

    name: "apps"
    label: "Apps"
    icon: "apps"
    placeholder: "Search apps"

    results: {
        const items = DesktopEntries.applications.values.filter(entry => !entry.noDisplay).map(entry => {
            const frecency = root.frecency(entry.id);
            return {
                key: `app:${entry.id}`,
                title: entry.name,
                subtitle: entry.comment || entry.genericName,
                icon: entry.icon,
                generic: entry.genericName,
                keywords: entry.keywords.join(" "),
                frecency: frecency,
                boost: 25 * Math.log2(1 + frecency),
                run: () => root.launch(entry)
            };
        });

        if (!Launcher.query.trim())
            return items.sort((a, b) => b.frecency - a.frecency || a.title.localeCompare(b.title));

        return Launcher.rank(items, [["title", 1], ["generic", 0.8], ["keywords", 0.7], ["subtitle", 0.4]]);
    }

    function frecency(id: string): real {
        const entry = history.launches[id];
        if (!entry)
            return 0;

        const days = (Date.now() - entry.last) / 86400000;
        const recency = days < 1 ? 4 : days < 7 ? 2 : days < 30 ? 1 : 0.5;
        return entry.count * recency;
    }

    // DesktopEntry.execute() ignores Terminal=true, so those get a terminal here.
    function launch(entry: DesktopEntry): void {
        if (entry.runInTerminal)
            Quickshell.execDetached({
                command: [Launcher.terminal, "-e", ...entry.command],
                workingDirectory: entry.workingDirectory
            });
        else
            entry.execute();

        const launches = Object.assign({}, history.launches);
        launches[entry.id] = {
            count: (launches[entry.id]?.count ?? 0) + 1,
            last: Date.now()
        };
        history.launches = launches;
        historyFile.writeAdapter();
    }

    FileView {
        id: historyFile

        path: Quickshell.statePath("launcher.json")
        blockLoading: true
        printErrors: false

        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: history

            // Desktop entry id -> { count, last } (last in ms since the epoch).
            property var launches: ({})
        }
    }
}
