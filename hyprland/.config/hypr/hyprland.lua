local dir = os.getenv("HOME") .. "/.config/hypr/"
package.path = dir .. "?.lua;" .. package.path

-- Re-run modules on every reload, in case the Lua state survives it
for name in pairs(package.loaded) do
    if name:match("^modules%.") then
        package.loaded[name] = nil
    end
end

require("modules.env")
require("modules.monitors")
require("modules.look")
require("modules.input")
require("modules.workspaces")
require("modules.keybinds")
require("modules.rules")
require("modules.autostart")
