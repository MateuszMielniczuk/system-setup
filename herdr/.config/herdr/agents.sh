#!/bin/bash
# Agent picker for herdr (Alt+A popup, config.toml): fzf list of agents, Enter focuses one
# Columns: status, project folder, title; the pane id is hidden (last field)

list() {
  herdr agent list 2>/dev/null | jq -r --arg home "$HOME" '
    .result.agents[] |
    (.agent_status | {blocked: "! blocked", working: "● working", done: "✓ done", idle: "○ idle"}[.] // "· \(.)") as $st |
    ((.foreground_cwd // .cwd) | if . == $home then "~" else split("/")[-1] end) as $dir |
    [(if .focused then "▸" else " " end) + " " + $st, $dir, .terminal_title_stripped // .agent, .pane_id] | @tsv' |
    column -t -s $'\t'
}

choice=$(list | fzf --reverse --no-sort --info=hidden --prompt "agent > " \
  --with-nth '1..-2' --header "Enter focus · Esc close") || exit 0
herdr agent focus "${choice##* }" >/dev/null
