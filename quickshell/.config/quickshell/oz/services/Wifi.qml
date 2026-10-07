// Wi-Fi through NetworkManager. Saved networks, eduroam included, connect
// directly. New password networks ask for the password; new enterprise ones
// ask for a username too and are added with nmcli, which takes the full 802.1X
// setup that Quickshell's settings object makes awkward from QML.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool enabled: Networking.wifiEnabled

    // Connected first, then known, then by signal.
    readonly property var networks: [...(device?.networks.values ?? [])].sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))

    // The network waiting for credentials, and what is typed so far. The
    // fields are edited in the frame's keyboard surface.
    property var prompting: null
    readonly property bool enterprise: prompting !== null && isEnterprise(prompting)
    // "identity" or "password".
    property string field: "password"
    property string identity: ""
    property string password: ""
    property string error: ""

    function isEnterprise(network: var): bool {
        return [WifiSecurityType.Wpa2Eap, WifiSecurityType.WpaEap, WifiSecurityType.Wpa3SuiteB192, WifiSecurityType.Leap].includes(network.security);
    }

    function setEnabled(on: bool): void {
        Networking.wifiEnabled = on;
    }

    function setScanning(on: bool): void {
        if (root.device)
            root.device.scannerEnabled = on;
    }

    function connect(network: var): void {
        root.cancel();
        if (network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe) {
            network.connect();
            return;
        }
        root.prompting = network;
        root.field = root.enterprise ? "identity" : "password";
    }

    function cancel(): void {
        root.prompting = null;
        root.identity = "";
        root.password = "";
        root.error = "";
    }

    // Enter in the prompt: next field, or connect.
    function submit(): void {
        if (!root.prompting)
            return;
        if (root.field === "identity") {
            root.field = "password";
            return;
        }

        if (root.enterprise) {
            // PEAP with MSCHAPv2 inside is what eduroam and most campus networks use.
            const ssid = root.prompting.name;
            nmcli.command = ["sh", "-c", 'nmcli connection add type wifi con-name "$1" ssid "$1" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity "$2" 802-1x.password "$3" && nmcli connection up "$1"', "sh", ssid, root.identity, root.password];
            nmcli.running = true;
        } else {
            root.prompting.connectWithPsk(root.password);
        }
        root.cancel();
    }

    Process {
        id: nmcli

        stderr: StdioCollector {
            onStreamFinished: root.error = text.trim()
        }
    }
}
