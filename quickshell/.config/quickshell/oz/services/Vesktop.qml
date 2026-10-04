pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// Vesktop's own microphone stream, so its mute shows even when the system mic
// is live.
Singleton {
    id: root

    readonly property PwNode input: Pipewire.nodes.values.find(node => node.properties?.["node.name"] === "vesktop" && node.properties?.["media.class"] === "Stream/Input/Audio") ?? null
    readonly property bool micMuted: input?.audio?.muted ?? false

    // Pipewire objects only publish live properties while tracked.
    PwObjectTracker {
        objects: root.input ? [root.input] : []
    }
}
