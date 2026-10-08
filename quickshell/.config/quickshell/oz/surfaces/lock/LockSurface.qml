// What one screen shows while locked: the wallpaper, the time and the password
// field. It starts as a snapshot of the desktop and fades into itself, and
// fades back before unlocking. Typing goes into whichever screen has focus.
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs.components
import qs.config
import qs.services as Services

WlSessionLockSurface {
    id: root

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? null

    // Follows Lock.revealed, but starts false so the fade in runs.
    property bool shown: false

    color: Appearance.panel

    Component.onCompleted: shown = Qt.binding(() => Services.Lock.revealed)

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Image {
        id: wallpaper

        anchors.fill: parent

        source: Services.Wallpaper.path ? `file://${Services.Wallpaper.path}` : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    MultiEffect {
        anchors.fill: wallpaper

        source: wallpaper
        blurEnabled: true
        blur: Tokens.lock.blur
        blurMax: 64
        brightness: -Tokens.lock.dim
    }

    Image {
        anchors.fill: parent

        source: Services.Lock.snapshot(root.screen?.name ?? "")
        fillMode: Image.PreserveAspectCrop
        cache: false

        opacity: root.shown ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: Services.Lock.fade
                easing.type: Easing.OutCubic
            }
        }
    }

    ColumnLayout {
        id: content

        anchors.centerIn: parent

        spacing: Tokens.space.item

        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Services.Lock.fade
                easing.type: Easing.OutCubic
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Appearance.text

            font.family: Tokens.font.mono
            font.pixelSize: Tokens.lock.clockSize
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: Tokens.space.item * 3

            text: Qt.formatDateTime(clock.date, "dddd d MMMM")
            color: Appearance.dim

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.title + 4
        }

        Rectangle {
            id: field

            Layout.alignment: Qt.AlignHCenter

            implicitWidth: Tokens.lock.fieldWidth
            implicitHeight: Tokens.lock.fieldHeight

            radius: height / 2
            color: Qt.alpha(Appearance.panel, Tokens.opacity.panel)
            border.width: 1
            border.color: Services.Lock.error !== "" ? Appearance.danger : input.activeFocus ? Appearance.accent : "transparent"

            // A shake when the password is wrong.
            transform: Translate {
                id: shake
            }

            SequentialAnimation {
                id: shakeAnimation

                loops: 2

                NumberAnimation {
                    target: shake
                    property: "x"
                    to: 10
                    duration: 50
                }

                NumberAnimation {
                    target: shake
                    property: "x"
                    to: -10
                    duration: 80
                }

                NumberAnimation {
                    target: shake
                    property: "x"
                    to: 0
                    duration: 50
                }
            }

            Connections {
                target: Services.Lock

                function onErrorChanged(): void {
                    if (Services.Lock.error !== "") {
                        input.clear();
                        shakeAnimation.restart();
                    }
                }
            }

            MaterialIcon {
                anchors.left: parent.left
                anchors.leftMargin: Tokens.space.item + 4
                anchors.verticalCenter: parent.verticalCenter

                text: Services.Lock.checking ? "hourglass_top" : "lock"
                color: Appearance.dim
                font.pixelSize: Tokens.icon.control - 2
            }

            TextInput {
                id: input

                anchors.fill: parent
                anchors.leftMargin: Tokens.space.item * 4 + 4
                anchors.rightMargin: Tokens.space.item * 2

                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                focus: true
                enabled: !Services.Lock.checking
                clip: true

                color: Appearance.text
                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.title
                font.letterSpacing: 2

                cursorDelegate: Rectangle {
                    width: 2
                    radius: 1
                    color: Appearance.accent
                }

                onAccepted: Services.Lock.submit(text)

                Keys.onEscapePressed: clear()
            }

            Text {
                anchors.left: input.left
                anchors.verticalCenter: parent.verticalCenter

                visible: input.text === ""

                text: Services.Lock.checking ? "Checking…" : "Password"
                color: Appearance.faint

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.large
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            opacity: Services.Lock.error !== "" ? 1 : 0

            text: Services.Lock.error || " "
            color: Appearance.danger

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }
    }

    // What's playing and what came in while away.
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48

        opacity: content.opacity

        spacing: Tokens.space.item * 2

        RowLayout {
            visible: root.player !== null

            spacing: Tokens.space.item

            MaterialIcon {
                text: "music_note"
                color: Appearance.accent
            }

            Text {
                Layout.maximumWidth: 360

                text: [root.player?.trackTitle, root.player?.trackArtist].filter(Boolean).join(" · ")
                color: Appearance.dim
                elide: Text.ElideRight

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }

            IconButton {
                icon: "pause"
                font.pixelSize: Tokens.icon.control

                onActivated: root.player.pause()
            }
        }

        RowLayout {
            visible: Services.Notifications.hasNotifications

            spacing: Tokens.space.tight

            MaterialIcon {
                text: "notifications"
                color: Appearance.dim
            }

            Text {
                text: `${Services.Notifications.all.length} new`
                color: Appearance.dim

                font.family: Tokens.font.ui
                font.pixelSize: Tokens.font.size.normal
            }
        }
    }
}
