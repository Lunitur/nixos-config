#!/usr/bin/env nu

def run [name: string, ...args: string] {
  if (ps | where name =~ $name | length | $in == 0) {
    ^pueue add $name ...$args
  }
}

^pueue clean
#^pueue parallel 1024

if ($env.XDG_SESSION_TYPE == "wayland") {
    run swaybg "-i" ~/Pictures/wallhaven-8586my.png "-m" fit
}


if ($env.XDG_SESSION_TYPE == "x11") {

    run nm-applet
#    run blueman-applet
    run flameshot
    run dunst

    run picom "--config" ".config/picom/picom.conf"

    run System/lolmouse
}

# run discord "--start-minimized"
run telegram-desktop "-startintray"
run signal-desktop "--start-in-tray"
run element-desktop


run kmonad ~/.config/kmonad/mech.kbd
run nextcloud

run caffeine
