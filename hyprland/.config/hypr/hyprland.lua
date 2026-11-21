local dir = os.getenv("HOME") .. "/.config/hypr/"
package.path = dir .. "?.lua;" .. package.path

require("modules.env")
require("modules.monitors")
require("modules.look")
require("modules.input")
require("modules.workspaces")
require("modules.keybinds")
require("modules.rules")
require("modules.autostart")
