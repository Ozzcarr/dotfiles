pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// One panel is open at a time, on one screen.
Singleton {
    id: root

    // "dashboard", "launcher" or "session" in the center; "notifications" or
    // "settings" on the right; "" when closed.
    property string panel: ""
    property string screen: ""
    // A sub-page of the open panel, like "wifi" in settings; "" for its start.
    property string page: ""

    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    function isOpen(name: string, screen: string): bool {
        return root.panel === name && root.screen === screen;
    }

    function open(name: string, screen: string, page: string): void {
        root.panel = name;
        root.screen = screen;
        root.page = page;
    }

    function toggle(name: string, screen: string): void {
        if (root.isOpen(name, screen))
            root.close();
        else
            root.open(name, screen, "");
    }

    function close(): void {
        root.panel = "";
        root.screen = "";
        root.page = "";
    }

    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            root.toggle("dashboard", root.focusedScreen);
        }
    }

    IpcHandler {
        target: "session"

        function toggle(): void {
            root.toggle("session", root.focusedScreen);
        }
    }

    IpcHandler {
        target: "settings"

        function toggle(): void {
            root.toggle("settings", root.focusedScreen);
        }

        // Opens straight into a page; closes if that page is already showing.
        function open(page: string): void {
            if (root.isOpen("settings", root.focusedScreen) && root.page === page)
                root.close();
            else
                root.open("settings", root.focusedScreen, page);
        }
    }
}
