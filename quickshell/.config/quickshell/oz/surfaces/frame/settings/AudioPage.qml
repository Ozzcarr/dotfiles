// Output and input devices, and each app's volume.
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

ColumnLayout {
    spacing: Tokens.space.tight

    SectionLabel {
        text: "Output"
    }

    Repeater {
        model: Services.Audio.sinks

        ListRow {
            required property var modelData

            icon: "speaker"
            title: Services.Audio.label(modelData)
            selected: modelData === Services.Audio.sink

            onClicked: Services.Audio.setSink(modelData)
        }
    }

    SectionLabel {
        text: "Input"
    }

    Repeater {
        model: Services.Audio.sources

        ListRow {
            required property var modelData

            icon: "mic"
            title: Services.Audio.label(modelData)
            selected: modelData === Services.Audio.source

            onClicked: Services.Audio.setSource(modelData)
        }
    }

    SectionLabel {
        visible: Services.Audio.streams.length > 0

        text: "Apps"
    }

    Repeater {
        model: Services.Audio.streams

        ColumnLayout {
            id: stream

            required property var modelData

            Layout.fillWidth: true
            Layout.leftMargin: Tokens.space.item

            spacing: 0

            Text {
                text: Services.Audio.label(stream.modelData)
                color: Appearance.text

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }

            SettingsSlider {
                Layout.fillWidth: true

                icon: muted ? "volume_off" : "volume_up"
                muted: stream.modelData.audio?.muted ?? false
                value: stream.modelData.audio?.volume ?? 0

                onMoved: value => Services.Audio.setVolume(stream.modelData, value)
                onIconClicked: Services.Audio.toggleMute(stream.modelData)
            }
        }
    }
}
