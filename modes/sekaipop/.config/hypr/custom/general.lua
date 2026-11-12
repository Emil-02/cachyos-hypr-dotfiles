-- Your own changes. Loaded after the defaults in hyprland/general.lua; never overwritten.

-- Mouse sama seperti mode lain
hl.config({ input = { accel_profile = "flat" } })

-- Border jendela aktif: gradasi warna tema yang berputar pelan (warna ditulis SekaiPop di sekaipop_overrides.lua)
hl.curve("linear", { type = "bezier", points = {{0, 0}, {1, 1}} })
hl.animation({ leaf = "borderangle", enabled = true, speed = 80, bezier = "linear", style = "loop" })

-- Blur lebih tebal untuk jendela transparan (kitty) agar terlihat seperti kaca buram
hl.config({ decoration = { blur = { size = 6, passes = 3 } } })
