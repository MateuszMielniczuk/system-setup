return {
    -- change Copilot chat plu
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
            { "zbirenbaum/copilot.lua" },
            { "nvim-lua/plenary.nvim" },
        },
        opts = {
            model = "claude-sonnet-4.5",

            -- Enable file completion with hidden files
            context = nil,

            -- Override completion to show hidden files
            completion = {
                file = {
                    hidden = true,
                },
            },
            headers = {
                user = '👤 MMi',
                assistant = '🤖 Copilot',
                tool = '🔧 Tool',
            },
        },
    },
}
