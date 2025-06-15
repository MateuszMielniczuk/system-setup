local M = {}

local kyria_layout = {
    "  Base Layer: Dvorak",
    " .-------------------------------------------                               -------------------------------------------.",
    " |  Tab   | ''   | , <  | . >  |   P  |   Y  |                              |   F  |   G  |   C  |   R  |   L  |  Bksp  |",
    " |--------+------+------+------+------+------|                              |------+------+------+------+------+--------|",
    " |Ctrl/Esc|   A  |   O  |   E  |   U  |   I  |                              |   D  |   H  |   T  |   N  |   S  |Ctrl/- _|",
    " |--------+------+------+------+------+------+-------------.  ,-------------+------+------+------+------+------+--------|",
    " | LShift |  ; : |   Q  |   J  |   K  |   X  | [ {  |CapsLk|  |F-keys|  ] } |   B  |   M  |  W   |   V  |   Z  | RShift |",
    " `----------------------+------+------+------+------+------|  |------+------+------+------+------+----------------------'",
    "                        (Adjust) LGUI | LAlt | Space| Nav  |  | Sym  | Enter| AltGr| RGUI ( Menu )",
    "                        `----------------------------------'  `----------------------------------'",
    " ",
    "Nav Layer: Media, navigation",
    " ,-------------------------------------------.                              ,-------------------------------------------.",
    " |        |M Prev|M Play|M Next|VolMut| BRI+ |                              |BrwsrS| PgUp | Home |  End | PgUP | Delete |",
    " |--------+------+------+------+------+------|                              |------+------+------+------+------+--------|",
    " |        |  GUI |  Alt | Ctrl | Shift| BRI- |                              |BrwsrF|  ←   |   ↓  |  ↑   |  →   | Insert |",
    " |--------+------+------+------+------+------+-------------.  ,-------------+------+------+------+------+------+--------|",
    " |        | Calc |      |MouseW|MouseL|MouseR|Mouse4|Mouse5|  |      |      |BrwsrB|MouseL|MouseD|MouseU|MouseR|  PrtSc |",
    " `----------------------+------+------+------+------+------|  |------+------+------+------+------+----------------------'",
    "                        (      )      |      |      | [Nav]|  |      |      |      |      (      )",
    "                        `----------------------------------'  `----------------------------------'",
    " ",
    "Sym Layer: Numbers, symbols",
    " ,-------------------------------------------.                              ,-------------------------------------------.",
    " |    `   |  !   |  @   |  #   |  $   |  %   |                              |   ^  |  &   |  *   |  (   |  )   |        |",
    " |--------+------+------+------+------+------|                              |------+------+------+------+------+--------|",
    " |    ~   |  1   |  2   |  3   |  4   |  5   |                              |   6  |  7   |  8   |  9   |  0   |   _    |",
    " |--------+------+------+------+------+------+-------------.  ,-------------+------+------+------+------+------+--------|",
    " |        |  ?   |   |  |  |   |  [   |  {   |   (  |      |  |      |  )   |   }  |  ]   |   /  |   =  |  -   |   +    |",
    " `----------------------+------+------+------+------+------|  |------+------+------+------+------+----------------------'",
    "                        (      )      |      |      |      |  | [Sym]|      |      |      (      )",
    "                        `----------------------------------'  `----------------------------------'",
    " ",
    "Adjust Layer: Default layer settings, RGB",
    " ,-------------------------------------------.                              ,-------------------------------------------.",
    " |        |BL_TOG|      |QWERTY| HSNT |      |                              | PLAIN|BREATH|RAINBW| SWIRL| SNAKE|KNGHTRID|",
    " |--------+------+------+------+------+------|                              |------+------+------+------+------+--------|",
    " |        |BLBRTH| BL+  |Dvorak|      |      |                              | TOG  | SAI  | HUI  | VAI  | MOD  |  XMAS  |",
    " |--------+------+------+------+------+------+-------------.  ,-------------+------+------+------+------+------+--------|",
    " |        |BL_CYC| BL-  |Colmak|      |      |      |      |  |      |      | TEST | SAD  | HUD  | VAD  | RMOD |GRADIENT|",
    " `----------------------+------+------+------+------+------|  |------+------+------+------+------+----------------------'",
    "                        ( [Adj])      |      |      |      |  |      |      |      |      (      )",
    "                        `----------------------------------'  `----------------------------------'",
}

function M.show_kyria()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, kyria_layout)

    local width = 0
    for _, line in ipairs(kyria_layout) do
        width = math.max(width, #line)
    end
    local height = #kyria_layout

    local opts = {
        style = "minimal",
        relative = "editor",
        width = width + 2,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = "single",
    }
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Map 'q' to close the window and buffer
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
    })

    -- Optionally, allow closing with <Esc> as well
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
    })
end

return M
