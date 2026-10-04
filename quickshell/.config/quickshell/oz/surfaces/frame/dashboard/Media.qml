import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.components
import qs.config

Card {
    id: root

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        return players.find(p => p.isPlaying) ?? players[0] ?? null;
    }

    // Live streams report absurd lengths; treat anything over a day as unknown.
    readonly property bool hasLength: (player?.lengthSupported ?? false) && player.length > 0 && player.length < 86400

    function time(seconds: real): string {
        const s = Math.max(0, Math.floor(seconds));
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    // MPRIS only reports position on seeks, so poll it while playing.
    Timer {
        running: root.visible && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true

        onTriggered: root.player.positionChanged()
    }

    ColumnLayout {
        visible: !root.player

        Layout.fillWidth: true
        Layout.fillHeight: true

        Item {
            Layout.fillHeight: true
        }

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter

            text: "music_off"
            color: Appearance.faint
            font.pixelSize: Tokens.font.size.display
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Nothing playing"
            color: Appearance.faint

            font.family: Tokens.font.ui
            font.pixelSize: Tokens.font.size.normal
        }

        Item {
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        visible: !!root.player

        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: 0

        RowLayout {
            Layout.fillWidth: true

            spacing: Tokens.dashboard.artGap

            ClippingRectangle {
                implicitWidth: Tokens.dashboard.art
                implicitHeight: implicitWidth

                radius: Tokens.dashboard.cardRadius - 4
                color: Appearance.panel

                MaterialIcon {
                    anchors.centerIn: parent

                    visible: art.status !== Image.Ready

                    text: "music_note"
                    color: Appearance.faint
                    font.pixelSize: Tokens.font.size.display
                }

                Image {
                    id: art

                    anchors.fill: parent

                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 0

                spacing: 2

                Text {
                    Layout.fillWidth: true

                    text: root.player?.trackTitle || "Unknown title"
                    color: Appearance.text
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.title
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true

                    text: root.player?.trackArtist || root.player?.identity || ""
                    color: Appearance.dim
                    elide: Text.ElideRight

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.normal
                }

                Text {
                    Layout.fillWidth: true

                    visible: text !== ""

                    text: root.player?.trackAlbum ?? ""
                    color: Appearance.faint
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap

                    font.family: Tokens.font.ui
                    font.pixelSize: Tokens.font.size.small
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        ColumnLayout {
            visible: root.hasLength

            Layout.fillWidth: true

            spacing: 4

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 4
                radius: 2
                color: Appearance.panel

                Rectangle {
                    width: parent.width * Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1))
                    height: parent.height

                    radius: parent.radius
                    color: Appearance.accent
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6

                    enabled: root.player?.canSeek ?? false

                    onClicked: event => root.player.position = root.player.length * Math.max(0, Math.min(1, event.x / width))
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true

                    text: root.time(root.player?.position ?? 0)
                    color: Appearance.faint

                    font.family: Tokens.font.mono
                    font.pixelSize: Tokens.font.size.small
                }

                Text {
                    text: root.time(root.player?.length ?? 0)
                    color: Appearance.faint

                    font.family: Tokens.font.mono
                    font.pixelSize: Tokens.font.size.small
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            spacing: Tokens.dashboard.gap * 2

            IconButton {
                icon: "skip_previous"
                font.pixelSize: Tokens.icon.control
                enabled: root.player?.canGoPrevious ?? false

                onActivated: root.player.previous()
            }

            IconButton {
                icon: root.player?.isPlaying ? "pause_circle" : "play_circle"
                tint: Appearance.accent
                hoverTint: Appearance.text
                font.pixelSize: Tokens.icon.control + 10

                onActivated: root.player.togglePlaying()
            }

            IconButton {
                icon: "skip_next"
                font.pixelSize: Tokens.icon.control
                enabled: root.player?.canGoNext ?? false

                onActivated: root.player.next()
            }
        }
    }
}
