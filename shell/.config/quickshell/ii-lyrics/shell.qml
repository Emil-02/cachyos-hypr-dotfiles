//@ pragma UseQApplication
// Widget lirik & musik untuk end-4 illogical-impulse.
// Mode: desktop (di atas wallpaper), mengambang (pil lirik di atas jendela),
//       karaoke (layar penuh), mati.
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris

ShellRoot {
    id: root

    // ---------- Tema (mengikuti warna wallpaper end-4) ----------
    readonly property string home: Quickshell.env("HOME")
    property var palette: ({})
    function col(key, fallback) {
        return palette && palette[key] ? palette[key] : fallback;
    }

    FileView {
        path: root.home + "/.local/state/quickshell/user/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.palette = JSON.parse(text()); } catch (e) {}
        }
    }

    // ---------- Pemutar ----------
    property MprisPlayer lastPlayer: null
    readonly property MprisPlayer player: {
        const ps = Mpris.players.values;
        const playing = ps.find(p => p.isPlaying);
        if (playing) return playing;
        if (lastPlayer && ps.includes(lastPlayer)) return lastPlayer;
        return ps[0] ?? null;
    }
    onPlayerChanged: if (player) lastPlayer = player

    readonly property bool hasTrack: !!player && (player.trackTitle ?? "") !== ""
    readonly property bool playing: !!player && player.isPlaying
    readonly property string rawTitle: player?.trackTitle ?? ""
    readonly property string rawArtist: player?.trackArtist ?? ""
    // Judul & artis bersih dari hasil pencocokan lirik (judul YouTube sering berantakan)
    readonly property var matchParts: matched.includes(" - ") ? [matched.slice(0, matched.indexOf(" - ")), matched.slice(matched.indexOf(" - ") + 3)] : null
    readonly property string title: matchParts ? matchParts[1] : rawTitle
    readonly property string artist: matchParts ? matchParts[0] : rawArtist
    readonly property string album: player?.trackAlbum ?? ""
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property real length: player?.length ?? 0
    property real pos: 0

    FrameAnimation {
        running: root.playing && root.mode !== "off"
        onTriggered: {
            root.player.positionChanged();
            root.pos = root.player.position;
        }
    }
    Timer {
        interval: 500
        running: !root.playing && root.hasTrack
        repeat: true
        onTriggered: {
            root.player.positionChanged();
            root.pos = root.player.position;
        }
    }

    // ---------- Lirik ----------
    property var lines: []
    property bool synced: true
    property string status: "idle"   // idle | loading | ok | notfound | error
    property string matched: ""
    property real offset: 0
    readonly property string trackKey: hasTrack ? `${rawArtist}\n${rawTitle}\n${Math.round(length)}` : ""
    property string requestedKey: ""

    readonly property int index: {
        const t = pos + offset + 0.2;
        const ls = lines;
        if (!ls.length || t < ls[0][0]) return -1;
        let lo = 0, hi = ls.length - 1;
        while (lo < hi) {
            const mid = (lo + hi + 1) >> 1;
            if (ls[mid][0] <= t) lo = mid; else hi = mid - 1;
        }
        return lo;
    }

    onTrackKeyChanged: {
        lines = [];
        matched = "";
        offset = 0;
        status = trackKey ? "loading" : "idle";
        debounce.restart();
    }

    Timer {
        id: debounce
        interval: 900
        onTriggered: root.fetch()
    }

    function fetch() {
        if (!trackKey) return;
        if (requestedKey !== trackKey) requestedKey = trackKey;
        fetchProc.running = false;
        fetchProc.command = ["python3", Quickshell.shellPath("fetch_lyrics.py"),
            "--artist", rawArtist, "--title", rawTitle, "--album", album,
            "--duration", String(length)];
        fetchProc.key = trackKey;
        fetchProc.running = true;
    }

    function applyResult(raw, key) {
        if (key !== trackKey) return;
        let d;
        try { d = JSON.parse(raw); } catch (e) { status = "error"; return; }
        if (d.status !== "ok") { status = d.status; lines = []; return; }
        matched = d.match ?? "";
        if (d.lines && d.lines.length) {
            let ls = d.lines;
            if (ls[0][0] > 4) ls = [[0, ""]].concat(ls);   // titik-titik intro
            synced = true;
            lines = ls;
        } else if (d.plain && d.plain.length) {
            const step = Math.max(2, (length || d.plain.length * 4) / (d.plain.length + 1));
            synced = false;
            lines = d.plain.map((l, i) => [i * step + step / 2, l]);
        } else {
            synced = true;
            lines = [[0, ""]];
        }
        status = "ok";
    }

    // Coba lagi otomatis bila server lirik sedang sibuk (maks. 6 kali per lagu)
    property int retries: 0
    onRequestedKeyChanged: retries = 0
    Timer {
        interval: 15000 + root.retries * 10000
        running: root.status === "error" && root.retries < 6
        onTriggered: { root.retries++; root.status = "loading"; root.fetch(); }
    }

    Process {
        id: fetchProc
        property string key: ""
        stdout: StdioCollector {
            onStreamFinished: root.applyResult(this.text, fetchProc.key)
        }
    }

    // ---------- Visualizer (cava) ----------
    property var bars: []
    readonly property real bass: {
        const b = bars;
        if (!b.length) return 0;
        let s = 0;
        for (let i = 0; i < Math.min(6, b.length); i++) s += b[i];
        return Math.min(1, s / Math.min(6, b.length));
    }

    Process {
        running: root.playing && root.mode !== "off" && (root.mode !== "desktop" || root.desktopVisible)
        command: ["cava", "-p", root.home + "/.config/quickshell/ii/scripts/cava/raw_output_config.txt"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(";");
                const out = [];
                for (let i = 0; i < parts.length; i++)
                    if (parts[i] !== "") out.push(Math.min(1, parseInt(parts[i]) / 1000));
                root.bars = out;
            }
        }
        onRunningChanged: if (!running) root.bars = []
    }

    // ---------- Mode tampilan ----------
    property string mode: "desktop"
    property string modeBeforeKaraoke: "desktop"
    readonly property var modeLabels: ({ desktop: "Desktop", float: "Mengambang", karaoke: "Karaoke", off: "Mati" })
    readonly property bool desktopVisible: mode === "desktop" && hasTrack

    FileView {
        id: stateFile
        path: root.home + "/.local/state/ii-lyrics.json"
        onLoaded: {
            try {
                const s = JSON.parse(text());
                if (s.mode && s.mode !== "karaoke") root.mode = s.mode;
            } catch (e) {}
        }
    }
    function setMode(m) {
        if (m === "karaoke" && mode !== "karaoke") modeBeforeKaraoke = mode;
        mode = m;
        if (m !== "karaoke") stateFile.setText(JSON.stringify({ mode: m }));
        Quickshell.execDetached(["notify-send", "-a", "Lirik", "-t", "1500", "-i", "audio-x-generic",
            "Mode lirik: " + modeLabels[m]]);
    }

    IpcHandler {
        target: "lyrics"

        function cycle(): void {
            const order = ["desktop", "float", "off"];
            const cur = root.mode === "karaoke" ? root.modeBeforeKaraoke : root.mode;
            root.setMode(order[(order.indexOf(cur) + 1) % order.length]);
        }
        function karaoke(): void {
            root.setMode(root.mode === "karaoke" ? root.modeBeforeKaraoke : "karaoke");
        }
        function setMode(m: string): void {
            if (root.modeLabels[m]) root.setMode(m);
        }
        function shift(delta: real): void {
            root.offset = Math.round((root.offset + delta) * 10) / 10;
            Quickshell.execDetached(["notify-send", "-a", "Lirik", "-t", "1200", "-i", "audio-x-generic",
                "Sinkron lirik: " + (root.offset > 0 ? "+" : "") + root.offset.toFixed(1) + " dtk"]);
        }
        function refetch(): void {
            root.status = "loading";
            root.fetch();
        }
        function status(): string {
            return `${root.mode} | ${root.status} | ${root.matched} | idx ${root.index}/${root.lines.length} | pos ${root.pos.toFixed(1)} | offset ${root.offset}`;
        }
    }

    // ---------- Jaga widget tetap di atas wallpaper end-4 ----------
    // Wallpaper end-4 berada di lapisan yang sama; saat ia dibuat ulang, widget dipetakan ulang.
    property bool remapping: false
    Timer {
        id: remapTimer
        interval: 400
        onTriggered: { root.remapping = true; remapBack.restart(); }
    }
    Timer {
        id: remapBack
        interval: 60
        onTriggered: root.remapping = false
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "openlayer" && event.data.startsWith("quickshell:background"))
                remapTimer.restart();
        }
    }

    // ---------- Jendela: Desktop ----------
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: deskWin
            required property var modelData
            screen: modelData
            visible: root.mode === "desktop" && !root.remapping
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "ii-lyrics"
            anchors { left: true; right: true; bottom: true }
            implicitHeight: 460
            mask: Region { item: root.desktopVisible ? deskCard : null }

            Item {
                anchors.fill: parent
                opacity: root.desktopVisible ? (root.playing ? 1 : 0.6) : 0
                scale: root.desktopVisible ? 1 : 0.96
                Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }

                LyricsView {
                    id: deskLyrics
                    core: root
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: deskCard.top
                    anchors.bottomMargin: 26
                    width: Math.min(parent.width - 120, 980)
                    height: 270
                    currentSize: 34
                    otherSize: 20
                    visible: root.status === "ok"
                }

                StatusLine {
                    core: root
                    anchors.centerIn: deskLyrics
                }

                Visualizer {
                    core: root
                    anchors.horizontalCenter: deskCard.horizontalCenter
                    anchors.bottom: deskCard.verticalCenter
                    width: deskCard.width + 140
                    height: 64
                    barWidth: 4
                    gap: 4
                    maxOpacity: 0.6
                }

                NowPlaying {
                    id: deskCard
                    core: root
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 46
                    width: 540
                    height: 84
                }
            }
        }
    }

    // ---------- Jendela: Mengambang (di atas semua jendela, tembus klik) ----------
    LazyLoader {
        active: root.mode === "float" && root.hasTrack

        PanelWindow {
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "ii-lyrics-float"
            anchors { bottom: true }
            margins { bottom: 16 }
            implicitWidth: 660
            implicitHeight: 62
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.alpha(root.col("surface_container", "#1e1f25"), 0.88)
                border.width: 1
                border.color: Qt.alpha(root.col("outline_variant", "#44474e"), 0.7)
                opacity: root.playing ? 1 : 0.55
                Behavior on opacity { NumberAnimation { duration: 500 } }

                Visualizer {
                    core: root
                    anchors.fill: parent
                    anchors.margins: 6
                    barWidth: 3
                    gap: 5
                    maxOpacity: 0.22
                    mirrorVertical: true
                }

                NowPlayingDisc {
                    id: floatDisc
                    core: root
                    anchors.left: parent.left
                    anchors.leftMargin: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 18
                    height: width
                }

                LyricsView {
                    core: root
                    anchors.left: floatDisc.right
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    currentSize: 19
                    otherSize: 19
                    lineHeight: parent.height
                    onlyCurrent: true
                    visible: root.status === "ok"
                }

                StatusLine {
                    core: root
                    small: true
                    anchors.left: floatDisc.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // ---------- Jendela: Karaoke (layar penuh) ----------
    LazyLoader {
        active: root.mode === "karaoke"

        PanelWindow {
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "ii-lyrics-karaoke"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { left: true; right: true; top: true; bottom: true }

            Item {
                id: kRoot
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: root.setMode(root.modeBeforeKaraoke)
                Keys.onSpacePressed: root.player?.togglePlaying()
                Keys.onRightPressed: root.player?.next()
                Keys.onLeftPressed: root.player?.previous()

                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

                Rectangle { anchors.fill: parent; color: root.col("surface_container_lowest", "#0e0e11") }

                Image {
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    opacity: status === Image.Ready ? 0.55 : 0
                    scale: 1.15 + root.bass * 0.04
                    Behavior on opacity { NumberAnimation { duration: 900 } }
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1.0
                        blurMax: 64
                        saturation: 0.3
                        brightness: -0.35
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.alpha(root.col("surface_container_lowest", "#0e0e11"), 0.35) }
                        GradientStop { position: 1.0; color: Qt.alpha(root.col("surface_container_lowest", "#0e0e11"), 0.85) }
                    }
                }

                Visualizer {
                    core: root
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 150
                    barWidth: 6
                    gap: 6
                    maxOpacity: 0.45
                }

                LyricsView {
                    core: root
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -20
                    width: Math.min(parent.width - 160, 1100)
                    height: parent.height * 0.62
                    currentSize: 50
                    otherSize: 26
                    visible: root.status === "ok"
                }

                StatusLine {
                    core: root
                    anchors.centerIn: parent
                }

                NowPlaying {
                    core: root
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 40
                    width: 560
                    height: 84
                }

                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 24
                    text: "Esc untuk keluar  ·  Spasi putar/jeda  ·  ← → lagu"
                    color: Qt.alpha(root.col("on_surface", "#e3e2e6"), 0.45)
                    font.family: "Google Sans Flex"
                    font.pixelSize: 12
                }
            }
        }
    }
}
