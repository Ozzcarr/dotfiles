// A Slider reachable with the keyboard: Left and Right step it 5%, Enter
// presses its icon (usually mute).
import QtQuick
import qs.components

Slider {
    id: root

    highlighted: nav.focused

    NavTarget {
        id: nav

        steps: true

        onActivated: root.iconClicked()
        onStepped: delta => root.moved(Math.max(0, Math.min(1, root.value + delta * 0.05)))
    }
}
