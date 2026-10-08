// Asks for the password when something needs admin rights.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    readonly property var flow: Services.Polkit.flow

    spacing: Tokens.space.item

    RowLayout {
        Layout.fillWidth: true

        spacing: Tokens.space.item

        MaterialIcon {
            Layout.alignment: Qt.AlignTop

            text: "admin_panel_settings"
            color: Appearance.accent
            font.pixelSize: Tokens.icon.control + 6
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 2

            Text {
                text: "Authentication required"
                color: Appearance.text

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.title
                font.bold: true
            }

            Text {
                Layout.fillWidth: true

                text: root.flow?.message ?? ""
                color: Appearance.dim
                wrapMode: Text.Wrap

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true

        implicitHeight: Tokens.launcher.inputHeight

        radius: Tokens.launcher.rowRadius
        color: Appearance.cell
        border.width: 1
        border.color: Services.Polkit.error ? Appearance.danger : Appearance.accent

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.launcher.padding
            anchors.rightMargin: Tokens.launcher.padding

            spacing: Tokens.space.item

            MaterialIcon {
                text: "key"
                font.pixelSize: Tokens.icon.control - 2
            }

            Text {
                Layout.fillWidth: true

                text: Services.Polkit.checking ? "Checking…" : "•".repeat(Services.Polkit.password.length) + "▏"
                color: Services.Polkit.checking ? Appearance.dim : Appearance.text
                elide: Text.ElideLeft

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        spacing: Tokens.space.item

        Text {
            Layout.fillWidth: true

            text: Services.Polkit.error || root.flow?.supplementaryMessage || "Enter to confirm · Esc to cancel"
            color: Services.Polkit.error || root.flow?.supplementaryIsError ? Appearance.danger : Appearance.faint
            elide: Text.ElideRight

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }

        IconButton {
            icon: "close"

            onActivated: Services.Polkit.cancel()
        }

        IconButton {
            icon: "check"
            tint: Appearance.accent

            onActivated: Services.Polkit.submit()
        }
    }
}
