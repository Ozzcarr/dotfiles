import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services as Services

RowLayout {
    id: root

    required property var screen

    Layout.alignment: Qt.AlignVCenter

    spacing: Tokens.space.item

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        Layout.alignment: Qt.AlignVCenter

        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Appearance.text

        font.family: Tokens.font.mono
        font.pixelSize: Tokens.font.size.large
        font.bold: true
    }

    Text {
        Layout.alignment: Qt.AlignVCenter

        text: Qt.formatDateTime(clock.date, "ddd dd MMM")
        color: Appearance.dim

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.small
    }

    TapHandler {
        onTapped: Services.Panels.toggle("dashboard", root.screen.name)
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
