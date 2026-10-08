// OBS's replay buffer: on or off, and how much the save key keeps.
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    readonly property var replay: Services.Replay
    readonly property int range: replay.maxLength - replay.minLength

    spacing: Tokens.space.tight

    ListRow {
        icon: root.replay.active ? "movie" : "videocam_off"
        title: "Replay buffer"
        subtitle: !root.replay.available ? "OBS isn't running" : root.replay.active ? "Recording" : "Off"
        selected: root.replay.active

        onClicked: root.replay.toggle()
    }

    SectionLabel {
        text: "Length"
    }

    SettingsSlider {
        Layout.fillWidth: true

        enabled: root.replay.available

        icon: "timer"
        value: (root.replay.length - root.replay.minLength) / root.range
        valueText: `${root.replay.length}s`

        onMoved: value => root.replay.setLength(Math.round((root.replay.minLength + value * root.range) / 15) * 15)
        onIconClicked: root.replay.toggle()
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.space.item
        Layout.topMargin: Tokens.space.tight

        text: root.replay.available ? "Changing the length restarts the buffer, so the replay so far is lost." : "Start OBS with its WebSocket server on to change these."
        color: Appearance.faint
        wrapMode: Text.Wrap

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.small
    }
}
