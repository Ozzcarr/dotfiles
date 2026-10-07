// Night light through hyprsunset, which only runs once it is first turned on.
// It is changed through hyprsunset's socket rather than by restarting it: a
// restart reapplies the color matrix, which stalls games. The on/off state
// lives in the runtime dir, so it survives shell restarts but not a reboot;
// the temperature and dimming are remembered for good.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int minTemperature: 2500
    readonly property int maxTemperature: 6000
    readonly property int minGamma: 50

    readonly property bool enabled: enabledFile.text().trim() === "on"
    readonly property int temperature: settings.temperature
    // Display gamma in percent; lower dims the screen along with the warmth.
    readonly property int gamma: settings.gamma

    function toggle(): void {
        root.setEnabled(!root.enabled);
    }

    function setEnabled(on: bool): void {
        enabledFile.setText(on ? "on" : "off");
        root.apply(on);
        Osd.show(on ? "nightlight" : "light_mode", on ? "Night light on" : "Night light off", -1);
    }

    function setTemperature(kelvin: int): void {
        settings.temperature = Math.max(root.minTemperature, Math.min(root.maxTemperature, kelvin));
        settingsFile.writeAdapter();
        if (root.enabled)
            debounce.restart();
    }

    function setGamma(percent: int): void {
        settings.gamma = Math.max(root.minGamma, Math.min(100, percent));
        settingsFile.writeAdapter();
        if (root.enabled)
            debounce.restart();
    }

    function apply(on: bool): void {
        const values = on ? `temperature ${root.temperature} && hyprctl hyprsunset gamma ${root.gamma}` : "identity && hyprctl hyprsunset gamma 100";
        // Starts hyprsunset neutral on first use, in its own unit so restarting
        // the shell doesn't take it down, and waits for its socket.
        hyprsunset.command = ["sh", "-c", `pgrep -x hyprsunset >/dev/null || { systemd-run --user -q --unit=night-light hyprsunset -i; for i in $(seq 20); do hyprctl hyprsunset gamma >/dev/null 2>&1 && break; sleep 0.05; done; }; hyprctl hyprsunset ${values} >/dev/null`];
        hyprsunset.running = true;
    }

    // Sliders move faster than hyprsunset needs updates.
    Timer {
        id: debounce

        interval: 60

        onTriggered: root.apply(root.enabled)
    }

    Process {
        id: hyprsunset
    }

    FileView {
        id: enabledFile

        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/night-light`
        blockLoading: true
        printErrors: false
    }

    FileView {
        id: settingsFile

        path: Quickshell.statePath("night-light.json")
        blockLoading: true
        printErrors: false

        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: settings

            property int temperature: 4000
            property int gamma: 90
        }
    }

    IpcHandler {
        target: "nightlight"

        function toggle(): void {
            root.toggle();
        }
    }
}
