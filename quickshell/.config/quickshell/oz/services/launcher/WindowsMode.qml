// Open windows on every workspace. Enter focuses the window.
import Quickshell
import Quickshell.Hyprland

Mode {
    name: "windows"
    prefix: "#"
    short: "windows"
    label: "Windows"
    icon: "select_window"
    placeholder: "Switch to a window"

    results: Launcher.rank(Hyprland.toplevels.values.map(toplevel => {
        const cls = toplevel.lastIpcObject?.class ?? "";
        const entry = cls ? DesktopEntries.heuristicLookup(cls) : null;
        const workspace = toplevel.workspace ? `workspace ${toplevel.workspace.name}` : "";
        return {
            key: `window:${toplevel.address}`,
            title: toplevel.title,
            subtitle: [entry?.name ?? cls, workspace].filter(Boolean).join(" · "),
            icon: entry?.icon ?? "",
            glyph: "select_window",
            run: () => Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${toplevel.address}" })`)
        };
    }), [["title", 1], ["subtitle", 0.8]])

    // Window classes come from Hyprland's IPC objects, which go stale.
    onOpened: Hyprland.refreshToplevels()
}
