import QtQuick
import QtQuick.Effects

// Kartu "sedang diputar": sampul berputar seperti piringan, latar sampul ter-blur,
// judul, artis, progres, dan tombol kontrol.
Item {
    id: card

    required property var core
    property bool showControls: true
    readonly property var p: core.player
    readonly property color hi: core.col("primary", "#a8c7fa")
    readonly property color fg: core.col("on_surface", "#e3e2e6")
    readonly property color fgDim: core.col("on_surface_variant", "#c4c6d0")
    readonly property color surf: core.col("surface_container", "#1e1f25")
    readonly property color line: core.col("outline_variant", "#44474e")
    readonly property real radius: height / 2

    function fmt(s) {
        s = Math.max(0, Math.floor(s || 0));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    // Latar: sampul ter-blur + lapisan warna tema
    Item {
        id: bg
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: bgMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        Rectangle { anchors.fill: parent; color: card.surf; opacity: 0.82 }

        Image {
            anchors.fill: parent
            source: card.core.artUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            opacity: status === Image.Ready ? 0.55 : 0
            Behavior on opacity { NumberAnimation { duration: 600 } }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 64
                saturation: 0.25
                brightness: -0.18
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.alpha(card.surf, 0.25) }
                GradientStop { position: 1.0; color: Qt.alpha(card.surf, 0.7) }
            }
        }
    }

    Rectangle {
        id: bgMask
        anchors.fill: parent
        radius: card.radius
        visible: false
        layer.enabled: true
    }

    Rectangle {
        anchors.fill: parent
        radius: card.radius
        color: "transparent"
        border.width: 1
        border.color: Qt.alpha(card.line, 0.6)
    }

    // Sampul berbentuk piringan
    NowPlayingDisc {
        id: disc
        core: card.core
        width: card.height - 16
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
    }

    // Judul, artis, progres
    Column {
        anchors.left: disc.right
        anchors.leftMargin: 14
        anchors.right: controls.visible ? controls.left : parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Text {
            width: parent.width
            text: card.core.title || "Tidak ada media"
            color: card.fg
            font.family: "Google Sans Flex"
            font.pixelSize: 15
            font.weight: 600
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: card.core.artist
            color: card.fgDim
            font.family: "Google Sans Flex"
            font.pixelSize: 12
            elide: Text.ElideRight
            visible: text !== ""
        }

        Item {
            width: parent.width
            height: 16

            Rectangle {
                id: track
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: 2
                color: Qt.alpha(card.fg, 0.15)

                Rectangle {
                    width: parent.width * (card.core.length > 0 ? Math.min(1, card.core.pos / card.core.length) : 0)
                    height: parent.height
                    radius: 2
                    color: card.hi
                }
            }
        }

        Row {
            width: parent.width
            Text {
                width: parent.width / 2
                text: card.fmt(card.core.pos)
                color: card.fgDim
                font.family: "Google Sans Flex"
                font.pixelSize: 10
            }
            Text {
                width: parent.width / 2
                horizontalAlignment: Text.AlignRight
                text: card.core.status === "loading" ? "mencari lirik…" : card.fmt(card.core.length)
                color: card.fgDim
                font.family: "Google Sans Flex"
                font.pixelSize: 10
            }
        }
    }

    // Tombol kontrol
    Row {
        id: controls
        visible: card.showControls
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: [
                { icon: "skip_previous", act: "prev", big: false },
                { icon: card.core.playing ? "pause" : "play_arrow", act: "toggle", big: true },
                { icon: "skip_next", act: "next", big: false }
            ]

            Rectangle {
                required property var modelData
                width: modelData.big ? 44 : 34
                height: width
                radius: modelData.big ? 14 : width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.big ? card.hi : (ma.containsMouse ? Qt.alpha(card.fg, 0.12) : "transparent")
                scale: ma.pressed ? 0.88 : 1
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 160 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: modelData.big ? 26 : 22
                    color: modelData.big ? card.core.col("on_primary", "#0b305f") : card.fg
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!card.p) return;
                        if (modelData.act === "toggle") card.p.togglePlaying();
                        else if (modelData.act === "next") card.p.next();
                        else card.p.previous();
                    }
                }
            }
        }
    }
}
