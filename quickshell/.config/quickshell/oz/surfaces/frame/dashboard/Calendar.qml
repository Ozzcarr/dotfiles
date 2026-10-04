import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.config

Card {
    id: root

    property date shown: new Date()

    readonly property date today: clock.date
    readonly property int year: shown.getFullYear()
    readonly property int month: shown.getMonth()
    readonly property date thisMonday: new Date(today.getFullYear(), today.getMonth(), today.getDate() - (today.getDay() + 6) % 7)
    readonly property int weekWidth: 22

    // Monday-first grid of 42 days, starting on the Monday on or before the 1st.
    readonly property var days: {
        const first = new Date(year, month, 1);
        const start = new Date(year, month, 1 - (first.getDay() + 6) % 7);
        return Array.from({ length: 42 }, (_, i) => new Date(start.getFullYear(), start.getMonth(), start.getDate() + i));
    }

    // ISO 8601: a week belongs to the year its Thursday falls in.
    function isoWeek(monday: date): int {
        const thursday = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + 3);
        const jan1 = new Date(thursday.getFullYear(), 0, 1);
        return Math.floor(Math.round((thursday - jan1) / 86400000) / 7) + 1;
    }

    function step(months: int): void {
        root.shown = new Date(root.year, root.month + months, 1);
    }

    spacing: 6

    SystemClock {
        id: clock

        precision: SystemClock.Hours
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true

            text: Qt.formatDate(root.shown, "MMMM yyyy")
            color: Appearance.text

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.title
            font.bold: true
        }

        IconButton {
            icon: "chevron_left"

            onActivated: root.step(-1)
        }

        IconButton {
            icon: "chevron_right"

            onActivated: root.step(1)
        }
    }

    // Column 0 holds week numbers, column 1 the divider, 2-8 the days.
    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        rowSpacing: 2
        columnSpacing: 4

        Text {
            Layout.row: 0
            Layout.column: 0
            Layout.preferredWidth: root.weekWidth

            text: "W"
            color: Appearance.faint
            horizontalAlignment: Text.AlignHCenter

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }

        Rectangle {
            Layout.row: 1
            Layout.column: 1
            Layout.rowSpan: 6
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4

            implicitWidth: 1
            color: Appearance.faint
            opacity: 0.35
        }

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            Text {
                required property string modelData
                required property int index

                Layout.row: 0
                Layout.column: index + 2
                Layout.fillWidth: true

                text: modelData
                color: Appearance.dim
                horizontalAlignment: Text.AlignHCenter

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.small
            }
        }

        Repeater {
            model: root.days.length / 7

            Text {
                required property int index

                readonly property date monday: root.days[index * 7]
                readonly property bool isThisWeek: monday.toDateString() === root.thisMonday.toDateString()

                Layout.row: index + 1
                Layout.column: 0
                Layout.preferredWidth: root.weekWidth
                Layout.fillHeight: true

                text: root.isoWeek(monday)
                color: isThisWeek ? Appearance.accent : Appearance.faint
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                font.family: Tokens.font.mono
                font.pixelSize: Tokens.font.size.small
                font.bold: isThisWeek
            }
        }

        Repeater {
            model: root.days

            Rectangle {
                id: day

                required property date modelData
                required property int index

                readonly property bool inMonth: modelData.getMonth() === root.month
                readonly property bool isToday: modelData.toDateString() === root.today.toDateString()

                Layout.row: Math.floor(index / 7) + 1
                Layout.column: index % 7 + 2
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: height / 2
                color: isToday ? Appearance.accent : "transparent"

                Text {
                    anchors.centerIn: parent

                    text: day.modelData.getDate()
                    color: day.isToday ? Appearance.onAccent : day.inMonth ? Appearance.text : Appearance.faint

                    font.family: Tokens.font.mono
                    font.pixelSize: Tokens.font.size.normal
                    font.bold: day.isToday
                }
            }
        }
    }

    WheelHandler {
        onWheel: event => root.step(event.angleDelta.y > 0 ? -1 : 1)
    }
}
