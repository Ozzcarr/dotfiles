// Session actions, quick settings pages and toggles, searchable.
import Quickshell
import qs.services

Mode {
    id: root

    // `page` opens that quick settings page; `confirm` needs a second Enter.
    readonly property var actions: [
        ...Session.actions.map(action => ({
                    key: action.key,
                    title: action.label,
                    glyph: action.icon,
                    command: action.command,
                    confirm: action.confirm
                })),
        { key: "audio", title: "Audio", subtitle: "Devices and app volume", glyph: "volume_up", page: "audio" },
        { key: "wifi", title: "Wi-Fi", subtitle: "Networks", glyph: "wifi", page: "wifi" },
        { key: "bluetooth", title: "Bluetooth", subtitle: "Devices", glyph: "bluetooth", page: "bluetooth" },
        { key: "displays", title: "Displays", subtitle: "hyprmoncfg", glyph: "desktop_windows", command: `${Launcher.terminal} --title hyprmoncfg -e hyprmoncfg` },
        { key: "nightlight", title: "Night light", subtitle: "Toggle", glyph: "nightlight", run: () => NightLight.toggle() },
        { key: "noise", title: "Noise mode", subtitle: "Toggle", glyph: "graphic_eq", run: () => Toggles.toggleNoise() },
        { key: "awake", title: "Keep awake", subtitle: "Toggle", glyph: "coffee", run: () => Toggles.toggleKeepAwake() },
        { key: "dnd", title: "Do not disturb", subtitle: "Toggle", glyph: "notifications_off", run: () => Notifications.toggleDnd() },
        { key: "wallpaper", title: "Wallpaper", glyph: "wallpaper", command: "wallpaper" },
        { key: "updates", title: "Check for updates", glyph: "update", command: "systemctl --user start nix-update-check.service" },
        { key: "reload", title: "Reload shell", glyph: "refresh", run: () => Quickshell.reload(true) }
    ]

    name: "system"
    prefix: "!"
    short: "system"
    label: "System"
    icon: "settings"
    placeholder: "System actions"

    results: Launcher.rank(root.actions.map(action => ({
                    key: action.key,
                    title: action.title,
                    subtitle: Launcher.confirming === action.key ? "Press Enter again to confirm" : action.subtitle,
                    glyph: action.glyph,
                    confirm: action.confirm ?? false,
                    // Opening a page replaces the launcher, so it must not close after.
                    keepOpen: !!action.page,
                    run: () => {
                        if (action.page)
                            Panels.open("settings", Panels.focusedScreen, action.page);
                        else if (action.run)
                            action.run();
                        else
                            Launcher.exec(action.command);
                    }
                })), [["title", 1], ["subtitle", 0.5]])
}
