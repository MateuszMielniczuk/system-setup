hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- KDE apps (Dolphin "Open with", app lists) need Plasma's menu file outside Plasma.
-- Hyprland session only; not exported to systemd, so Plasma is unaffected.
hl.env("XDG_MENU_PREFIX", "plasma-")
