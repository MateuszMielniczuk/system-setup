hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "",
        repeat_delay = 300,
        repeat_rate  = 40,
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
        },
    },
})

-- Matches KDE: pointer acceleration 0.6, scroll factor 2.
-- Check the exact name with `hyprctl devices`.
hl.device({
    name          = "xiaomi-mi-usb-receiver-mouse",
    sensitivity   = 0.6,
    scroll_factor = 2,
})
