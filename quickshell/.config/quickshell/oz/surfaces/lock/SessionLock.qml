import QtQuick
import Quickshell.Wayland
import qs.services as Services

WlSessionLock {
    locked: Services.Lock.locked

    onSecureChanged: Services.Lock.secure = secure

    surface: Component {
        LockSurface {}
    }
}
