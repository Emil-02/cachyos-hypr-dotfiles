hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- Menu ganti tampilan (Noctalia / Caelestia / end-4)
hl.bind("SUPER + F12", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/ganti-mode menu"), { description = "Ganti mode tampilan" })

-- Widget lirik & musik (ii-lyrics)
local lyr = "qs -c ii-lyrics ipc call lyrics "
hl.bind("SUPER + Y",            hl.dsp.exec_cmd(lyr .. "cycle"),        { description = "Lirik: ganti mode (desktop/mengambang/mati)" })
hl.bind("SUPER + SHIFT + Y",    hl.dsp.exec_cmd(lyr .. "karaoke"),      { description = "Lirik: mode karaoke layar penuh" })
hl.bind("SUPER + bracketleft",  hl.dsp.exec_cmd(lyr .. "shift -- -0.5"), { description = "Lirik: lebih awal 0.5 dtk" })
hl.bind("SUPER + bracketright", hl.dsp.exec_cmd(lyr .. "shift 0.5"),    { description = "Lirik: lebih lambat 0.5 dtk" })

-- Wallpaper acak dari koleksi Berkelas (sama di semua mode); warna tema ikut wallpaper
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpaper-acak"), { description = "Wallpaper acak" })
