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

hl.window_rule({
    name  = "float-dialogs",
    match = { class = "^(org.pulseaudio.pavucontrol|nm-connection-editor|blueman-manager|org.kde.polkit-kde-authentication-agent-1)$" },
    float = true,
})
