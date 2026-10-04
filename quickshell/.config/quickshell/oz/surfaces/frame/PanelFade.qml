// `PanelFade on opacity {}`: fades out first, then in, so when Drop switches
// between panels the two never show at once.
import QtQuick
import qs.config

Behavior {
    id: root

    SequentialAnimation {
        PauseAnimation {
            duration: root.targetValue > 0 ? Motion.fast : 0
        }

        NumberAnimation {
            duration: Motion.fast
        }
    }
}
