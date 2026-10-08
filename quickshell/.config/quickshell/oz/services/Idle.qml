// Locks, turns the screens off and on battery suspends after inactivity, with
// shorter timeouts on battery. Apps that hold an idle inhibitor (video, a
// fullscreen game) pause it, and so does keep awake. It also locks before the
// system sleeps, holding a short delay so the lock screen is up first.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    // Seconds of inactivity; 0 never.
    readonly property int lockAfter: Battery.draining ? 300 : 900
    readonly property int screenOffAfter: Battery.draining ? 420 : 1200
    readonly property int suspendAfter: Battery.draining ? 900 : 0

    // Lives in the runtime dir: survives shell restarts, resets on reboot.
    readonly property bool keepAwake: keepAwakeFile.text().trim() === "on"

    function toggleKeepAwake(): void {
        const on = !root.keepAwake;
        keepAwakeFile.setText(on ? "on" : "off");
        Osd.show(on ? "coffee" : "bedtime", on ? "Keep awake on" : "Keep awake off", -1);
    }

    function screens(on: bool): void {
        Hyprland.dispatch(`hl.dsp.dpms("${on ? "on" : "off"}")`);
    }

    IdleMonitor {
        enabled: !root.keepAwake
        timeout: root.lockAfter
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle)
                Lock.lock();
        }
    }

    IdleMonitor {
        enabled: !root.keepAwake
        timeout: root.screenOffAfter
        respectInhibitors: true

        onIsIdleChanged: root.screens(!isIdle)
    }

    IdleMonitor {
        enabled: !root.keepAwake && root.suspendAfter > 0
        timeout: Math.max(1, root.suspendAfter)
        respectInhibitors: true

        onIsIdleChanged: {
            if (isIdle)
                Quickshell.execDetached(["systemctl", "suspend"]);
        }
    }

    FileView {
        id: keepAwakeFile

        path: `${Quickshell.env("XDG_RUNTIME_DIR")}/keep-awake`
        blockLoading: true
        printErrors: false
    }

    // Held while awake; logind waits for it to be released before sleeping,
    // which happens once the lock screen is confirmed.
    Process {
        id: sleepDelay

        running: true
        command: ["systemd-inhibit", "--what=sleep", "--mode=delay", "--who=Shell", "--why=Lock the screen before sleeping", "sleep", "infinity"]
    }

    // Releases the delay once locked, or after two seconds at most, so a broken
    // lock never keeps the machine awake.
    Timer {
        id: releaseSleep

        property int waited: 0

        interval: 50
        repeat: true

        onTriggered: {
            waited += interval;
            if (Lock.secure || waited >= 2000) {
                stop();
                sleepDelay.running = false;
            }
        }
    }

    // logind's PrepareForSleep (before and after sleep) and Lock (loginctl
    // lock-session). dbus-monitor prints the member, then its argument.
    Process {
        running: true
        command: ["dbus-monitor", "--system", "type='signal',sender='org.freedesktop.login1',member='PrepareForSleep'", "type='signal',sender='org.freedesktop.login1',interface='org.freedesktop.login1.Session',member='Lock'"]

        stdout: SplitParser {
            property string member: ""

            onRead: line => {
                const match = /member=(\w+)/.exec(line);
                if (match) {
                    member = match[1];
                    if (member === "Lock")
                        Lock.lock();
                    return;
                }

                if (member !== "PrepareForSleep")
                    return;
                if (line.includes("boolean true")) {
                    Lock.lock();
                    releaseSleep.waited = 0;
                    releaseSleep.restart();
                } else if (line.includes("boolean false")) {
                    sleepDelay.running = true;
                    root.screens(true);
                }
                member = "";
            }
        }
    }

    IpcHandler {
        target: "idle"

        function keepawake(): void {
            root.toggleKeepAwake();
        }
    }
}
