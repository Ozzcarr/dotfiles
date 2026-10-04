// What the on-screen display shows: an icon and an optional level, for a
// moment after something changes. Volume, Spotify volume and Vesktop changes
// are picked up here; brightness and scripts call the IPC.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    property bool visible: false
    // A Material Symbols name, or an app icon from the icon theme, which wins.
    property string icon: ""
    property string appIcon: ""
    property string label: ""
    // 0 to 1, or -1 for no level bar.
    property real level: -1

    readonly property MprisPlayer spotify: Mpris.players.values.find(player => player.identity === "Spotify") ?? null

    function show(icon: string, label: string, level: real): void {
        if (!armed.ready)
            return;
        root.icon = icon;
        root.appIcon = "";
        root.label = label;
        root.level = level;
        root.visible = true;
        hide.restart();
    }

    function showApp(appIcon: string, label: string, level: real): void {
        root.show("", label, level);
        root.appIcon = appIcon;
    }

    function showVolume(): void {
        const muted = Audio.muted;
        root.show(muted ? "volume_off" : Audio.volume > 50 ? "volume_up" : "volume_down", muted ? "Muted" : `${Audio.volume}%`, muted ? 0 : Audio.volume / 100);
    }

    Timer {
        id: hide

        interval: 1500

        onTriggered: root.visible = false
    }

    // Devices report their initial state at startup; that isn't a change.
    Timer {
        id: armed

        property bool ready: false

        interval: 2000
        running: true

        onTriggered: ready = true
    }

    Connections {
        target: Audio

        function onVolumeChanged(): void {
            root.showVolume();
        }

        function onMutedChanged(): void {
            root.showVolume();
        }
    }

    // Spotify keeps its own volume, which SUPER+volume changes.
    Connections {
        target: root.spotify

        function onVolumeChanged(): void {
            const volume = Math.round(root.spotify.volume * 100);
            root.showApp("spotify", `${volume}%`, volume / 100);
        }
    }

    // The streams' own signals, so Vesktop opening or closing doesn't count.
    Connections {
        target: Vesktop.input?.audio ?? null

        function onMutedChanged(): void {
            root.show(Vesktop.micMuted ? "mic_off" : "mic", Vesktop.micMuted ? "Vesktop mic muted" : "Vesktop mic on", -1);
        }
    }

    Connections {
        target: Vesktop.output?.audio ?? null

        function onMutedChanged(): void {
            root.show(Vesktop.deafened ? "headset_off" : "headset_mic", Vesktop.deafened ? "Vesktop deafened" : "Vesktop undeafened", -1);
        }
    }

    // brightnessctl -m prints "device,class,current,percent,max".
    Process {
        id: brightnessQuery

        command: ["brightnessctl", "-c", "backlight", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const percent = parseInt(text.split(",")[3]);
                if (!isNaN(percent))
                    root.show(percent > 50 ? "brightness_high" : "brightness_low", `${percent}%`, percent / 100);
            }
        }
    }

    IpcHandler {
        target: "osd"

        function brightness(): void {
            brightnessQuery.running = true;
        }

        function flash(icon: string, label: string): void {
            root.show(icon, label, -1);
        }
    }
}
