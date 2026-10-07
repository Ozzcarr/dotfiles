// Pipewire devices and app streams. Quickshell counts a playback stream as the
// sink side, so app streams are the sink streams.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // The device that actually plays. When the default sink is EasyEffects'
    // virtual one, EasyEffects reads it before its own volume and mute apply,
    // so those do nothing; the device EasyEffects plays into is the real one.
    readonly property PwNode output: {
        if (root.sink?.name !== "easyeffects_sink")
            return root.sink;
        const link = Pipewire.linkGroups.values.find(group => group.source?.name?.startsWith("ee_soe") && group.target?.isSink && !group.target.isStream);
        return link?.target ?? root.sink;
    }
    readonly property bool muted: output?.audio?.muted ?? false
    readonly property int volume: Math.round((output?.audio?.volume ?? 0) * 100)

    readonly property var sinks: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(node => node.audio && node.isSink && node.isStream)
    // The default source is listed even when Quickshell doesn't see it as audio.
    readonly property var sources: {
        const list = Pipewire.nodes.values.filter(node => node.audio && !node.isSink && !node.isStream);
        return root.source && !list.includes(root.source) ? [root.source, ...list] : list;
    }

    // EasyEffects' virtual microphone has a media class Quickshell doesn't treat
    // as audio, so it has no controls there; its level goes through wpctl.
    readonly property bool sourceDirect: source?.audio ? true : false
    readonly property real sourceVolume: sourceDirect ? source.audio.volume : wpctlVolume
    readonly property bool sourceMuted: sourceDirect ? source.audio.muted : wpctlMuted
    property real wpctlVolume: 0
    property bool wpctlMuted: false

    function label(node: PwNode): string {
        return node?.properties?.["application.name"] || node?.description || node?.nickname || node?.name || "";
    }

    function setVolume(node: PwNode, value: real): void {
        if (node?.audio)
            node.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute(node: PwNode): void {
        if (node?.audio)
            node.audio.muted = !node.audio.muted;
    }

    // Volume keys: 5% steps on the real output, capped at 100%.
    function adjust(steps: int): void {
        root.setVolume(root.output, (root.output?.audio?.volume ?? 0) + steps * 0.05);
    }

    function setSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node: PwNode): void {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function setSourceVolume(value: real): void {
        if (root.sourceDirect)
            root.setVolume(root.source, value);
        else
            root.wpctl(["set-volume", "@DEFAULT_AUDIO_SOURCE@", Math.max(0, Math.min(1, value)).toFixed(2)]);
    }

    function toggleSourceMute(): void {
        if (root.sourceDirect)
            root.toggleMute(root.source);
        else
            root.wpctl(["set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function refreshSource(): void {
        if (!root.sourceDirect)
            sourceQuery.running = true;
    }

    function wpctl(args: list<string>): void {
        setter.command = ["wpctl", ...args];
        setter.running = true;
    }

    onSourceChanged: root.refreshSource()

    // Pipewire objects only publish live properties while tracked.
    PwObjectTracker {
        objects: [root.sink, root.output, root.source, ...root.streams].filter(node => node !== null)
    }

    IpcHandler {
        target: "audio"

        function up(): void {
            root.adjust(1);
        }

        function down(): void {
            root.adjust(-1);
        }

        function mute(): void {
            root.toggleMute(root.output);
        }
    }

    Process {
        id: setter

        onExited: root.refreshSource()
    }

    // Prints "Volume: 0.85", with " [MUTED]" when muted.
    Process {
        id: sourceQuery

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]

        stdout: StdioCollector {
            onStreamFinished: {
                const match = /Volume:\s+([\d.]+)/.exec(text);
                if (match)
                    root.wpctlVolume = Number(match[1]);
                root.wpctlMuted = text.includes("[MUTED]");
            }
        }
    }
}
