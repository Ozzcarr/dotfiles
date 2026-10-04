import Quickshell
import Quickshell.Wayland

PanelWindow {
    // Layer namespace is "quickshell-<name>", which looknfeel.lua's layer rules match.
    required property string name

    color: "transparent"

    WlrLayershell.namespace: `quickshell-${name}`
    WlrLayershell.layer: WlrLayer.Top
}
