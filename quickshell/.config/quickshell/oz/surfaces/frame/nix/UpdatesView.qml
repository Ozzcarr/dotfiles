// What `nix flake update` would bring, from the nix-update-check cache.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    readonly property var status: Services.Updates.status
    readonly property var lines: {
        const section = (title, items) => items?.length ? [{ title: `${title} (${items.length})` }, ...items.map(text => ({ text }))] : [];
        return [...section("Inputs behind", status?.inputs), ...section("Changed packages", status?.packages), ...section("New packages", status?.added)];
    }

    spacing: Tokens.space.item

    RowLayout {
        Layout.fillWidth: true

        spacing: Tokens.space.tight

        Text {
            Layout.fillWidth: true

            text: {
                if (Services.Updates.failed)
                    return root.status.error;
                if (!root.status)
                    return "Not checked yet";
                const download = root.status.download ? ` · ${root.status.download}` : "";
                return `Checked ${root.status.checked}${download}`;
            }
            color: Services.Updates.failed ? Appearance.danger : Appearance.dim
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }

        IconButton {
            icon: "refresh"

            onActivated: Services.Updates.check()
        }
    }

    Text {
        visible: root.status && !Services.Updates.failed && root.lines.length === 0

        Layout.fillWidth: true
        Layout.fillHeight: true

        text: "Everything is up to date"
        color: Appearance.faint
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.large
    }

    ScrollingList {
        visible: root.lines.length > 0

        Layout.fillWidth: true
        Layout.fillHeight: true

        model: root.lines
        active: Services.Nix.view === "updates"

        delegate: Text {
            required property var modelData
            required property int index

            width: ListView.view.width
            height: Tokens.nix.lineHeight + (modelData.title && index > 0 ? Tokens.space.item : 0)

            text: modelData.title ?? modelData.text
            color: modelData.title ? Appearance.accent : Appearance.text
            verticalAlignment: Text.AlignBottom
            elide: Text.ElideRight

            font.family: modelData.title ? Tokens.font.ui : Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
            font.bold: !!modelData.title
        }
    }
}
