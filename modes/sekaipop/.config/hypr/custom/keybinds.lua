hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Shell (more): Edit user keybinds"} )

-- Menu ganti tampilan (Noctalia / Caelestia / end-4 / SekaiPop)
hl.bind("SUPER + F12", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/ganti-mode menu"), { description = "Ganti mode tampilan" })

-- Wallpaper acak (sama di semua mode); warna tema ikut wallpaper
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("qs -c sekaipop ipc call wallpaper random"), { description = "Wallpaper acak" })

-- Avatar VRM: tampil / sembunyi, dan sapa (lambaian)
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/sekai-avatar toggle"), { description = "Avatar: tampil / sembunyi" })
hl.bind("SUPER + ALT + SHIFT + V", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/sekai-avatar sapa"), { description = "Avatar: sapa" })
