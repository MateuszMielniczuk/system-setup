-- Started from here (not ~/.config/autostart or systemd) so nothing leaks into Plasma.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    -- Password dialogs (pkexec, KDE settings); Plasma's unit restarts it if it crashes
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")
    -- Unlock KWallet with the login password: hands the session to the PAM-started wallet
    -- service (SDDM login; Plasma runs the same step). Needs wallet password = login password.
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    -- KDE daemon: its network module is NetworkManager's password agent and reads the Wi-Fi
    -- passwords Plasma saved in KWallet. No nm-applet: a second agent answered first,
    -- found nothing and asked again.
    hl.exec_cmd("kded6")
    hl.exec_cmd("kbuildsycoca6 --noincremental >/dev/null 2>&1")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle > ~/.cache/hypridle.log 2>&1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprsunset") -- night light on its schedule (hyprsunset.conf)
    hl.exec_cmd("~/.config/hypr/scripts/calendar.sh start")
    hl.exec_cmd("~/.config/hypr/scripts/theme.sh rotation start")
    hl.exec_cmd("~/.config/hypr/scripts/backup.sh auto")
    -- Waybar's first update check runs before the network is up; re-check after a minute
    hl.exec_cmd("sleep 60 && pkill -RTMIN+14 waybar")
end)
