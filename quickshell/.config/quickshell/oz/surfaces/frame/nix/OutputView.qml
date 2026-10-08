// The log of the running or last operation, or a generation diff. Stays at
// the bottom while new lines come in, unless scrolled up.
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services as Services

ColumnLayout {
    spacing: Tokens.space.tight

    Text {
        Layout.fillWidth: true

        text: Services.Nix.outputTitle || "Nothing has run yet"
        color: Services.Nix.outputTitle ? Appearance.accent : Appearance.faint
        elide: Text.ElideRight

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.small
        font.bold: true
    }

    ScrollingList {
        id: list

        property bool following: true

        Layout.fillWidth: true
        Layout.fillHeight: true

        model: Services.Nix.output
        active: Services.Nix.view === "output"

        onContentYChanged: following = atYEnd || contentHeight <= height
        onCountChanged: if (following)
            positionViewAtEnd()

        delegate: Text {
            required property string line

            width: ListView.view.width

            text: line
            color: Appearance.text
            wrapMode: Text.WrapAnywhere
            lineHeight: Tokens.nix.lineHeight
            lineHeightMode: Text.FixedHeight

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.font.size.small
        }
    }
}
