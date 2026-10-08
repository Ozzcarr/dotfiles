// A list the panel's keyboard can scroll while its view is showing.
import QtQuick
import qs.config
import qs.services as Services

ListView {
    id: root

    property bool active: false

    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Connections {
        target: Services.Nix
        enabled: root.active

        function onScroll(lines: int): void {
            const max = Math.max(0, root.contentHeight - root.height);
            root.contentY = Math.max(0, Math.min(max, root.contentY + lines * Tokens.nix.lineHeight));
        }
    }
}
