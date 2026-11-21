hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Keep the screen awake (pauses hypridle) without the manual toggle
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name  = "idle-inhibit-video",
    match = { class = "^(mpv|vlc|io.github.celluloid_player.Celluloid|org.gnome.Totem)$" },
    idle_inhibit = "focus",
})

hl.window_rule({
    name  = "idle-inhibit-youtube",
    match = { title = ".*YouTube.*" },
    idle_inhibit = "focus",
})

hl.window_rule({
    name  = "float-dialogs",
    match = { class = "^(org.pulseaudio.pavucontrol|nm-connection-editor|nmtui|blueman-manager|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})

hl.window_rule({
    name      = "dropterm",
    match     = { class = "^dropterm$" },
    float     = true,
    size      = "monitor_w*0.7 monitor_h*0.6",
    center    = true,
    workspace = "special:term",
})

hl.window_rule({
    name  = "satty",
    match  = { class = "^(com.gabm.satty|satty)$" },
    float  = true,
    size   = "monitor_w*0.85 monitor_h*0.85",
    center = true,
})

hl.layer_rule({
    name  = "blur-panels",
    match = { namespace = "^(waybar|launcher|notifications)$" },
    blur  = true,
    ignore_alpha = 0.2,
})
