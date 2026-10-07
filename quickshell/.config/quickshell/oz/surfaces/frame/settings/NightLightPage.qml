// Night light on or off, and how warm and dim it is. Changes show right away
// while it is on.
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services as Services

ColumnLayout {
    id: root

    readonly property var light: Services.NightLight
    readonly property int range: light.maxTemperature - light.minTemperature

    spacing: Tokens.space.tight

    ListRow {
        icon: root.light.enabled ? "nightlight" : "light_mode"
        title: "Night light"
        subtitle: root.light.enabled ? "On" : "Off"
        selected: root.light.enabled

        onClicked: root.light.toggle()
    }

    SectionLabel {
        text: "Warmth"
    }

    // Right is warmer, so the slider fills as the light gets warmer.
    SettingsSlider {
        Layout.fillWidth: true

        icon: "thermostat"
        value: (root.light.maxTemperature - root.light.temperature) / root.range
        valueText: `${root.light.temperature}K`

        onMoved: value => root.light.setTemperature(Math.round((root.light.maxTemperature - value * root.range) / 100) * 100)
        onIconClicked: root.light.toggle()
    }

    SectionLabel {
        text: "Brightness"
    }

    SettingsSlider {
        Layout.fillWidth: true

        icon: "brightness_6"
        value: (root.light.gamma - root.light.minGamma) / (100 - root.light.minGamma)
        valueText: `${root.light.gamma}%`

        onMoved: value => root.light.setGamma(Math.round(root.light.minGamma + value * (100 - root.light.minGamma)))
        onIconClicked: root.light.toggle()
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.space.item
        Layout.topMargin: Tokens.space.tight

        visible: !root.light.enabled

        text: "Turn it on to see changes as you make them."
        color: Appearance.faint
        wrapMode: Text.Wrap

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.small
    }
}
