-- Curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- macOS-like motion: quick ease-out, gentle scale on open/close, sliding Spaces.

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("mac",            { type = "bezier", points = { {0.25, 0.1},  {0.25, 1}    } })
hl.curve("macOut",         { type = "bezier", points = { {0.32, 0.72}, {0, 1}       } })

hl.curve("easy",           { type = "spring", mass = 1, stiffness = 500, dampening = 35 })
hl.curve("macSpring",      { type = "spring", mass = 1, stiffness = 320, dampening = 30 })

hl.animation({ leaf = "global",        enabled = true, speed = 4,   bezier = "mac" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5, bezier = "macOut", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.5, bezier = "mac",    style = "popin 90%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4,   spring = "macSpring", style = "slide" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "mac" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "mac" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,   bezier = "macOut", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.5, bezier = "mac",    style = "fade" })

hl.animation({ leaf = "workspaces",          enabled = true, speed = 4,   bezier = "macOut", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3.5, bezier = "macOut", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3,   bezier = "mac",    style = "slidevert" })
