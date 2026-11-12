import QtQuick
import QtQuick.Effects

// Sampul lagu berbentuk piringan yang berputar saat musik diputar.
Item {
    id: disc

    required property var core
    readonly property color hi: core.col("primary", "#a8c7fa")

    scale: 1 + core.bass * 0.06

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: disc.core.col("surface_container_highest", "#33353a")
    }

    Image {
        id: art
        anchors.fill: parent
        source: disc.core.artUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 256
        sourceSize.height: 256
        visible: false
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: width / 2
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: art
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        visible: art.status === Image.Ready

        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 18000
            loops: Animation.Infinite
            running: true
            paused: !disc.core.playing
        }
    }

    Text {
        anchors.centerIn: parent
        visible: art.status !== Image.Ready
        text: "music_note"
        font.family: "Material Symbols Rounded"
        font.pixelSize: parent.width * 0.5
        color: disc.hi
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 0.16
        height: width
        radius: width / 2
        color: disc.core.col("surface_container", "#1e1f25")
        border.width: Math.max(1, parent.width / 32)
        border.color: Qt.alpha(disc.hi, 0.7)
        visible: art.status === Image.Ready
    }
}
