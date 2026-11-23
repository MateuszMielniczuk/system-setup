-- Applies the desktop theme written by ~/.config/hypr/scripts/theme.sh
local M = {}

local state = (vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")) .. "/theme/current"

-- desktop theme -> { colorscheme, background, gruvbox overrides }
local schemes = {
    ["gruvbox-dark"] = { "catppuccin-mocha", "dark", true },
    ["gruvbox-light"] = { "catppuccin-latte", "light", true },
    ["catppuccin-mocha"] = { "catppuccin-mocha", "dark" },
    ["catppuccin-latte"] = { "catppuccin-latte", "light" },
    ["tokyonight-night"] = { "tokyonight-night", "dark" },
    ["tokyonight-day"] = { "tokyonight-day", "light" },
    ["nord"] = { "nord", "dark" },
    ["rosepine-main"] = { "rose-pine-main", "dark" },
    ["rosepine-dawn"] = { "rose-pine-dawn", "light" },
    ["everforest-dark"] = { "everforest", "dark" },
    ["everforest-light"] = { "everforest", "light" },
    ["kanagawa-dragon"] = { "kanagawa-dragon", "dark" },
    ["kanagawa-lotus"] = { "kanagawa-lotus", "light" },
    ["melange-dark"] = { "melange", "dark" },
    ["melange-light"] = { "melange", "light" },
    ["gruvbox-material-dark"] = { "gruvbox-material", "dark" },
    ["gruvbox-material-light"] = { "gruvbox-material", "light" },
}

function M.current()
    local f = io.open(state)
    if not f then
        return "gruvbox-dark"
    end
    local name = f:read("*l")
    f:close()
    return schemes[name] and name or "gruvbox-dark"
end

function M.apply()
    local scheme = schemes[M.current()]
    vim.o.background = scheme[2]
    if scheme[1]:match("^catppuccin") then
        -- LazyVim applies the colorscheme before catppuccin's own config has run
        if not M.catppuccin_opts then
            require("lazy").load({ plugins = { "catppuccin" } })
        end
        local opts = vim.deepcopy(M.catppuccin_opts)
        if not scheme[3] then
            opts.color_overrides = nil
            opts.highlight_overrides = nil
        end
        require("catppuccin").setup(opts)
    end
    vim.cmd.colorscheme(scheme[1])
end

return M
