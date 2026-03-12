#!/usr/bin/env nu

# Hidden workspace name
let SCRATCHPAD = "emacs-scratchpad"

# Find emacs window
let windows = niri msg -j windows | from json
let emacs_win = $windows | where app_id == "emacs" or app_id == "Emacs" or app_id == "emacsclient"

if ($emacs_win | is-empty) {
    # Emacs not running, spawn it
    niri msg action spawn -- emacsclient -c -a 'emacs'
    exit 0
}

let win = $emacs_win | first

if $win.is_focused {
    # It is currently focused, hide it
    niri msg action move-window-to-workspace --window-id ($win.id | into string) $SCRATCHPAD --focus=false
    
    # If the current workspace is the scratchpad workspace, switch to the previous workspace to hide it
    let workspaces = niri msg -j workspaces | from json
    let current_ws = $workspaces | where is_focused == true | first
    if $current_ws.name == $SCRATCHPAD {
        niri msg action focus-workspace-previous
    }
} else {
    # Not focused, bring it to current workspace
    let workspaces = niri msg -j workspaces | from json
    let current_ws = $workspaces | where is_focused == true | first
    let current_ws_idx = $current_ws.idx
    
    if $win.workspace_id != $current_ws_idx {
        niri msg action move-window-to-workspace --window-id ($win.id | into string) ($current_ws_idx | into string)
    }
    
    if not $win.is_floating {
        niri msg action move-window-to-floating --id ($win.id | into string)
    }
    
    niri msg action focus-window --id ($win.id | into string)
}
