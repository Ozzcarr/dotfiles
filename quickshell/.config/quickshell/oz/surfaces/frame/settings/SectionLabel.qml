import QtQuick
import QtQuick.Layouts
import qs.config

Text {
    Layout.fillWidth: true
    Layout.topMargin: Tokens.space.tight
    Layout.leftMargin: Tokens.space.item

    color: Appearance.faint

    font.family: Tokens.font.ui
    font.pixelSize: Tokens.font.size.small
    font.bold: true
}
