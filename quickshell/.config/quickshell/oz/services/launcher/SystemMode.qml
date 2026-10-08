// Session actions, quick settings pages and toggles, searchable.
import Quickshell
import qs.services

Mode {
    id: root

    // `panel` opens that panel, at `page` if given; `confirm` needs a second Enter.
    readonly property var actions: [
        ...Session.actions.map(action => ({
                    key: action.key,
                    title: action.label,
                    glyph: action.icon,
                    command: action.command,
                    confirm: action.confirm
                })),
        { key: "audio", title: "Audio", subtitle: "Devices and app volume", glyph: "volume_up", panel: "settings", page: "audio" },
        { key: "wifi", title: "Wi-Fi", subtitle: "Networks", glyph: "wifi", panel: "settings", page: "wifi" },
        { key: "bluetooth", title: "Bluetooth", subtitle: "Devices", glyph: "bluetooth", panel: "settings", page: "bluetooth" },
        { key: "displays", title: "Displays", subtitle: "hyprmoncfg", glyph: "desktop_windows", command: `${Launcher.terminal} --title hyprmoncfg -e hyprmoncfg` },
        { key: "nightlight", title: "Night light", subtitle: "Toggle", glyph: "nightlight", run: () => NightLight.toggle() },
        { key: "noise", title: "Noise mode", subtitle: "Toggle", glyph: "graphic_eq", run: () => NoiseMode.toggle() },
        { key: "awake", title: "Keep awake", subtitle: "Toggle", glyph: "coffee", run: () => Idle.toggleKeepAwake() },
        { key: "dnd", title: "Do not disturb", subtitle: "Toggle", glyph: "notifications_off", run: () => Notifications.toggleDnd() },
        { key: "wallpaper", title: "Wallpaper", subtitle: "Pick a wallpaper", glyph: "wallpaper", panel: "wallpaper" },
        { key: "nix", title: "NixOS", subtitle: "Rebuild, update and generations", glyph: "deployed_code", panel: "nix" },
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
                    // Opening a panel replaces the launcher, so it must not close after.
                    keepOpen: !!action.panel,
                    run: () => {
                        if (action.panel)
                            Panels.open(action.panel, Panels.focusedScreen, action.page ?? "");
                        else if (action.run)
                            action.run();
                        else
                            Launcher.exec(action.command);
                    }
                })), [["title", 1], ["subtitle", 0.5]])
}
