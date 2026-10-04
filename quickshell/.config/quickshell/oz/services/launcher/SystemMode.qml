// Session, settings and toggles. The settings open terminal tools until the
// shell has its own quick settings panel.
import Quickshell

Mode {
    id: root

    readonly property string hyprDir: `${Quickshell.env("HOME")}/dotfiles/hyprland/.config/hypr`

    // `confirm` actions need a second Enter.
    readonly property var actions: [
        { key: "lock", title: "Lock", glyph: "lock", command: "hyprlock" },
        { key: "suspend", title: "Suspend", glyph: "bedtime", command: "systemctl suspend" },
        { key: "logout", title: "Log out", glyph: "logout", command: "hyprctl dispatch 'hl.dsp.exit()'", confirm: true },
        { key: "reboot", title: "Restart", glyph: "restart_alt", command: "systemctl reboot", confirm: true },
        { key: "poweroff", title: "Shut down", glyph: "power_settings_new", command: "systemctl poweroff", confirm: true },
        { key: "audio", title: "Audio", subtitle: "wiremix", glyph: "volume_up", command: tui("wiremix") },
        { key: "wifi", title: "Wi-Fi", subtitle: "impala", glyph: "wifi", command: tui("impala") },
        { key: "bluetooth", title: "Bluetooth", subtitle: "bluetui", glyph: "bluetooth", command: tui("bluetui") },
        { key: "displays", title: "Displays", subtitle: "hyprmoncfg", glyph: "desktop_windows", command: tui("hyprmoncfg") },
        { key: "nightlight", title: "Night light", subtitle: "Toggle", glyph: "nightlight", command: `${hyprDir}/night-light.sh` },
        { key: "noise", title: "Noise mode", subtitle: "Toggle", glyph: "graphic_eq", command: "noise-mode toggle" },
        { key: "awake", title: "Keep awake", subtitle: "Toggle", glyph: "coffee", command: `${hyprDir}/keep-awake.sh` },
        { key: "wallpaper", title: "Wallpaper", glyph: "wallpaper", command: "wallpaper" },
        { key: "updates", title: "Check for updates", glyph: "update", command: "systemctl --user start nix-update-check.service" },
        { key: "reload", title: "Reload shell", glyph: "refresh", command: "qs -c oz ipc call shell reload" }
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
                    run: () => Launcher.exec(action.command)
                })), [["title", 1], ["subtitle", 0.5]])

    // Window rules float these by title.
    function tui(tool: string): string {
        return `${Launcher.terminal} --title ${tool} -e ${tool}`;
    }
}
