// Makes its parent reachable with the keyboard in quick settings. Left and
// Right adjust controls that `steps`; on others Right opens an `expandable`
// control's page and Left goes back.
import QtQuick
import qs.services as Services

Item {
    id: root

    property bool steps: false
    property bool expandable: false

    readonly property bool focused: Services.SettingsNav.current === root

    signal activated
    signal stepped(int delta)
    signal expanded
    signal secondaryActivated

    function step(delta: int): void {
        if (root.steps)
            root.stepped(delta);
        else if (delta > 0 && root.expandable)
            root.expanded();
        else if (delta < 0)
            Services.Panels.page = "";
    }

    Component.onCompleted: Services.SettingsNav.add(root)
    Component.onDestruction: Services.SettingsNav.remove(root)
}
