require("lint").linters_by_ft = {
    javascript = {"eslint",},
    typescript = {"eslint",},
    python = { "flake8", "mypy", },
}

vim.api.nvim_create_autocmd({
  "BufReadPost",
  "BufWritePost",
  "TextChanged",
  "InsertLeave",
}, {
  callback = function()
    require("lint").try_lint()
  end,
})
