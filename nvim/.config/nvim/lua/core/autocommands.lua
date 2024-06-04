-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

-- Always leave space at the bottom of the file when scrolling to bottom
vim.cmd([[
augroup ScrollOffAtEnd
  autocmd!
  autocmd CursorMoved * call ScrollOffAtEnd(0)
  autocmd TextChangedI * call ScrollOffAtEnd(1)
augroup END

function ScrollOffAtEnd(insert_mode) abort
  while winheight(0) > &scrolloff && winline() > winheight(0) - &scrolloff
    let at_end = a:insert_mode ? getcursorcharpos()[2] > len(getline('.')) : 0
    execute "normal!\<C-E>"

    " Fix position of cursor when 'wrap' occurs
    if at_end
      let cursor_pos = getcursorcharpos()
      let cursor_pos[2] = cursor_pos[2] + 1
      call setcursorcharpos(cursor_pos[1:])
    endif
  endwhile
endfunction
]])

-- resize neovim split when terminal is resized
-- vim.api.nvim_command("autocmd VimResized * wincmd =")
