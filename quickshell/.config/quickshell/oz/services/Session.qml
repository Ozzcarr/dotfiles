// Lock, suspend, log out, restart and shut down, for the session menu and the
// launcher's system mode. The ones that end the session need a second press.
pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var actions: [
        { key: "lock", label: "Lock", icon: "lock", command: "qs -c oz ipc call lock lock" },
        { key: "suspend", label: "Suspend", icon: "bedtime", command: "systemctl suspend" },
        { key: "logout", label: "Log out", icon: "logout", command: "hyprctl dispatch 'hl.dsp.exit()'", confirm: true },
        { key: "reboot", label: "Restart", icon: "restart_alt", command: "systemctl reboot", confirm: true },
        { key: "poweroff", label: "Shut down", icon: "power_settings_new", command: "systemctl poweroff", confirm: true }
    ]

    // Selection in the session menu, and the action waiting for a second press.
    property int current: 0
    property string confirming: ""

    function reset(): void {
        root.current = 0;
        root.confirming = "";
    }

    function move(delta: int): void {
        root.current = (root.current + delta + root.actions.length) % root.actions.length;
        root.confirming = "";
    }

    // Returns true when the action ran rather than asking for confirmation.
    function activate(index: int): bool {
        const action = root.actions[index];
        if (action.confirm && root.confirming !== action.key) {
            root.current = index;
            root.confirming = action.key;
            return false;
        }

        root.confirming = "";
        Panels.close();
        Quickshell.execDetached(["sh", "-c", action.command]);
        return true;
    }
}
