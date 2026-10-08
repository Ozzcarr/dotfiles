// Rebuilds, updates and generations for the NixOS panel. System operations
// run in `oz-system@<operation>.service` (modules/core/rebuild.nix in
// nix-config), which polkit guards with the password; the home switch runs as
// a transient user unit. Either way the work lives in systemd, so it survives a
// shell restart, and the shell only follows the log. A restarted shell picks a
// running operation back up.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string systemLog: "/run/oz-system/log"
    readonly property string homeLog: `${Quickshell.env("XDG_RUNTIME_DIR")}/oz-home.log`
    readonly property string profiles: "/nix/var/nix/profiles"

    // `alias` is the shell function it replaces; `confirm` needs a second press.
    readonly property var operations: [
        { key: "switch", label: "Switch", icon: "published_with_changes", alias: "frs" },
        { key: "boot", label: "Switch on boot", icon: "restart_alt", alias: "frb" },
        { key: "update-switch", label: "Update and switch", icon: "system_update_alt", alias: "fus" },
        { key: "update-boot", label: "Update on boot", icon: "update", alias: "fub" },
        { key: "home", label: "Home switch", icon: "home", alias: "hr" },
        { key: "rollback", label: "Roll back", icon: "history", alias: "rb", confirm: true },
        { key: "clean", label: "Collect garbage", icon: "delete_sweep", alias: "ncg", confirm: true }
    ]
    readonly property list<string> views: ["updates", "generations", "output"]

    // The operation in progress, and how the last one ended: "success",
    // "failed" or "cancelled".
    property string running: ""
    property string last: ""
    property string result: ""

    // What the output view shows: an operation's log or a generation diff.
    property string outputTitle: ""
    readonly property ListModel output: ListModel {}

    // [{ number, date, version, kernel, current, next }], newest first.
    property var generations: []

    // Panel state, shared by the panel and its keyboard handler.
    property string view: "updates"
    property bool inView: false
    property int action: 0
    property int generation: 0
    // A generation marked to diff against; -1 diffs against the current one.
    property int marked: -1
    property string confirming: ""

    // Asks the open view to scroll by this many lines.
    signal scroll(int lines)

    function operation(key: string): var {
        return root.operations.find(op => op.key === key) ?? null;
    }

    function reset(): void {
        root.confirming = "";
        root.inView = false;
        root.marked = -1;
        listGenerations.running = true;
        if (root.running !== "")
            root.view = "output";
    }

    function moveAction(delta: int): void {
        root.action = Math.max(0, Math.min(root.operations.length - 1, root.action + delta));
        root.confirming = "";
    }

    function moveGeneration(delta: int): void {
        root.generation = Math.max(0, Math.min(root.generations.length - 1, root.generation + delta));
    }

    function cycleView(delta: int): void {
        const i = root.views.indexOf(root.view);
        root.view = root.views[(i + delta + root.views.length) % root.views.length];
    }

    function mark(index: int): void {
        root.marked = root.marked === index ? -1 : index;
    }

    // Returns true when the operation started rather than asking to confirm.
    function start(key: string): bool {
        const op = root.operation(key);
        if (!op || root.running !== "")
            return false;
        if (op.confirm && root.confirming !== key) {
            root.confirming = key;
            return false;
        }

        root.confirming = "";
        root.running = key;
        root.result = "";
        root.view = "output";
        root.outputTitle = op.label;
        root.output.clear();

        follower.follow(key === "home" ? root.homeLog : root.systemLog, false);
        starter.command = key === "home" ? homeCommand() : ["systemctl", "start", `oz-system@${key}.service`];
        starter.running = true;
        return true;
    }

    function homeCommand(): list<string> {
        return ["systemd-run", "--user", "--unit=oz-home", "--collect", "--wait", "--quiet", "--service-type=oneshot", "--setenv=PATH", "-p", `StandardOutput=truncate:${root.homeLog}`, "-p", "StandardError=inherit", "--", "sh", "-c", 'exec nh home switch --no-nom --configuration "$USER@$(hostname)" "$HOME/nix-config"'];
    }

    function finish(result: string): void {
        const op = root.operation(root.running);
        root.last = root.running;
        root.result = result;
        root.running = "";
        // Lets the last lines through before letting go of the log.
        stopFollowing.restart();
        listGenerations.running = true;

        if (result === "cancelled")
            return;
        if (result === "success" && op.key !== "home")
            Updates.check();
        Quickshell.execDetached(["notify-send", "-a", "NixOS", "-i", result === "success" ? "emblem-ok-symbolic" : "dialog-error-symbolic", result === "success" ? `${op.label} finished` : `${op.label} failed`, result === "success" ? "" : "The output is in the NixOS panel."]);
    }

    // Diffs the selected generation against the marked one, or the current.
    function diff(): void {
        const selected = root.generations[root.generation];
        const other = root.marked >= 0 ? root.generations[root.marked] : root.generations.find(gen => gen.current);
        if (!selected || !other || selected === other || root.running !== "")
            return;

        const [from, to] = selected.number < other.number ? [selected, other] : [other, selected];
        root.outputTitle = `Generation ${from.number} → ${to.number}`;
        root.output.clear();
        root.view = "output";
        differ.command = ["nvd", "diff", `${root.profiles}/system-${from.number}-link`, `${root.profiles}/system-${to.number}-link`];
        differ.running = true;
    }

    function append(line: string): void {
        // Progress output redraws with carriage returns; only the last draw counts.
        const clean = line.replace(/\x1b\[[0-9;?]*[A-Za-z]/g, "").split("\r").pop();
        root.output.append({ line: clean });
        if (root.output.count > 2000)
            root.output.remove(0, root.output.count - 2000);
    }

    Component.onCompleted: reattach.running = true

    Process {
        id: starter

        stderr: StdioCollector {
            id: starterErrors
        }

        onExited: code => {
            if (code === 0)
                root.finish("success");
            else if (/access denied|authentication|not authorized/i.test(starterErrors.text))
                root.finish("cancelled");
            else
                root.finish("failed");
        }
    }

    // Follows a log from the start of the operation. The unit truncates it,
    // which tail notices and reads on from.
    Process {
        id: follower

        function follow(path: string, whole: bool): void {
            running = false;
            command = ["tail", "-n", whole ? "+1" : "0", "-F", path];
            running = true;
        }

        stdout: SplitParser {
            onRead: line => root.append(line)
        }
    }

    Timer {
        id: stopFollowing

        interval: 500

        onTriggered: follower.running = false
    }

    // Finds an operation that was running when the shell started.
    Process {
        id: reattach

        command: ["sh", "-c", 'systemctl list-units --plain --no-legend --state=activating "oz-system@*"; systemctl --user list-units --plain --no-legend --state=activating oz-home.service']

        stdout: StdioCollector {
            onStreamFinished: {
                const unit = text.trim().split(/\s+/)[0];
                if (!unit)
                    return;
                const key = unit === "oz-home.service" ? "home" : unit.replace(/^oz-system@|\.service$/g, "");
                const op = root.operation(key);
                if (!op)
                    return;
                root.running = key;
                root.view = "output";
                root.outputTitle = op.label;
                root.output.clear();
                follower.follow(key === "home" ? root.homeLog : root.systemLog, true);
                poll.unit = unit;
                poll.start();
            }
        }
    }

    // Watches a picked-up operation, since there is no systemctl call to wait on.
    Timer {
        id: poll

        property string unit: ""

        interval: 2000
        repeat: true

        onTriggered: {
            checker.command = ["systemctl", ...(unit === "oz-home.service" ? ["--user"] : []), "is-active", unit];
            checker.running = true;
        }
    }

    Process {
        id: checker

        stdout: StdioCollector {
            onStreamFinished: {
                const state = text.trim();
                if (state === "activating")
                    return;
                poll.stop();
                root.finish(state === "failed" ? "failed" : "success");
            }
        }
    }

    Process {
        id: listGenerations

        command: ["sh", "-c", `
            current=$(readlink -f /run/current-system)
            next=$(readlink -f ${root.profiles}/system)
            for link in ${root.profiles}/system-*-link; do
                target=$(readlink -f "$link")
                number=\${link##*/system-}
                printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' "\${number%-link}" "$(stat -c %Y "$link")" \\
                    "$(cat "$link/nixos-version" 2>/dev/null)" \\
                    "$(ls "$link/kernel-modules/lib/modules" 2>/dev/null | head -n 1)" \\
                    "$([ "$target" = "$current" ] && echo 1)" "$([ "$target" = "$next" ] && echo 1)"
            done`]

        stdout: StdioCollector {
            onStreamFinished: {
                root.generations = text.split("\n").filter(line => line !== "").map(line => {
                    const [number, date, version, kernel, current, next] = line.split("\t");
                    return { number: Number(number), date: new Date(Number(date) * 1000), version, kernel, current: current === "1", next: next === "1" };
                }).sort((a, b) => b.number - a.number);
                root.generation = Math.min(root.generation, Math.max(0, root.generations.length - 1));
                root.marked = Math.min(root.marked, root.generations.length - 1);
            }
        }
    }

    Process {
        id: differ

        stdout: SplitParser {
            onRead: line => root.append(line)
        }
    }

    IpcHandler {
        target: "nix"

        function toggle(): void {
            Panels.toggle("nix", Panels.focusedScreen);
        }
    }
}
