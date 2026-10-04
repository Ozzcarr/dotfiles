pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false

    // Pipewire objects only publish live properties while tracked.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
}
