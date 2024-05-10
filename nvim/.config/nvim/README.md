        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    My  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  config :)
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

# Requirements:

- Python and PIP installed
- latest NODEjs and NPM available (installed by apt not snap!)
- install ripgrep
- install fd-find (optional)

Run command `:checkhealth` to see all errors within nvim installation

# Customized key maps used in this configuration

## Basic navigation

`ctrl`+`h` - move cursor to left window\
`ctrl`+`l` - move cursor to right window\
`ctrl`+`k` - move cursor to top window\
`ctrl`+`j` - move cursor to bottom window

`tab` - move to next opened buffer\
`shift`+`tab` - move to previous opened buffer

`alt`+`j` - move cursor line down\
`alt`+`k` - move cursor line up

`ctrl` + `j` or `ctrl` + `x` - decrement number
`ctrl` + `k` or `ctrl` + `a`- increment number

`j` `k` or `k` `j` - exit insert mode (faster than pressing `esc`)

`g` `c` - code comment (with comment library)

## Leader key actions

Leader key - `space`

### quick actions

`space` - find recently opened buffers\
`?` - find recently opened files\
`/` - current buffer fuzzy find\
`D` - type definition, open file with definition (lsp)\
`k` - close current buffer\
`m` - open mason lsp, linter, formatter manager\
`p` - open package manager\
`r` - rename variable (lsp)
`e` - open file explorer\
`q` - quit neovim\
`w` - write changes to the current buffer

### AI tools

`a` `a` - use to autocomplete started code (like copilot)\
`a` `c` - open chatgpt prompt\
`a` `d` - add docstring to class or function\
`a` `e` - explain peace of code\
`a` `f` - fix bugs in code\
`a` `m` - modify code with given instructions\
`a` `o` - optimize selected code\
`a` `p` - pretend to be select options (eg. js console, linux terminal)\
`a` `t` - generate tests for code

### code actions

`c` `a` - code action (change var into function, add missing import, etc)\
`c` `l` - code run linter now\
`c` `f` - code format with formatter

### diagnostics and errors

`d` `j` - go to next diagnostic\
`d` `k` - go to previous diagnostic

`d` `l` - open diagnostic list

### hoover

`h` `d` - hover floating diagnostic window\
`h` `h` - hover git hunk
`h` `i` - hoover element documentation\
`h` `s` - hover signature documentation

### go to

`g` `d` - go to code definition (lsp)\
`g` `D` - go to declaration (lsp)\
`g` `i` - go to implementation (lsp)
`g` `p` - go to previous hunk(git)\
`g` `n` - go to next hunk(git)

### search

`s` `c` - search colorscheme\
`s` `d` - search diagnostics (errors)\
`s` `f` - search files\
`s` `g` - search grep, search all occurrences in all files\
`s` `h` - search help in nvim libraries api\
`s` `i` - search/show all method implementations in telescope\
`s` `k` - search key map\
`s` `m` - search available man pages\
`s` `r` - show all references with telescope (lsp)\
`s` `u` - search keymaps resume\
`s` `s` - show all class, functions, variables definitions with telescope (lsp)\
`s` `w` - search string(word) by grep in current directory

### tab navigation

`t` `o` - open new tab
`t` `x` - close current tab
`t` `n` - go to next tab
`t` `p` - go to previous tab
`t` `f` - open current buffer in new tab

## Autocompletion with lsp (internal)

`ctrl`+`space` - show more completion options\
`ctrl`+`j` - select next item\
`ctrl`+`k` - select previous item\
`ctrl`+`u` - scroll docs up\
`ctrl`+`d` - scroll docs down\
`tab` - select next item\
`shift`+`tab` - select previous item\
`enter` - accept no newline\
`ctrl` + `c` - close completion window

## Chatgpt (internal)

### chat window

`ctrl` + `c` - close window\
`tab` - toggle windows\
`ctrl` + `y` - yank last answer\
`ctrl` + `p` - yank code from last answer\
`ctrl` + `k` - scroll window up\
`ctrl` + `j` - scroll window down\
`ctrl` + `n` - open new chat session\
`ctrl` + `f` - cycle over modes (center, stick to right)\
`space` - select session\
`r` - rename session\
`d` - delete session\
`ctrl` + `d` - draft message (create message without submitting it to server)\
`ctrl` + `o` - toggle settings window\
`ctrl` + `r` - switch role (switch between user and assistant role to define a workflow)\
`ctrl` + `s` - toggle system message window\
`ctrl` + `x` - stop generating message from gpt

### edit with instructions

`ctrl` + `c` - close window\
`ctrl` + `y` - accept\
`ctrl` + `d` - toggle diff\
`ctrl` + `o` - toggle settings\
`ctrl` + `i` - use output as input\
`tab` - toggle windows

## Copilot (internal)

`alt` + `l` - accept generated code\
`alt` + `]` - next suggestion\
`alt` + `[` - previous suggestion\
`ctrl` + `]` - dismiss suggestion

## Treesitter (internal)

`ctrl` + `space` - select code incrementally how it is nested in normal mode
`backspace` - unselect incrementally above action

Additionally text objects addon is providing additional functionality to jump,
move, yank, delete: functions, classes, loops etc.

Additional text objects:

- `=` assignments
- `a` parameter/argument
- `c` class
- `f` functions definition
- `F` function call
- `i` if statement/conditional
- `m` method

Additional select methods beside `a`round and `i`nner:

- `l` left
- `right` right

Examples:

- delete left side of assignment: `d` `l` `=`
- yank all inside class: `y` `i` `c`
- delete all if statement and insert mode: `c` `i` `i`

There are also jump actions to additional text objects with `[` previous `]` next.
Examples:

- go to next class: `]` `c`
- go to previous function `[` `f`

Additionally to enhance all above functionalities it is possible to repeat
actions forward with `;` and backward with `,`.

## Telescope (internal)

### Keys for insert mode

`ctrl`+`u` - previous history element\
`ctrl`+`d` - next history element\
`ctrl`+`j` - go to next element\
`ctrl`+`k` - go to previous element\
`page up` - results scrolling up\
`page down` - result scrolling down

`ctrl`+`/` - show which key info panel with available key maps

### Keys for normal mode

`esc` - exit\
`j` or `down` - next selection\
`k` or `up` - previous selection\
`g` `g` - go to top\
`G` - go to bottom\
`ctrl`+`k` or `page up` - scroll up\
`ctrl`+`j` or `page down` - scroll down

`?` - open which key with available keys

## Useful vim default keybindings

`ctrl` `a` - increment number\
`ctrl` `x` - decrement number\
`:!` - run terminal command\
`.` - repeate last command\
`$` - move to the end of the line\
`0` - move to the line start\
`:` `number` - go to line number after pressing enter\
`shift` + `5` or `%` - move between bracket start end\
`:Ex` - jump to file tree\
`za` - fold functions or classes

Search:\
`/` - press to start search

- `n` - press to find next match
- `shift` + `n` - press to find previous match

`*` - find next word highlighted by cursor\
`#` - find previous word hilighted by cursor

## Vim text objects actions keybindings

`<command><inner/around><textobject>`

It is possible to apply below commands efficiently to text objects:

- `v` select
- `c` delete add go to insert mode
- `d` delete
- `y` copy/yank

Any combination of above letters with key (i)inner or a(around) will add action
help apply action to text objects.

Text objects:

- `p` paragraph
- `s` sentence
- `t` markup title
- `w` word
- `W` word including signs
- any type of parenthesis `(` `{` `[` `<` or quotes `"` `'`

This can be extended with Treesitter, and addon for text objects.

## Other useful vim actions

Find and replace:\
`:[range]s/{pattern}/{string}/[flags] [count]`

- to replace only current line:\
  `:s/to_replace/replace`

- to replace all occurrences in one line:\
  `:s/to_replace/replace/g`

- to replace all occurrences in a file use `%` sign as range:\
  `:%s/to_replace/replace/g`
