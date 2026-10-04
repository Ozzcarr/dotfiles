pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// One panel is open at a time, on one screen.
Singleton {
    id: root

    // "dashboard", "launcher", "notifications", or "" when closed.
    property string panel: ""
    property string screen: ""

    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    function isOpen(name: string, screen: string): bool {
        return root.panel === name && root.screen === screen;
    }

    function open(name: string, screen: string): void {
        root.panel = name;
        root.screen = screen;
    }

    function toggle(name: string, screen: string): void {
        if (root.isOpen(name, screen))
            root.close();
        else
            root.open(name, screen);
    }

    function close(): void {
        root.panel = "";
        root.screen = "";
    }

    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            root.toggle("dashboard", root.focusedScreen);
        }
    }
}
