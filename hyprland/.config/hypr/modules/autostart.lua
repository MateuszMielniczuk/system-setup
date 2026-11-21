-- Started from here (not ~/.config/autostart or systemd) so nothing leaks into Plasma.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
end)
