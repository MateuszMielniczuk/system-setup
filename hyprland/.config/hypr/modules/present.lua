-- Presentation mode follows screen sharing (portal screencasts: Meet, Teams, Discord, OBS)
local function active(state)
    if type(state) == "table" then
        state = state.active or state.state or state[1]
    end
    return state == true or state == 1 or state == "1" or state == "true"
end

hl.on("screenshare.state", function(state)
    hl.exec_cmd("~/.config/hypr/scripts/present.sh auto " .. (active(state) and "on" or "off"))
end)
