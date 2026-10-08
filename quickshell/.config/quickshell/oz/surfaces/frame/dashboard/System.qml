import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services as Services

Card {
    Metric {
        icon: "memory"
        label: "CPU"
        value: Services.Sys.cpu
        history: Services.Sys.cpuHistory
    }

    Metric {
        visible: Services.Gpu.available

        icon: "monitoring"
        label: "GPU"
        value: Math.max(0, Services.Gpu.utilization)
        history: Services.Gpu.history
        detail: `${Services.Gpu.temperature}°C`
    }

    Metric {
        icon: "developer_board"
        label: "Memory"
        value: Services.Sys.memory
        history: Services.Sys.memoryHistory
        detail: `${(Services.Sys.memoryUsedMib / 1024).toFixed(1)} / ${(Services.Sys.memoryTotalMib / 1024).toFixed(0)} GiB`
    }

    MouseArea {
        id: updatesArea

        Layout.fillWidth: true

        implicitHeight: updates.implicitHeight

        hoverEnabled: true
        onClicked: {
            Services.Nix.view = "updates";
            Services.Panels.open("nix", Services.Panels.screen, "");
        }

        RowLayout {
            id: updates

            anchors.left: parent.left
            anchors.right: parent.right

            spacing: Tokens.space.tight

            MaterialIcon {
                text: Services.Updates.failed ? "sync_problem" : "sync"
                color: Services.Updates.failed ? Appearance.danger : Services.Updates.count > 0 ? Appearance.warning : Appearance.soft
            }

            Text {
                Layout.fillWidth: true

                text: Services.Updates.failed ? "Update check failed" : Services.Updates.count > 0 ? `${Services.Updates.count} updates available` : "Up to date"
                color: updatesArea.containsMouse ? Appearance.text : Appearance.dim
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }
        }
    }
}
