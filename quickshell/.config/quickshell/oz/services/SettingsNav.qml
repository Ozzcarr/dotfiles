// Keyboard focus in quick settings. Every focusable control holds a NavTarget,
// which registers here; moving goes through them in reading order, so pages
// don't number their controls and hidden ones are skipped.
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var targets: []
    // The focused NavTarget, or null until the keyboard is used.
    property var current: null

    function add(target: var): void {
        root.targets = [...root.targets, target];
    }

    function remove(target: var): void {
        root.targets = root.targets.filter(t => t !== target);
        if (root.current === target)
            root.current = null;
    }

    function ordered(): var {
        return root.targets.filter(t => t.parent?.visible && t.parent.width > 0).map(t => ({
                    target: t,
                    position: t.parent.mapToItem(null, 0, 0)
                })).sort((a, b) => (a.position.y - b.position.y) || (a.position.x - b.position.x)).map(entry => entry.target);
    }

    function move(delta: int): void {
        const list = root.ordered();
        if (list.length === 0)
            return;
        const at = list.indexOf(root.current);
        root.current = at < 0 ? list[0] : list[Math.max(0, Math.min(list.length - 1, at + delta))];
    }

    // Each returns false when nothing is focused, so the caller can fall back.
    function activate(): bool {
        root.current?.activated();
        return root.current !== null;
    }

    function step(delta: int): bool {
        root.current?.step(delta);
        return root.current !== null;
    }

    function secondary(): void {
        root.current?.secondaryActivated();
    }

    // A new page starts unfocused.
    Connections {
        target: Panels

        function onPageChanged(): void {
            root.current = null;
        }

        function onPanelChanged(): void {
            root.current = null;
        }
    }
}
