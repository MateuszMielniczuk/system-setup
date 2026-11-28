# herdr

Terminal multiplexer for coding agents (herdr 0.9.5, `~/.local/bin/herdr`).
Model: **workspace** (sidebar) → **tab** (top bar) → **pane** (terminal or agent).
A persistent server keeps sessions; clients attach.

Config: `herdr/.config/herdr/config.toml` (stow package; runtime files next to it are gitignored).

```bash
herdr config check            # validate
herdr server reload-config    # apply (or Ctrl+B, Shift+R inside herdr)
herdr config reset-keys       # backs up the config, drops custom keys
herdr --skill                 # agent skill for controlling herdr from the CLI
```

Full commented defaults are embedded in the binary:
`strings -n 3 ~/.local/bin/herdr | grep -n -A80 '^\[keys\]'`.
Docs: <https://herdr.dev/llms.txt>, <https://herdr.dev/llms-full.txt>.

## Keys

Each program has its own modifier: **Super** = Hyprland, **Ctrl+Shift** = Kitty, **Alt** = herdr.

| Keys | Action |
|---|---|
| Alt+1..9 | go to tab N |
| Ctrl+Alt+1..9 | go to workspace N |
| Alt+H / Alt+L | previous / next tab |
| Alt+Shift+H / L | move tab left / right |
| Ctrl+Alt+H/J/K/L | focus pane left / down / up / right |
| Alt+N | new tab |
| Alt+V / Alt+Minus | split vertical / horizontal |
| Alt+Z | zoom pane |
| Alt+X | close pane |
| Alt+A | agent picker popup (`agents.sh`): pick from a list, Enter jumps there |
| Alt+G | go to: search agents and terminals |
| Alt+Shift+A | next agent |
| Alt+O | focus the agent of the currently visible herdr toast (no toast, no action) |
| Alt+W | workspace picker popup (`workspaces.sh`): j/k move, Enter jumps, `/` search (built-in picker: Ctrl+B w) |
| Alt+B | toggle sidebar |

Everything else stays on the Ctrl+B prefix: `?` help, `s` settings, `q` detach,
`Shift+R` reload, `Shift+N` new workspace, `Shift+W` rename workspace, `Shift+D` close
workspace, `Shift+T` rename tab, `Shift+X` close tab, `Shift+P` rename pane, `e` edit
scrollback, `r` resize mode, `Shift+G` new worktree.

Avoided on purpose: Alt+J/K (LazyVim move line), Alt+T / Alt+P (Claude Code thinking /
model picker). Plain printable keys must never be direct bindings (they eat typing).

## Binding syntax

- `"prefix+x"`: press the prefix, release, then x. `"ctrl+alt+x"`: direct, no prefix.
- Modifiers ctrl/shift/alt/cmd/super; special keys enter/tab/esc/arrows/f1..;
  named punctuation minus, comma, ampersand, plus, backtick.
- Indexed: `"alt+1..9"`. Empty string unbinds.
- Most reliable direct chords: ctrl+letter, function keys, ctrl+alt+…. Shells receive
  Ctrl+Shift+letter as plain Ctrl+letter, so those can't be told apart without the
  kitty keyboard protocol.
- Custom commands: `[[keys.command]]` with `key`, `type` (popup / pane / shell),
  `command`, optional `width`/`height`.

## Kitty and Hyprland

- Kitty handles keys before herdr. Its Alt+1..9 and Ctrl+Alt+H/L tab maps use
  `map --when-focus-on "not title:^herdr"`, so in herdr windows they reach herdr.
  This depends on `window_title = "herdr: {workspace}"`.
- Shift+Enter: inside herdr `TERM_PROGRAM=herdr`, Claude Code doesn't enable the kitty
  keyboard protocol and Shift+Enter arrives as Enter. Kitty sends Alt+Enter (newline)
  instead in herdr windows: `map --when-focus-on "title:^herdr" shift+enter send_text all \x1b\r`.
- Hyprland binds nothing on Alt or Ctrl+Alt (lock is Super+Escape only).
- Notifications use `[ui.toast] delivery = "herdr"` (in-app toast, needed for Alt+O). They do not go
  through mako; `"system"` would, but then Alt+O has no target.
