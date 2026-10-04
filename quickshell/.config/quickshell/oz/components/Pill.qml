import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    default property alias content: row.data

    property int spacing: Tokens.space.tight

    Layout.alignment: Qt.AlignVCenter

    implicitWidth: row.implicitWidth + Tokens.pill.padding * 2
    implicitHeight: Tokens.pill.height

    radius: height / 2
    color: Appearance.cell

    RowLayout {
        id: row

        anchors.centerIn: parent

        spacing: root.spacing
    }
}
