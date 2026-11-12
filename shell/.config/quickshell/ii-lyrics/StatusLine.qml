import QtQuick

// Pesan status saat lirik belum tersedia.
Item {
    id: st

    required property var core
    property bool small: false
    readonly property bool show: core.hasTrack && core.status !== "ok"

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    opacity: show ? 1 : 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 400 } }

    Text {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, st.width > 0 ? st.width : implicitWidth)
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        text: st.core.status === "loading" ? "♪  Mencari lirik…"
            : st.core.status === "notfound" ? "♪  Lirik tidak ditemukan"
            : st.core.status === "error" ? "♪  Lirik belum bisa diambil, mencoba lagi…"
            : ""
        color: Qt.alpha(st.core.col("on_surface", "#e3e2e6"), 0.7)
        font.family: "Google Sans Flex"
        font.pixelSize: st.small ? 15 : 22
        font.weight: 500

        SequentialAnimation on opacity {
            running: st.core.status === "loading"
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 700; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
        }
    }
}
