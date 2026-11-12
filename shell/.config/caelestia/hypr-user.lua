-- Tambahan pribadi untuk mode Caelestia (tidak ditimpa saat update)
local wp = os.getenv("HOME") .. "/Gambar/Wallpaper/Berkelas"

-- Siapkan overlay shell kustom (lockscreen minimalis) sebelum Caelestia dijalankan
os.execute(os.getenv("HOME") .. "/.local/bin/caelestia-overlay")

-- Ganti mode tampilan (Caelestia <-> Noctalia)
hl.bind("SUPER + F12", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/ganti-mode menu"))

-- Wallpaper (shortcut sama seperti mode Noctalia)
local cycle = os.getenv("HOME") .. "/.local/bin/caelestia-wallpaper-cycle"
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(cycle .. " next " .. wp))
hl.bind("SUPER + ALT + SHIFT + W", hl.dsp.exec_cmd(cycle .. " prev " .. wp))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("caelestia wallpaper -r " .. wp))

-- Akselerasi mouse sama seperti mode Noctalia
hl.config({ input = { accel_profile = "flat" } })

-- Skala layar sama seperti mode Noctalia
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
