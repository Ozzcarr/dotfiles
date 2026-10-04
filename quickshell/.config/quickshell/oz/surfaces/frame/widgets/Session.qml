import Quickshell
import qs.components
import qs.config

IconButton {
    icon: "power_settings_new"
    // Not red at rest: warm wallpapers push the accent toward red already.
    tint: Appearance.accentAlt
    hoverTint: Appearance.danger

    onActivated: Quickshell.execDetached(["wlogout"])
}
