import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    default property alias content: column.data

    property int spacing: Tokens.space.item

    radius: Tokens.dashboard.cardRadius
    color: Appearance.cell

    ColumnLayout {
        id: column

        anchors.fill: parent
        anchors.margins: Tokens.dashboard.cardPadding

        spacing: root.spacing
    }
}
