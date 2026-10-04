// Material Symbols is a ligature font: the text is the icon name.
import QtQuick
import QtQuick.Layouts
import qs.config

Text {
    Layout.alignment: Qt.AlignVCenter

    color: Appearance.dim

    font.family: Tokens.font.icon
    font.pixelSize: Tokens.icon.glyph

    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
