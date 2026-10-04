// The notification daemon. Every notification is kept in the history until
// dismissed; new ones also show as popups until they time out.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    // Newest first.
    readonly property var all: [...server.trackedNotifications.values].reverse()
    readonly property var popups: all.filter(n => popupIds.includes(n.id))
    readonly property bool hasNotifications: all.length > 0

    readonly property bool dnd: state.dnd

    // Ids of notifications currently shown as popups.
    property list<int> popupIds: []

    function hidePopup(notification: Notification): void {
        root.popupIds = root.popupIds.filter(id => id !== notification.id);
        if (notification.transient)
            notification.expire();
    }

    function clearAll(): void {
        for (const notification of root.all)
            notification.dismiss();
    }

    function toggleDnd(): void {
        state.dnd = !state.dnd;
        stateFile.writeAdapter();
        Osd.show(state.dnd ? "notifications_off" : "notifications", state.dnd ? "Do not disturb on" : "Do not disturb off", -1);
    }

    // Clicking a notification runs its default action if it has one.
    function activate(notification: Notification): void {
        const action = notification.actions.find(a => a.identifier === "default");
        if (action)
            action.invoke();
        else
            notification.dismiss();
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;

            if (!root.dnd || notification.urgency === NotificationUrgency.Critical)
                root.popupIds = [notification.id, ...root.popupIds];
        }
    }

    FileView {
        id: stateFile

        path: Quickshell.statePath("notifications.json")
        blockLoading: true
        printErrors: false

        onLoadFailed: writeAdapter()

        JsonAdapter {
            id: state

            property bool dnd: false
        }
    }

    IpcHandler {
        target: "notifications"

        function toggle(): void {
            Panels.toggle("notifications", Panels.focusedScreen);
        }

        function clear(): void {
            root.clearAll();
        }

        function dnd(): void {
            root.toggleDnd();
        }
    }
}
