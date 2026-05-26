#!/usr/bin/env nu

# Find emacs window
let windows = niri msg -j windows | from json
let emacs_win = $windows | where app_id == "emacs" or app_id == "Emacs" or app_id == "emacsclient"

if ($emacs_win | is-empty) {
    niri msg action spawn -- emacsclient -c -a 'emacs'
    exit 0
}

let win = $emacs_win | first
let workspaces = niri msg -j workspaces | from json
let current_ws = $workspaces | where is_focused == true | first

# Move to current workspace if needed
if $win.workspace_id != $current_ws.idx {
    niri msg action move-window-to-workspace --window-id ($win.id | into string) ($current_ws.idx | into string)
}

# Un-float if floating
if $win.is_floating {
    niri msg action toggle-window-floating --id ($win.id | into string)
}

# Focus
niri msg action focus-window --id ($win.id | into string)
