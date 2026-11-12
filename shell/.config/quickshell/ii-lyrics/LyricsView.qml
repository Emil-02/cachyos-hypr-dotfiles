import QtQuick
import QtQuick.Effects

// Daftar lirik bergulir dengan baris aktif yang membesar, menyala, dan terisi
// warna mengikuti waktu (efek karaoke).
Item {
    id: lv

    required property var core
    property real currentSize: 34
    property real otherSize: 21
    property real lineHeight: currentSize * 1.75
    property bool onlyCurrent: false
    property bool fadeEdges: true
    property color hi: core.col("primary", "#a8c7fa")
    property color fg: core.col("on_surface", "#e3e2e6")
    property string fontFamily: "Google Sans Flex"

    readonly property var lines: core.lines
    readonly property int idx: core.index

    layer.enabled: fadeEdges && !onlyCurrent
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: edgeMask
        maskThresholdMin: 0.0
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        id: edgeMask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.28; color: "black" }
            GradientStop { position: 0.72; color: "black" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Bayangan lembut agar lirik tetap terbaca di atas wallpaper terang
    Item {
        id: shadowed
        anchors.fill: parent
        layer.enabled: !lv.onlyCurrent
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.55
            shadowBlur: 0.8
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 2
            blurMax: 24
        }

    ListView {
        id: list
        anchors.fill: parent
        model: lv.lines.length
        currentIndex: Math.max(0, lv.idx)
        interactive: false
        clip: lv.onlyCurrent
        highlight: Item {}
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: height / 2 - lv.lineHeight / 2
        preferredHighlightEnd: height / 2 + lv.lineHeight / 2
        highlightMoveDuration: 520
        highlightMoveVelocity: -1
        cacheBuffer: 600

        delegate: Item {
            id: d

            required property int index
            readonly property var entry: lv.lines[index] ?? [0, ""]
            readonly property real t0: entry[0]
            readonly property real t1: index + 1 < lv.lines.length ? lv.lines[index + 1][0] : Math.max(t0 + 4, lv.core.length)
            readonly property string txt: entry[1]
            readonly property bool cur: index === lv.idx
            readonly property bool past: index < lv.idx
            readonly property int dist: Math.abs(index - list.currentIndex)
            readonly property real progress: cur ? Math.max(0, Math.min(1, (lv.core.pos - t0) / Math.max(0.2, t1 - t0))) : (past ? 1 : 0)

            width: list.width
            height: lv.lineHeight

            opacity: lv.onlyCurrent ? (cur ? 1 : 0)
                   : cur ? 1
                   : Math.max(0, 0.62 - (dist - 1) * 0.2)
            Behavior on opacity { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

            scale: cur ? 1 : lv.otherSize / lv.currentSize
            Behavior on scale { NumberAnimation { duration: 560; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }

            // Garis lirik dasar (redup saat aktif, lalu terisi oleh lapisan sorot)
            Text {
                id: base
                anchors.centerIn: parent
                width: parent.width - 48
                height: parent.height
                visible: d.txt !== ""
                text: d.txt
                color: d.cur && lv.core.synced ? Qt.alpha(lv.fg, 0.5) : lv.fg
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: lv.fontFamily
                font.pixelSize: lv.currentSize
                font.weight: 650
                font.letterSpacing: -0.2
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: 12
                renderType: Text.QtRendering
            }

            // Lapisan sorot: menyapu dari kiri ke kanan mengikuti waktu
            Item {
                id: sweep
                visible: d.cur && lv.core.synced && d.txt !== ""
                x: base.x + (base.width - base.contentWidth) / 2 - 8
                y: base.y
                height: base.height
                width: (base.contentWidth + 16) * d.progress
                clip: true

                Text {
                    x: base.x - sweep.x
                    width: base.width
                    height: base.height
                    text: d.txt
                    color: lv.hi
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: base.font
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: 12
                    renderType: Text.QtRendering
                }
            }

            // Cahaya lembut di belakang baris aktif, berdenyut mengikuti bass
            MultiEffect {
                source: sweep
                anchors.fill: sweep
                visible: sweep.visible
                z: -1
                shadowEnabled: true
                shadowColor: lv.hi
                shadowBlur: 1.0
                shadowOpacity: 0.35 + lv.core.bass * 0.5
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                blurMax: 40
                opacity: 0.9
            }

            // Jeda instrumental: tiga titik yang terisi menuju baris berikutnya
            Row {
                anchors.centerIn: parent
                visible: d.txt === ""
                spacing: lv.currentSize * 0.4

                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        readonly property bool on: d.cur && d.progress > (index + 0.5) / 3.5
                        width: lv.currentSize * 0.32
                        height: width
                        radius: width / 2
                        color: on ? lv.hi : lv.fg
                        opacity: d.cur ? (on ? 1 : 0.28) : 0.22
                        scale: on ? 1.0 + lv.core.bass * 0.55 : (d.cur ? 0.85 : 0.7)
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }
            }
        }
    }
    }
}
