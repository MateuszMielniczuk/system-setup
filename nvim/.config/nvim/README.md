# Key maps used in configuration

[ctrl] + [h] - move cursor to left window
[ctrl] + [l] - move cursor to right window
[ctrl] + [k] - move cursor to top window
[ctrl] + [j] - move cursor to bottom window

[tab] - move to next opened buffer
[shift]+[tab] - move to previous opened buffer

[alt]+[j] - move current line down
[alt]+[k] - move current line up

[j][k] or [k][j] - exit insert mode

[g][d] - go to code definition (lsp)
[g][D] - go to declaration (lsp)
[g][r] - go to reference with telescope (lsp)
[g][I] - go to implementation (lsp)

[K] - hoover element documentation
[ctrl]+[k] - hover signature documentation

#todo !!!!!! Add diagnostic messages from key maps !!!!!!!!!!!

-- leader actions ------------------------------------------------------------
------------------------------------------------------------------------------
 
Leader key - [space]
 
[ ] - find recently opened buffers
[?] - find recently opened files
[/] - current buffer fuzzy find
[D] - type definition, open file with definition (lsp)
[k] - close current buffer
[m] - open mason lsp, linter, formatter manager
[p] - open package manager
[r] - reformat code
[t] - open file explorer
[q] - quit neovim
[w] - write changes to the current buffer

[c]+[a] - code action (change var into function etc)
[c]+[f] - code format with formatter

[d]+[[] - go to next error
[d]+[]] - go to previous error
[d]+[d] - show all errors with telescope
[d]+[o] - show floating error
[d]+[s] - show all class, functions, variables definitions with telescope (lsp)

[g]+[f] - search git files
[g]+[p] - go to previous hunk
[g]+[n] - go to next hunk


[s]+[c] - search color scheme
[s]+[d] - search diagnostics (errors)
[s]+[f] - search files
[s]+[g] - search grep, search all occurrences in all files
[s]+[h] - search help nvim tags
[s]+[k] - search key map
[s]+[m] - search available manual pages
[s]+[r] - search resume???
[s]+[w] - search word - don't understand use case

[p]+[h] - preview hunk

[r]+[n] - rename variable (lsp)

[w]+[a] - add folder to workspace
[w]+[l] - list workspace folders
[w]+[s] - show all workspace symbols with telescope (lsp)
[w]+[r] - remove workspace folder

-- autocompletion ------------------------------------------------------------
------------------------------------------------------------------------------

[ctrl]+[ ] - show more completion options
[ctrl]+[j] - select next item
[ctrl]+[k] - select previous item
[ctrl]+[u] - scroll docs up
[ctrl]+[d] - scroll docs down
[tab] - select next item
[shift]+[tab] - select previous item

-- telescope -----------------------------------------------------------------
------------------------------------------------------------------------------

### Keys for insert mode
[ctrl]+[u] - previous history element
[ctrl]+[d] - next history element
[ctrl]+[j] - go to next element
[ctrl]+[k] - go to previous element
[page up] - results scrolling up
[page down] - result scrolling down

[ctrl]+[/] - show which key info panel with available key maps

### Keys for normal mode
[esc] - exit
[j] or [down] - next selection
[k] or [up] - previous selection
[gg] - go to top
[G] - go to bottom
[ctrl]+[j] or [page down] - scroll down
[ctrl]+[k] or [page up] - scroll up

[?] - open which key with available keys
