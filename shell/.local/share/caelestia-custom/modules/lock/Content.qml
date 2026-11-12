// Lockscreen minimalis: jam, tanggal, foto profil & kolom password (kustom pengguna).
import "center"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property var lock

    readonly property real centerScale: Math.min(1, (lock.screen?.height ?? 1440) / 1440)
    readonly property int centerWidth: Tokens.sizes.lock.centerWidth * centerScale

    ColumnLayout {
        id: column

        anchors.centerIn: parent
        width: root.centerWidth
        spacing: Tokens.spacing.medium

        Clock {
            Layout.alignment: Qt.AlignHCenter
            centerScale: root.centerScale * 0.85
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.small

            text: Time.format("dddd, d MMMM")
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.title.builders.medium.weight(Font.Medium).build()
        }

        ProfilePic {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Tokens.spacing.extraLarge
            Layout.bottomMargin: Tokens.spacing.large
            centerWidth: root.centerWidth * 0.6
        }

        PasswordInput {
            Layout.alignment: Qt.AlignHCenter
            centerScale: Math.max(0.8, root.centerScale)
            centerWidth: root.centerWidth
            lock: root.lock
        }
    }

    StateMessage {
        anchors.top: column.bottom
        anchors.topMargin: Tokens.spacing.small
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width
        pam: root.lock.pam
    }
}
