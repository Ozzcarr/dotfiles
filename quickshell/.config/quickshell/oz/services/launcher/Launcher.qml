// The launcher's search state and what Enter does. Each mode is its own file
// and produces results; this file holds the shared matching and running.
// The surface is surfaces/frame/launcher, which only reads from here.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    readonly property string terminal: "kitty"

    readonly property list<Mode> modes: [apps, calc, clipboard, windows, system, binds, run]

    property Mode mode: apps
    property string query: ""
    property int current: 0

    // The search is edited in the frame's keyboard surface and mirrored on
    // screen, so the cursor and selection are shared state.
    property int cursor: 0
    property int selectionStart: 0
    property int selectionEnd: 0

    // Key of the result waiting for a second Enter before it runs.
    property string confirming: ""

    readonly property var results: mode.results

    onQueryChanged: {
        root.current = 0;
        root.confirming = "";
    }

    function begin(name: string): void {
        root.mode = root.modes.find(m => m.name === name) ?? apps;
        root.query = "";
        root.current = 0;
        root.confirming = "";
        root.mode.opened();
    }

    // Returns true when the text was a mode's prefix and switched to it.
    function switchByPrefix(text: string): bool {
        const target = root.modes.find(m => m.prefix !== "" && m.prefix === text);
        if (!target)
            return false;
        root.begin(target.name);
        return true;
    }

    function move(delta: int): void {
        const count = root.results.length;
        if (count > 0)
            root.current = Math.max(0, Math.min(count - 1, root.current + delta));
        root.confirming = "";
    }

    function activate(index: int, alt: bool): void {
        const item = root.results[index];
        if (!item)
            return;

        if (item.confirm && root.confirming !== item.key) {
            root.current = index;
            root.confirming = item.key;
            return;
        }

        item.run(alt);
        if (!item.keepOpen)
            Panels.close();
    }

    // Higher is better; -1 means no match. Prefix matches beat word starts,
    // which beat loose in-order matches, allowed only when `loose` is set.
    function score(needle: string, haystack: string, loose: bool): real {
        if (!haystack)
            return -1;

        const n = needle.toLowerCase();
        const h = haystack.toLowerCase();

        const at = h.indexOf(n);
        if (at === 0)
            return 1000 - h.length;
        if (at > 0)
            return (/[\s\-_.]/.test(h[at - 1]) ? 800 : 600) - at - h.length * 0.1;
        if (!loose)
            return -1;

        let total = 0;
        let matched = 0;
        let previous = -2;
        for (let i = 0; i < h.length && matched < n.length; i++) {
            if (h[i] !== n[matched])
                continue;
            total += i === previous + 1 ? 10 : 1;
            if (i === 0 || /[\s\-_.]/.test(h[i - 1]))
                total += 8;
            previous = i;
            matched++;
        }

        return matched === n.length ? 100 + total - h.length * 0.1 : -1;
    }

    // Filters and sorts items by the query. `fields` are [name, weight] pairs;
    // only the first matches loosely, since the rest are prose, where scattered
    // letters match almost anything. An item's `boost` is added to its score.
    function rank(items: var, fields: var): var {
        const q = root.query.trim();
        if (!q)
            return items;

        const scored = [];
        for (const item of items) {
            let best = -1;
            for (const [i, [field, weight]] of fields.entries()) {
                const s = root.score(q, item[field], i === 0);
                if (s >= 0)
                    best = Math.max(best, s * weight);
            }
            if (best >= 0)
                scored.push([best + (item.boost ?? 0), item]);
        }

        return scored.sort((a, b) => b[0] - a[0]).map(pair => pair[1]);
    }

    function exec(command: string): void {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    function copy(text: string): void {
        Quickshell.execDetached(["wl-copy", "--", text]);
    }

    AppsMode {
        id: apps
    }

    CalcMode {
        id: calc
    }

    ClipboardMode {
        id: clipboard
    }

    WindowsMode {
        id: windows
    }

    SystemMode {
        id: system
    }

    BindsMode {
        id: binds
    }

    RunMode {
        id: run
    }

    IpcHandler {
        target: "launcher"

        function toggle(mode: string): void {
            const screen = Panels.focusedScreen;
            if (Panels.isOpen("launcher", screen) && root.mode.name === mode) {
                Panels.close();
                return;
            }
            root.begin(mode);
            Panels.open("launcher", screen, "");
        }
    }
}
