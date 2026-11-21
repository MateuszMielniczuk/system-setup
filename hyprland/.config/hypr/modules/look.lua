local theme = require("modules.theme")

hl.env("GTK_THEME", theme.gtk)

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border   = { colors = theme.active, angle = 45 },
            inactive_border = theme.inactive,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},  {0.32, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},     {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},  {0.1, 1} } })
hl.curve("easy",         { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  spring = "easy",   style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7,    bezier = "quick" })
