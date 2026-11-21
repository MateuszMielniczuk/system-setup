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

-- Picture-in-picture: small, pinned (all desktops), bottom-right of its monitor
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture[- ]in[- ][Pp]icture)$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    size  = "monitor_w*0.25 monitor_h*0.25",
    move  = "monitor_w*0.73 monitor_h*0.72",
})

-- File dialogs and modal windows: float, centered, sized to the monitor
hl.window_rule({
    name   = "file-dialogs",
    match  = { title = "^(Open File|Open Files|Open Folder|Save As|Save File|Select a File|Select Folder|Choose Files|File Upload).*" },
    float  = true,
    center = true,
    size   = "monitor_w*0.6 monitor_h*0.65",
})

hl.window_rule({
    name   = "portal-dialogs",
    match  = { class = "^(xdg-desktop-portal-gtk|org.freedesktop.impl.portal.desktop.kde)$" },
    float  = true,
    center = true,
    size   = "monitor_w*0.6 monitor_h*0.65",
})

hl.window_rule({
    name   = "modal",
    match  = { modal = true },
    float  = true,
    center = true,
})

-- Password prompts: dim everything behind them
hl.window_rule({
    name   = "auth-prompts",
    match  = { class = "^(org.kde.polkit-kde-authentication-agent-1|gcr-prompter|polkit-gnome-authentication-agent-1)$" },
    float  = true,
    center = true,
    dim_around = true,
})

-- Browser "… is sharing your screen" bar: keep it pinned at the bottom center
hl.window_rule({
    name  = "screenshare-bar",
    match = { title = ".*is sharing (a window|your screen).*" },
    float = true,
    pin   = true,
    move  = "(monitor_w*0.5-window_w*0.5) (monitor_h-window_h-12)",
})

-- KDE settings modules and small Plasma tools opened from Hyprland
hl.window_rule({
    name   = "kde-dialogs",
    match  = { class = "^(kcm_.*|.*plasmawindowed.*|.*bluedevilwizard|org.kde.kdialog)$" },
    float  = true,
    center = true,
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
