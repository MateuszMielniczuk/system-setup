#!/bin/bash
# Workspace picker for herdr (Alt+W popup, config.toml): j/k move, Enter focus,
# / to search by typing, Esc/q close. Starts on the current workspace.

list() {
  herdr workspace list 2>/dev/null | jq -r '
    .result.workspaces[] |
    (.agent_status | {blocked: "!", working: "●", done: "✓", idle: "○"}[.] // "·") as $st |
    [(if .focused then "▸ " else "  " end) + "\(.number)", $st, .label, "\(.tab_count) tabs", "\u001f" + .workspace_id] | @tsv' |
    column -t -s $'\t' | sed 's/ *\x1f/\t/'
}

items=$(list)
[ -n "$items" ] || exit 0
current=$(grep -n '^▸' <<<"$items" | cut -d: -f1)

choice=$(fzf --reverse --no-sort --info=hidden --no-input --prompt "workspace > " \
  --delimiter '\t' --with-nth 1 --accept-nth 2 --header "j/k move · Enter focus · / search · Esc close" \
  --bind "load:pos(${current:-1})" \
  --bind 'j:down,k:up,q:abort' \
  --bind '/:show-input+unbind(j,k,q,/)' <<<"$items") || exit 0
herdr workspace focus "$choice" >/dev/null
