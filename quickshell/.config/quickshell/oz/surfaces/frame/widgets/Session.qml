import qs.components
import qs.config
import qs.services as Services

IconButton {
    icon: "power_settings_new"
    // Not red at rest: warm wallpapers push the accent toward red already.
    tint: Appearance.accentAlt
    hoverTint: Appearance.danger

    onActivated: Services.Panels.toggle("session", Services.Panels.focusedScreen)
}
