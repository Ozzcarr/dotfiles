import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    spacing: Tokens.dashboard.gap

    Calendar {
        Layout.preferredWidth: Tokens.dashboard.calendarWidth
        Layout.fillHeight: true
    }

    Media {
        Layout.preferredWidth: Tokens.dashboard.mediaWidth
        Layout.fillHeight: true
    }

    System {
        Layout.preferredWidth: Tokens.dashboard.systemWidth
        Layout.fillHeight: true
    }
}
