// The session's polkit agent: when something asks for admin rights, the
// center drop turns into a password prompt, then goes back to whatever was
// open before. Closing the prompt cancels the request.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    readonly property AuthFlow flow: agent.flow
    readonly property bool active: agent.isActive
    readonly property bool registered: agent.isRegistered

    // Mirrors the keyboard surface's field; cleared once submitted.
    property string password: ""
    property bool checking: false
    property string error: ""

    // The panel the prompt replaced.
    property var previous: null

    function submit(): void {
        if (!root.flow?.isResponseRequired || root.password === "")
            return;
        root.checking = true;
        root.error = "";
        root.flow.submit(root.password);
        root.password = "";
    }

    function cancel(): void {
        root.flow?.cancelAuthenticationRequest();
    }

    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            root.password = "";
            root.checking = false;
            root.error = "";
            if (Panels.panel !== "polkit")
                root.previous = { panel: Panels.panel, screen: Panels.screen, page: Panels.page };
            Panels.open("polkit", Panels.focusedScreen, "");
        }

        onIsActiveChanged: {
            if (isActive)
                return;
            root.password = "";
            root.checking = false;
            if (Panels.panel === "polkit") {
                const back = root.previous;
                if (back?.panel)
                    Panels.open(back.panel, back.screen, back.page);
                else
                    Panels.close();
            }
            root.previous = null;
        }
    }

    Connections {
        target: root.flow

        function onIsResponseRequiredChanged(): void {
            if (root.flow.isResponseRequired)
                root.checking = false;
        }

        function onAuthenticationFailed(): void {
            root.checking = false;
            root.error = "Wrong password";
        }
    }

    Connections {
        target: Panels

        function onPanelChanged(): void {
            if (root.active && Panels.panel !== "polkit")
                root.cancel();
        }
    }
}
