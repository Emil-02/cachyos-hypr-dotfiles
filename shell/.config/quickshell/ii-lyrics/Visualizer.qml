import QtQuick

// Batang visualizer simetris dari data cava.
Item {
    id: vis

    required property var core
    property color barColor: core.col("primary", "#a8c7fa")
    property real maxOpacity: 0.55
    property int barWidth: 5
    property int gap: 4
    property bool mirrorVertical: false

    readonly property var bars: core.bars
    readonly property int half: bars.length

    opacity: core.playing ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 600 } }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: vis.mirrorVertical ? undefined : parent.bottom
        anchors.verticalCenter: vis.mirrorVertical ? parent.verticalCenter : undefined
        spacing: vis.gap
        height: parent.height

        Repeater {
            model: vis.half * 2

            Rectangle {
                required property int index
                readonly property int src: index < vis.half ? vis.half - 1 - index : index - vis.half
                readonly property real v: Math.min(1, vis.bars[src] ?? 0)
                anchors.bottom: vis.mirrorVertical ? undefined : parent.bottom
                anchors.verticalCenter: vis.mirrorVertical ? parent.verticalCenter : undefined
                width: vis.barWidth
                height: Math.max(width, v * vis.height)
                radius: width / 2
                color: vis.barColor
                opacity: (0.18 + v * 0.82) * vis.maxOpacity * (1 - Math.abs(index - vis.half + 0.5) / (vis.half * 1.6))
            }
        }
    }
}
