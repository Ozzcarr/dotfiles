// Networks in range. Typing for the password prompt happens in the frame's
// keyboard surface; the fields here mirror it.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.components
import qs.config
import qs.services as Services
import qs.services.launcher

ColumnLayout {
    id: root

    readonly property var wifi: Services.Wifi

    function signalIcon(network: var): string {
        const strength = network.signalStrength;
        return strength > 0.66 ? "wifi" : strength > 0.33 ? "wifi_2_bar" : "wifi_1_bar";
    }

    function describe(network: var): string {
        if (network.connected)
            return "Connected";
        if (network.stateChanging)
            return "Connecting…";
        if (network.known)
            return "Saved";
        if (network.security === WifiSecurityType.Open)
            return "Open";
        return Services.Wifi.isEnterprise(network) ? "Enterprise" : "Secured";
    }

    // Scan only while the page is up.
    Component.onCompleted: root.wifi.setScanning(true)
    Component.onDestruction: root.wifi.setScanning(false)

    spacing: Tokens.space.tight

    Text {
        Layout.fillWidth: true
        Layout.margins: Tokens.space.item

        visible: root.wifi.device === null

        text: "No Wi-Fi adapter"
        color: Appearance.faint
        horizontalAlignment: Text.AlignHCenter

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.normal
    }

    ListRow {
        visible: root.wifi.device !== null

        icon: root.wifi.enabled ? "wifi" : "wifi_off"
        title: "Wi-Fi"
        subtitle: root.wifi.enabled ? "On" : "Off"
        selected: root.wifi.enabled

        onClicked: root.wifi.setEnabled(!root.wifi.enabled)
    }

    // Credentials for the network being joined.
    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.space.tight

        visible: root.wifi.prompting !== null

        spacing: Tokens.space.tight

        SectionLabel {
            text: `Join ${root.wifi.prompting?.name ?? ""}`
        }

        PromptField {
            visible: root.wifi.enterprise

            label: "Username"
            text: root.wifi.identity
            active: root.wifi.field === "identity"
        }

        PromptField {
            label: "Password"
            text: "•".repeat(root.wifi.password.length)
            active: root.wifi.field === "password"
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.space.item

            text: "Enter to connect, Esc to cancel"
            color: Appearance.faint

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.small
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.space.item

        visible: root.wifi.error !== ""

        text: root.wifi.error
        color: Appearance.danger
        wrapMode: Text.Wrap

        font.family: Tokens.font.ui
        font.pixelSize: Tokens.font.size.small
    }

    SectionLabel {
        visible: root.wifi.enabled && root.wifi.networks.length > 0

        text: "Networks"
    }

    Repeater {
        model: root.wifi.enabled ? root.wifi.networks : []

        ListRow {
            required property var modelData

            icon: root.signalIcon(modelData)
            title: modelData.name
            subtitle: root.describe(modelData)
            selected: modelData.connected
            actionIcon: modelData.known ? "delete" : ""

            onClicked: modelData.connected ? modelData.disconnect() : root.wifi.connect(modelData)
            onAction: modelData.forget()
        }
    }

    // Anything the prompt can't do, like certificate files.
    ListRow {
        visible: root.wifi.device !== null

        icon: "terminal"
        title: "Open in impala"
        subtitle: "For network setups this panel doesn't cover"

        onClicked: {
            Services.Panels.close();
            Quickshell.execDetached([Launcher.terminal, "--title", "impala", "-e", "impala"]);
        }
    }
}
