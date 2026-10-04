// Vesktop's own streams, which vesktop-mute and vesktop-deafen mute, so its
// state shows even when the system devices are live. Matched on fields that
// exist before a node is tracked; `properties` only fills in after.
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Quickshell counts a playback stream as the sink side; the mic is the other.
    readonly property PwNode input: find(false)
    readonly property PwNode output: find(true)

    readonly property bool micMuted: input?.audio?.muted ?? false
    readonly property bool deafened: output?.audio?.muted ?? false

    function find(sink: bool): PwNode {
        return Pipewire.nodes.values.find(node => node.isStream && node.isSink === sink && node.name === "vesktop") ?? null;
    }

    // Pipewire objects only publish live properties while tracked.
    PwObjectTracker {
        objects: [root.input, root.output].filter(node => node !== null)
    }
}
