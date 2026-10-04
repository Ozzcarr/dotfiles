// cliphist's history, newest first. Enter copies the entry again.
import QtQuick
import Quickshell
import Quickshell.Io

Mode {
    id: root

    property var clips: []

    name: "clipboard"
    prefix: ":"
    short: "clip"
    label: "Clipboard"
    icon: "content_paste"
    placeholder: "Search clipboard"

    results: Launcher.rank(root.clips.map(clip => ({
                    key: `clip:${clip.id}`,
                    title: clip.text,
                    glyph: clip.image ? "image" : "content_paste",
                    run: () => Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", clip.id])
                })), [["title", 1]])

    onOpened: list.running = true

    // Each line is "<id>\t<preview>"; images preview as "[[ binary data ... ]]".
    Process {
        id: list

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            onStreamFinished: root.clips = text.split("\n").filter(line => line.includes("\t")).map(line => {
                const tab = line.indexOf("\t");
                const preview = line.slice(tab + 1);
                return {
                    id: line.slice(0, tab),
                    text: preview.replace(/\s+/g, " ").trim(),
                    image: preview.startsWith("[[ binary data")
                };
            })
        }
    }
}
