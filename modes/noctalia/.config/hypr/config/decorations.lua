-- Look and feel configuration (macOS-style)
-- Border and group colours are generated from the wallpaper by Noctalia
-- into config/theme.lua (template: ~/.config/noctalia/templates/hyprland-luxury.lua).

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 14,
        border_size = 1,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = 0x40ffffff,
            inactive_border = 0x20ffffff,
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        rounding = 12,
        rounding_power = 2.5,
        dim_special = 0.3,
        dim_inactive = false,
        dim_strength = 0.06,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 32,
            render_power = 4,
            offset = { 0, 10 },
            color = 0x70000000,
            color_inactive = 0x45000000,
        },
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            noise = 0.015,
            contrast = 1.0,
            brightness = 0.85,
            vibrancy = 0.25,
            vibrancy_darkness = 0.3,
            popups = true,
            special = true,
            new_optimizations = true,
        },
    },
})

-- macOS-style: thin hairline borders, soft drop shadows, no transparency.
-- Frosted glass behind the Noctalia bar, dock, panels, notifications and OSD
hl.layer_rule({
    name = "noctalia-glass",
    match = { namespace = "^noctalia-(bar-.*|dock|panel|attached-panel|notification|osd|overview-launcher|window-switcher)$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.3,
})
