-- Your own changes. Loaded after the defaults in hyprland/execs.lua; never overwritten.

-- Avatar VRM di desktop (hanya mode SekaiPop; ganti-mode mematikannya di mode lain)
hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 4 && " .. os.getenv("HOME") .. "/.local/bin/sekai-avatar start")
end)
