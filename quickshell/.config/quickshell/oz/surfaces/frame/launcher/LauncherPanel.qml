import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services.launcher

ColumnLayout {
    id: root


    // An empty list still shows one row, for the hint or "No results".
    readonly property int rows: Math.max(1, Math.min(Launcher.results.length, Tokens.launcher.rows))

    spacing: Tokens.launcher.gap

    SearchField {
        Layout.fillWidth: true
    }

    Item {
        Layout.fillWidth: true

        implicitHeight: root.rows * Tokens.launcher.rowHeight

        ListView {
            id: list

            anchors.fill: parent

            visible: count > 0
            clip: true

            model: Launcher.results
            currentIndex: Launcher.current
            boundsBehavior: Flickable.StopAtBounds

            highlightMoveDuration: Motion.fast
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: height

            delegate: ResultRow {}
        }

        Text {
            anchors.centerIn: parent

            visible: list.count === 0

            text: Launcher.query.trim() !== "" ? "No results" : Launcher.mode.emptyHint
            color: Appearance.faint

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }
    }
}
