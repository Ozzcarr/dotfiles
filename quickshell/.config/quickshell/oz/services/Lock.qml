// The session lock. Hyprland enforces it through ext-session-lock: while
// locked only the lock surfaces get drawn and get input, and if the shell dies
// the session stays locked. The only way out is PAM accepting the password.
// The state is also written to the runtime dir, so a shell restarted after a
// crash locks again straight away and takes the lock over.
//
// Right before locking, each screen is snapshotted so the lock screen can
// start out looking like the desktop and fade into itself; unlocking fades
// back before letting go. The snapshots are deleted on unlock.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Singleton {
    id: root

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    // How long the lock screens take to fade in and out, in ms.
    readonly property int fade: 350

    property bool locked: false
    // Hyprland has confirmed the lock and is showing only the lock screens.
    property bool secure: false
    // The lock screens are faded in; false while fading out before unlocking.
    property bool revealed: false
    property bool checking: false
    property string error: ""

    // Names this lock's snapshots, so the images never come from a cache.
    property string snapshotStamp: ""

    // Held until PAM asks for it, then dropped.
    property string pending: ""

    function snapshot(screen: string): string {
        return root.snapshotStamp && screen ? `file://${root.runtimeDir}/oz-lock-${screen}-${root.snapshotStamp}.jpg` : "";
    }

    function lock(): void {
        if (root.locked || snapshotter.running)
            return;
        Panels.close();
        root.error = "";
        root.snapshotStamp = String(Date.now());
        snapshotter.command = ["sh", "-c", 'stamp="$1"; shift; for o in "$@"; do grim -t jpeg -q 85 -o "$o" "$XDG_RUNTIME_DIR/oz-lock-$o-$stamp.jpg" & done; wait', "sh", root.snapshotStamp, ...Quickshell.screens.map(s => s.name)];
        snapshotter.running = true;
        snapshotTimeout.restart();
    }

    // Locks once the snapshots exist, or after the timeout without them.
    function engage(): void {
        snapshotTimeout.stop();
        if (root.locked)
            return;
        root.setLocked(true);
        root.revealed = true;
    }

    function setLocked(locked: bool): void {
        root.locked = locked;
        lockedFile.setText(locked ? "locked" : "");
    }

    function submit(password: string): void {
        if (root.checking || password === "")
            return;
        root.pending = password;
        root.checking = true;
        root.error = "";
        if (!pam.start()) {
            root.checking = false;
            root.pending = "";
            root.error = "Couldn't start authentication";
        }
    }

    Component.onCompleted: {
        if (lockedFile.text().trim() === "locked") {
            root.locked = true;
            root.revealed = true;
        }
    }

    Process {
        id: snapshotter

        onExited: root.engage()
    }

    // A slow or failed snapshot must never delay the lock for long.
    Timer {
        id: snapshotTimeout

        interval: 600

        onTriggered: root.engage()
    }

    // Lets the fade-out finish, then unlocks and drops the snapshots.
    Timer {
        id: release

        interval: root.fade + 50

        onTriggered: {
            root.setLocked(false);
            root.snapshotStamp = "";
            Quickshell.execDetached(["sh", "-c", 'rm -f "$XDG_RUNTIME_DIR"/oz-lock-*.jpg']);
        }
    }

    FileView {
        id: lockedFile

        // Per Wayland session, so a nested test session keeps its own.
        path: `${root.runtimeDir}/oz-locked-${Quickshell.env("WAYLAND_DISPLAY")}`
        blockLoading: true
        printErrors: false
    }

    PamContext {
        id: pam

        config: "oz-lock"

        onResponseRequiredChanged: {
            if (!responseRequired)
                return;
            respond(root.pending);
            root.pending = "";
        }

        onCompleted: result => {
            root.checking = false;
            root.pending = "";
            if (result === PamResult.Success) {
                root.revealed = false;
                release.restart();
            } else {
                root.error = "Wrong password";
            }
        }

        onError: () => {
            root.checking = false;
            root.pending = "";
            root.error = "Authentication failed";
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }
}
